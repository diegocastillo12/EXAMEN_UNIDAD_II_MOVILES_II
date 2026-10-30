import '../features/auth/providers/auth_providers.dart';
import '../features/offline_drafts/presentation/view_models/submission_sync_view_model.dart';
import '../features/onboarding/presentation/view_models/entry_view_model.dart';
import '../features/onboarding/presentation/state/entry_destination.dart';
import '../features/auth/presentation/view_models/recovery_access_view_model.dart';
import '../features/auth/domain/entities/recovery_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/presentation/widgets/startup_reveal.dart';
import 'router.dart';
import 'package:go_router/go_router.dart';
import '../features/notifications/presentation/view_models/push_view_model.dart';

class EntreHuellasApp extends ConsumerStatefulWidget {
  const EntreHuellasApp({
    this.observeNotifications = false,
    this.observeQueue = false,
    super.key,
  });
  final bool observeNotifications;
  final bool observeQueue;
  @override
  ConsumerState<EntreHuellasApp> createState() => _EntreHuellasAppState();
}

class _EntreHuellasAppState extends ConsumerState<EntreHuellasApp>
    with WidgetsBindingObserver {
  bool _foreground = true, _queueReady = false;
  String? _queueOwner;
  SubmissionSyncViewModel? _queueSync;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState phase) {
    _foreground = phase == AppLifecycleState.resumed;
    if (widget.observeQueue) {
      ref
          .read(submissionSyncViewModelProvider.notifier)
          .setEnabled(_foreground && _queueReady, owner: _queueOwner);
    }
  }

  GoRouter? _router;
  bool _pendingOpen = false;
  void _openInbox() {
    if (!_pendingOpen || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pendingOpen || _router == null) return;
      final path = _router!.routerDelegate.currentConfiguration.uri.path;
      // Wait for authentication and onboarding. Opening a push never authorizes a case.
      if (path == '/home' || path.startsWith('/home/')) {
        _pendingOpen = false;
        if (path != '/home/notifications') _router!.push('/home/notifications');
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _queueSync?.stop();
    WidgetsBinding.instance.removeObserver(this);
    _router?.routerDelegate.removeListener(_openInbox);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.observeQueue) {
      ref.watch(submissionSyncViewModelProvider);
      _queueSync = ref.read(submissionSyncViewModelProvider.notifier);
      final entry = ref.watch(entryViewModelProvider),
          recovery = ref.watch(recoveryAccessViewModelProvider),
          session = ref.watch(authSessionProvider);
      _queueReady =
          !entry.isLoading &&
          !entry.hasError &&
          entry.asData?.value == EntryDestination.home &&
          !recovery.isLoading &&
          !recovery.hasError &&
          recovery.asData?.value == RecoveryAccess.idle &&
          !session.isLoading &&
          !session.hasError;
      _queueOwner = _queueReady ? session.asData?.value?.userId : null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(submissionSyncViewModelProvider.notifier)
              .setEnabled(_foreground && _queueReady, owner: _queueOwner);
        }
      });
    }
    final router = ref.watch(routerProvider);
    if (_router != router) {
      _router?.routerDelegate.removeListener(_openInbox);
      _router = router;
      router.routerDelegate.addListener(_openInbox);
    }
    if (widget.observeNotifications) {
      ref.listen(pushViewModelProvider, (previous, next) {
        if (next.openId != (previous?.openId ?? 0)) {
          _pendingOpen = true;
          _openInbox();
        }
      });
    }
    return MaterialApp.router(
      title: 'Entre Huellas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => StartupReveal(child: child!),
      routerConfig: router,
    );
  }
}

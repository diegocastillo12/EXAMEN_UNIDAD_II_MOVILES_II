import '../features/case_matching/presentation/screens/matching_screen.dart';
import '../features/offline_cases/presentation/widgets/cached_cases_section.dart';
import '../features/saved_cases/presentation/widgets/clear_offline_lists_button.dart';
import 'secure_route_surface.dart';
import '../features/offline_drafts/presentation/screens/submission_queue_screen.dart';
import '../features/offline_drafts/presentation/screens/local_drafts_screen.dart';
import '../features/user_blocks/presentation/screens/user_blocks_screen.dart';
import '../features/user_blocks/presentation/widgets/user_block_controls.dart';
import '../features/case_contacts/presentation/view_models/case_contact_view_model.dart';
import '../features/case_posters/presentation/widgets/case_share_button.dart';
import '../features/case_contacts/presentation/widgets/case_contact_panel.dart';
import '../features/content_reports/presentation/screens/content_report_screen.dart';
import '../features/content_reports/presentation/widgets/report_content_button.dart';
import '../features/case_closure/presentation/screens/case_closure_screen.dart';
import '../features/found_cases/presentation/view_models/found_read_view_model.dart';
import '../features/explore/presentation/view_models/explore_view_model.dart';
import '../features/notifications/presentation/screens/inbox_screen.dart';
import '../features/notifications/presentation/widgets/follow_target_button.dart';
import '../features/explore/presentation/widgets/explore_section.dart';
import '../features/explore/presentation/widgets/explore_map_button.dart';
import '../features/case_timeline/presentation/widgets/timeline_access_button.dart';
import '../features/case_timeline/presentation/screens/case_timeline_screen.dart';
import '../features/case_timeline/presentation/screens/sighting_review_screen.dart';
import '../features/explore/presentation/screens/explore_map_screen.dart';
import '../features/case_posters/presentation/screens/case_poster_screen.dart';
import '../features/case_posters/domain/entities/case_poster.dart';
import '../features/places/presentation/widgets/place_search_fields.dart';
import 'widgets/report_location_search.dart';
import '../features/saved_cases/presentation/screens/saved_cases_screen.dart';
import '../features/saved_cases/domain/entities/saved_case_ref.dart';
import '../features/saved_cases/presentation/widgets/save_case_button.dart';
import '../features/found_cases/presentation/widgets/recovery_case_actions.dart';
import '../features/sightings/domain/entities/sighting.dart';
import '../features/sightings/providers/sighting_providers.dart';
import '../features/sightings/presentation/screens/sighting_screen.dart';
import '../features/lost_cases/presentation/view_models/case_read_view_model.dart';
import '../features/pets/presentation/view_models/pet_list_view_model.dart';
import '../features/found_cases/providers/found_case_providers.dart';
import '../features/found_cases/domain/entities/found_case.dart';
import 'navigation/entity_editor_page.dart';
import 'navigation/entity_detail_page.dart';
import '../features/found_cases/presentation/screens/found_editor_screen.dart';
import '../features/found_cases/presentation/screens/found_detail_screen.dart';
import '../features/found_cases/presentation/screens/my_found_cases_screen.dart';
import 'screens/lost_report_screen.dart';
import '../features/found_cases/presentation/screens/recovery_reports_screen.dart';
import '../features/home/presentation/widgets/home_content.dart'
    show openLostReport;
import '../features/lost_cases/presentation/screens/case_detail_screen.dart';
import '../features/lost_cases/presentation/screens/my_cases_screen.dart';
import '../core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/access_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/password_recovery_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/view_models/recovery_access_view_model.dart';
import '../features/auth/domain/entities/recovery_access.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/widgets/profile_avatar.dart';
import '../features/profile/presentation/view_models/profile_view_model.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/moderation_appeals/presentation/screens/appeals_screen.dart';
import '../features/interest_zones/presentation/screens/interest_zones_screen.dart';
import '../features/alert_preferences/presentation/screens/alert_preferences_screen.dart';
import '../features/pets/presentation/widgets/pets_section.dart';
import '../features/pets/presentation/screens/pet_editor_screen.dart';
import '../features/pets/presentation/screens/pet_detail_screen.dart';
import '../features/pets/domain/entities/pet.dart';
import '../features/onboarding/presentation/screens/entry_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/view_models/entry_view_model.dart';
import '../features/onboarding/presentation/state/entry_destination.dart';

final routerProvider = Provider<GoRouter>((ref) {
  void refreshCaseContacts() {
    if (ref.mounted) ref.invalidate(caseContactViewModelProvider);
  }

  final refresh = ValueNotifier(0);
  ref.listen(entryViewModelProvider, (_, _) => refresh.value++);
  ref.listen(recoveryAccessViewModelProvider, (_, _) => refresh.value++);
  GoRouter? activeRouter;
  final router = GoRouter(
    initialLocation: '/access',
    refreshListenable: refresh,
    redirect: (context, state) {
      final recovery = ref.read(recoveryAccessViewModelProvider);
      if (recovery.isLoading) return state.uri.path == '/' ? null : '/';
      if (recovery.hasError ||
          recovery.asData?.value == RecoveryAccess.ready ||
          recovery.asData?.value == RecoveryAccess.invalid) {
        final navigation = activeRouter?.routeInformationProvider.value.state;
        final current = activeRouter?.routerDelegate.currentConfiguration;
        final currentTop = current?.lastOrNull?.route;
        final restoring =
            navigation is Map ||
            (navigation is RouteInformationState &&
                navigation.type == NavigatingType.restore);
        if (restoring &&
            state.uri == current?.uri &&
            currentTop is GoRoute &&
            currentTop.path == '/recover-password') {
          return null;
        }
        // During refresh of an imperatively pushed page, uri can still refer
        // to the login underneath. The top match identifies the visible flow.
        if (state.uri.path == '/recover-password' ||
            (state.topRoute is GoRoute &&
                (state.topRoute as GoRoute).path == '/recover-password')) {
          return null;
        }
        return state.uri.path == '/reset-password' ? null : '/reset-password';
      }
      final flow = ref.read(entryViewModelProvider);
      final path = switch (flow.asData?.value) {
        EntryDestination.login => '/access',
        EntryDestination.onboarding => '/onboarding',
        EntryDestination.home => '/home',
        _ => '/',
      };
      if (path == '/access' &&
          ['/register', '/recover-password'].contains(state.uri.path)) {
        return null;
      }
      if (path == '/home' &&
          state.uri.path == '/home/found-cases/new' &&
          state.uri.queryParameters['independent'] != 'true' &&
          ((state.uri.queryParameters['case'] ?? '').trim().isEmpty ||
              !{
                'true',
                'false',
              }.contains(state.uri.queryParameters['community']))) {
        return '/home';
      }
      if (path == '/home' &&
          (state.uri.path == '/home/found-cases/new' ||
              state.uri.path == '/home/my-found-cases' ||
              state.uri.path.startsWith('/home/found-cases/') ||
              state.uri.path == '/home/lost-cases/new' ||
              state.uri.path == '/home/lost-cases/community/new' ||
              state.uri.path == '/home/my-cases' ||
              state.uri.path == '/home/my-reports' ||
              state.uri.path == '/home/saved-cases' ||
              state.uri.path == '/home/notifications' ||
              state.uri.path == '/home/drafts' ||
              state.uri.path == '/home/submissions' ||
              state.uri.path == '/home/blocked-users' ||
              state.uri.path == '/home/appeals' ||
              state.uri.path == '/home/coincidencias' ||
              state.uri.path == '/home/explore-map' ||
              state.uri.path.startsWith('/home/posters/') ||
              state.uri.path.startsWith('/home/sightings/') ||
              state.uri.path.startsWith('/home/timeline/') ||
              state.uri.path.startsWith('/home/denounce/') ||
              state.uri.path.startsWith('/home/closure/') ||
              state.uri.path.startsWith('/home/cases/'))) {
        return null;
      }
      if (path == '/home' && state.uri.path == '/home/profile') return null;
      if (path == '/home' && state.uri.path == '/home/interest-zones') {
        return null;
      }
      if (path == '/home' && state.uri.path == '/home/alert-preferences') {
        return null;
      }
      if (path == '/home' && state.uri.path.startsWith('/home/pets/')) {
        return null;
      }
      return state.uri.path == path ? null : path;
    },
    routes: [
      GoRoute(
        path: '/recover-password',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 320),
          reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              OriginPageTransition(
                animation: animation,
                origin: state.extra is Rect ? state.extra as Rect : null,
                child: child,
              ),
          child: const PasswordRecoveryScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const EntryScreen(),
        ),
      ),
      GoRoute(
        path: '/access',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AccessScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 320),
          reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              OriginPageTransition(
                animation: animation,
                origin: state.extra is Rect ? state.extra as Rect : null,
                child: child,
              ),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
          onHomeRefresh: () async {
            ref.read(profileViewModelProvider.notifier).retry();
            await ref.read(profileViewModelProvider.future);
          },
          onAlerts: (source) =>
              context.push('/home/notifications', extra: source),
          profileAvatar: const ProfileAvatarButton(),
          petsContent: const PetsSection(),
          exploreFloatingAction: const ExploreMapButton(),
          exploreContent: ExploreSection(
            locationSearchBuilder: (label, onSelect) =>
                PlaceSearchFields(initialLabel: label, onSelect: onSelect),
          ),
        ),
        routes: [
          GoRoute(
            path: 'coincidencias',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: MatchingScreen(
                onOpen: (reference, origin) async {
                  await context.push(
                    '/home/${reference.source == 'lost' ? 'cases' : 'found-cases'}/${reference.id}',
                    extra: origin,
                  );
                },
              ),
            ),
          ),
          GoRoute(
            path: 'appeals',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const AppealsScreen(),
            ),
          ),
          GoRoute(
            path: 'notifications',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: const InboxScreen(),
            ),
          ),
          GoRoute(
            path: 'saved-cases',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: const SecureRouteSurface(
                child: SavedCasesScreen(offlineCases: CachedCasesSection()),
              ),
            ),
          ),
          GoRoute(
            path: 'explore-map',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: const ExploreMapScreen(),
            ),
          ),
          GoRoute(
            path: 'my-reports',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: RecoveryReportsScreen(
                onReport: (source, onReturn) =>
                    openLostReport(source, onReturn: onReturn, radius: 28),
              ),
            ),
          ),
          GoRoute(
            path: 'found-cases/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  foundEditorContextProvider.overrideWithValue(
                    FoundEditorContext(
                      communitySearch:
                          state.uri.queryParameters['independent'] == 'true',
                      independentFound:
                          state.uri.queryParameters['independent'] == 'true',
                      targetId: state.uri.queryParameters['case'],
                      communityTarget:
                          state.uri.queryParameters['community'] == 'true',
                    ),
                  ),
                ],
                child: const FoundEditorScreen(
                  locationSearchBuilder: buildReportLocationSearch,
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'sightings/:source/:id',
            redirect: (context, state) =>
                !['lost', 'found'].contains(state.pathParameters['source']) ||
                    !RegExp(
                      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                    ).hasMatch(state.pathParameters['id'] ?? '')
                ? '/home'
                : null,
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  sightingTargetProvider.overrideWithValue(
                    SightingTarget(
                      state.pathParameters['id']!,
                      state.pathParameters['source'] == 'found',
                    ),
                  ),
                ],
                child: const SightingScreen(),
              ),
            ),
          ),
          GoRoute(
            path: 'my-found-cases',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MyFoundCasesScreen(),
            ),
          ),
          GoRoute(
            path: 'submissions',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: SubmissionQueueScreen(
                onOpen: (entry) {
                  final d = entry.command, receipt = entry.receipt;
                  if (receipt?.lost != null) {
                    context.push('/home/cases/${receipt!.id}');
                    return;
                  }
                  if (receipt?.found != null) {
                    context.push('/home/found-cases/${receipt!.id}');
                    return;
                  }
                  final p = d.slot.split(':');
                  final route = d.slot == 'independent-found'
                      ? '/home/found-cases/new?independent=true'
                      : d.slot == 'lost'
                      ? '/home/lost-cases/new'
                      : d.slot == 'community-search'
                      ? '/home/lost-cases/community/new'
                      : p.length == 3 && p[0] == 'sighting'
                      ? (receipt != null
                            ? '/home/${p[1] == 'true' ? 'found-cases' : 'cases'}/${Uri.encodeComponent(p[2])}'
                            : '/home/sightings/${p[1] == 'true' ? 'found' : 'lost'}/${Uri.encodeComponent(p[2])}')
                      : p.length == 3 && p[0] == 'found'
                      ? Uri(
                          path: '/home/found-cases/new',
                          queryParameters: {'case': p[2], 'community': p[1]},
                        ).toString()
                      : null;
                  if (route != null) context.push(route);
                },
              ),
            ),
          ),
          GoRoute(
            path: 'drafts',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: LocalDraftsScreen(
                onOpen: (draft) async {
                  final parts = draft.slot.split(':');
                  final path = draft.slot == 'independent-found'
                      ? '/home/found-cases/new?independent=true'
                      : draft.slot == 'lost'
                      ? '/home/lost-cases/new'
                      : draft.slot == 'community-search'
                      ? '/home/lost-cases/community/new'
                      : parts.first == 'sighting' && parts.length == 3
                      ? '/home/sightings/${parts[1] == 'true' ? 'found' : 'lost'}/${Uri.encodeComponent(parts[2])}'
                      : parts.first == 'found' && parts.length == 3
                      ? Uri(
                          path: '/home/found-cases/new',
                          queryParameters: {
                            'case': parts[2],
                            'community': parts[1],
                          },
                        ).toString()
                      : null;
                  if (path != null) await context.push<void>(path);
                },
              ),
            ),
          ),
          GoRoute(
            path: 'blocked-users',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: UserBlocksScreen(onSettled: refreshCaseContacts),
            ),
          ),
          GoRoute(
            path: 'found-cases/:id',
            pageBuilder: (context, state) => entityDetailPage(
              context: context,
              origin: state.extra is Rect ? state.extra as Rect : null,
              key: state.pageKey,
              child: FoundDetailScreen(
                contact: CaseContactPanel(
                  target: (source: 'found', id: state.pathParameters['id']!),
                ),
                shareActionBuilder: (name, event, canFollow) => CaseShareButton(
                  target: PosterCase(
                    PosterSource.found,
                    state.pathParameters['id']!,
                  ),
                  caseActions: [
                    SaveCaseButton(
                      target: SavedCaseRef(
                        source: SavedCaseSource.found,
                        id: state.pathParameters['id']!,
                      ),
                      inPanel: true,
                    ),
                    if (canFollow)
                      FollowTargetButton(
                        inPanel: true,
                        target: (
                          kind: 'found',
                          id: state.pathParameters['id']!,
                        ),
                      ),
                    UserBlockPanel(
                      inPanel: true,
                      target: (kind: 'found', id: state.pathParameters['id']!),
                      onSettled: refreshCaseContacts,
                    ),
                  ],
                  title: name,
                  eventLabel: event,
                  onReport: (source) => context.push<void>(
                    '/home/denounce/found/${state.pathParameters['id']}',
                    extra: source,
                  ),
                ),
                id: state.pathParameters['id']!,
                timelineAction: TimelineAccessButton(
                  target: (id: state.pathParameters['id']!, community: true),
                ),
                posterAction: TextButton.icon(
                  onPressed: () => context.push(
                    '/home/posters/found/${state.pathParameters['id']}',
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Crear cartel con QR'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'lost-cases/community/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  foundEditorContextProvider.overrideWithValue(
                    const FoundEditorContext(),
                  ),
                ],
                child: const LostReportScreen(initialCommunity: true),
              ),
            ),
          ),
          GoRoute(
            path: 'lost-cases/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  foundEditorContextProvider.overrideWithValue(
                    const FoundEditorContext(),
                  ),
                ],
                child: const LostReportScreen(),
              ),
            ),
          ),
          GoRoute(
            path: 'my-cases',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MyCasesScreen(),
            ),
          ),
          GoRoute(
            path: 'cases/:id',
            pageBuilder: (context, state) => entityDetailPage(
              context: context,
              origin: state.extra is Rect ? state.extra as Rect : null,
              key: state.pageKey,
              child: CaseDetailScreen(
                contact: CaseContactPanel(
                  target: (source: 'lost', id: state.pathParameters['id']!),
                ),
                shareActionBuilder: (name, event, canFollow) => CaseShareButton(
                  target: PosterCase(
                    PosterSource.lost,
                    state.pathParameters['id']!,
                  ),
                  caseActions: [
                    SaveCaseButton(
                      target: SavedCaseRef(
                        source: SavedCaseSource.lost,
                        id: state.pathParameters['id']!,
                      ),
                      inPanel: true,
                    ),
                    if (canFollow)
                      FollowTargetButton(
                        inPanel: true,
                        target: (kind: 'lost', id: state.pathParameters['id']!),
                      ),
                    UserBlockPanel(
                      inPanel: true,
                      target: (kind: 'lost', id: state.pathParameters['id']!),
                      onSettled: refreshCaseContacts,
                    ),
                  ],
                  title: name,
                  eventLabel: event,
                  onReport: (source) => context.push<void>(
                    '/home/denounce/lost/${state.pathParameters['id']}',
                    extra: source,
                  ),
                ),
                id: state.pathParameters['id']!,
                timelineAction: TimelineAccessButton(
                  target: (id: state.pathParameters['id']!, community: false),
                ),
                posterAction: TextButton.icon(
                  onPressed: () => context.push(
                    '/home/posters/lost/${state.pathParameters['id']}',
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Crear cartel con QR'),
                ),
                recoveryActions: (value, onChanged) => RecoveryCaseActions(
                  showSightingAction: false,
                  id: value.id,
                  community: false,
                  canResolve: value.canResolve,
                  open: value.status == 'active',
                  onChanged: () {
                    onChanged();
                    ref.invalidate(myCasesViewModelProvider);
                    ref.invalidate(petListViewModelProvider);
                    ref.invalidate(petDetailViewModelProvider);
                  },
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'alert-preferences',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const AlertPreferencesScreen(),
            ),
          ),
          GoRoute(
            path: 'denounce/:kind/:id',
            redirect: (_, state) =>
                ![
                      'lost',
                      'found',
                      'sighting',
                    ].contains(state.pathParameters['kind']) ||
                    !RegExp(
                      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                    ).hasMatch(state.pathParameters['id'] ?? '')
                ? '/home'
                : null,
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ContentReportScreen(
                target: (
                  kind: state.pathParameters['kind']!,
                  id: state.pathParameters['id']!,
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'closure/:source/:id',
            redirect: (_, state) =>
                !['lost', 'found'].contains(state.pathParameters['source']) ||
                    !RegExp(
                      r'^[0-9a-f-]{36}$',
                    ).hasMatch(state.pathParameters['id'] ?? '')
                ? '/home'
                : null,
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: CaseClosureScreen(
                target: (
                  id: state.pathParameters['id']!,
                  community: state.pathParameters['source'] == 'found',
                ),
                onSaved: () {
                  ref.invalidate(publicCaseViewModelProvider);
                  ref.invalidate(publicFoundViewModelProvider);
                  ref.invalidate(myCasesViewModelProvider);
                  ref.invalidate(myFoundCasesViewModelProvider);
                  ref.invalidate(petListViewModelProvider);
                  ref.invalidate(petDetailViewModelProvider);
                  ref.read(exploreViewModelProvider.notifier).refresh();
                },
              ),
            ),
          ),
          GoRoute(
            path: 'timeline/:source/:id',
            redirect: (_, state) =>
                !['lost', 'found'].contains(state.pathParameters['source']) ||
                    !RegExp(
                      r'^[0-9a-f-]{36}$',
                    ).hasMatch(state.pathParameters['id'] ?? '')
                ? '/home'
                : null,
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: CaseTimelineScreen(
                target: (
                  id: state.pathParameters['id']!,
                  community: state.pathParameters['source'] == 'found',
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: 'sightings/:sighting',
                pageBuilder: (context, state) => entityEditorPage(
                  context: context,
                  key: state.pageKey,
                  source: state.extra,
                  child: SightingReviewScreen(
                    reportAction: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReportContentButton(
                          target: (
                            kind: 'sighting',
                            id: state.pathParameters['sighting']!,
                          ),
                        ),
                        UserBlockPanel(
                          onSettled: refreshCaseContacts,
                          target: (
                            kind: 'sighting',
                            id: state.pathParameters['sighting']!,
                          ),
                        ),
                      ],
                    ),
                    reviewKey: (
                      target: (
                        id: state.pathParameters['id']!,
                        community: state.pathParameters['source'] == 'found',
                      ),
                      id: state.pathParameters['sighting']!,
                    ),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'posters/:source/:id',
            redirect: (_, state) =>
                !['lost', 'found'].contains(state.pathParameters['source'])
                ? '/home'
                : null,
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: CasePosterScreen(
                target: PosterCase(
                  PosterSource.values.byName(state.pathParameters['source']!),
                  state.pathParameters['id']!,
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'pets/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: const PetEditorScreen(petId: 'new'),
            ),
          ),
          GoRoute(
            path: 'pets/:id',
            pageBuilder: (context, state) {
              final child = PetDetailScreen(
                petId: state.pathParameters['id']!,
                savedPet: state.extra is Pet ? state.extra as Pet : null,
                canEdit: state.extra != 'inspect',
              );
              return entityDetailPage(
                context: context,
                key: state.pageKey,
                child: child,
                origin: state.extra is Rect ? state.extra as Rect : null,
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: PetEditorScreen(petId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      OriginPageTransition(
                        animation: animation,
                        origin: state.extra is Rect
                            ? state.extra as Rect
                            : null,
                        child: child,
                      ),
              child: ProfileScreen(
                offlineDataAction: const ClearOfflineListsButton(),
                cityFieldBuilder: (city, enabled, invalid, onQuery, onSelect) =>
                    PlaceSearchFields(
                      citiesOnly: true,
                      initialLabel: city,
                      enabled: enabled,
                      invalid: invalid,
                      onQueryChanged: onQuery,
                      onSelect: (place) => onSelect(place.label),
                    ),
              ),
            ),
          ),
          GoRoute(
            path: 'interest-zones',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: InterestZonesScreen(
                followActionBuilder: (id) =>
                    FollowTargetButton(target: (kind: 'zone', id: id)),
              ),
            ),
          ),
        ],
      ),
    ],
  );
  activeRouter = router;
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

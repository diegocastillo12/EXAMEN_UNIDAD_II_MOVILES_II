import 'package:flutter/material.dart';
import 'confirmation_toast.dart';
import 'entity_screen_shell.dart';

class CaseScreenShell extends StatelessWidget {
  const CaseScreenShell({
    required this.title,
    required this.child,
    this.header,
    this.persistentHeader,
    this.trailingAction,
    this.count = 8,
    this.onBack,
    this.stage = 'content',
    this.loading = false,
    this.immersive = false,
    this.notice,
    this.noticeActionLabel,
    this.onNoticeAction,
    this.noticeId,
    this.noticeIsError = true,
    super.key,
  });
  final String title;
  final int count;
  final Widget child;
  final Widget? header;
  final Widget? persistentHeader;
  final Widget? trailingAction;
  final VoidCallback? onBack;
  final Object stage;
  final bool loading;
  final bool immersive;
  final String? notice;
  final String? noticeActionLabel;
  final VoidCallback? onNoticeAction;
  final Object? noticeId;
  final bool noticeIsError;
  @override
  Widget build(BuildContext context) => ConfirmationToastHost(
    confirmed: notice != null,
    message: notice ?? '',
    noticeId: noticeId,
    isError: noticeIsError,
    actionLabel: noticeActionLabel,
    onAction: onNoticeAction,
    child: EntityScreenShell(
      title: title,
      header: header,
      persistentHeader: persistentHeader,
      trailingAction: trailingAction,
      onBack: onBack,
      stage: stage,
      loading: loading,
      immersive: immersive,
      count: count,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF111111),
          height: 1.5,
        ),
        child: child,
      ),
    ),
  );
}

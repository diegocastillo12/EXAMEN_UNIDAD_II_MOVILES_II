import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../widgets/saved_cases_section.dart';

class SavedCasesScreen extends ConsumerWidget {
  const SavedCasesScreen({this.offlineCases, super.key});
  final Widget? offlineCases;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PullToRefresh(
      indicatorTop: MediaQuery.paddingOf(context).top + 8,
      child: EntityScreenShell(
        title: 'Guardados',
        loading: false,
        count: 2,
        scrollPhysics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (offlineCases != null)
              StaggerRevealItem(order: 0, child: offlineCases!),
            const StaggerRevealItem(order: 1, child: SavedCasesSection()),
          ],
        ),
      ),
    );
  }
}

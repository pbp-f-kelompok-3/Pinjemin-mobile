import 'package:flutter/material.dart';

import '../main.dart';
import '../models/help_content.dart';
import '../widgets/left_drawer.dart';
import '../widgets/pinjemin_app_bar.dart';

/// Static Help Center: tutorial, privacy policy and FAQ in three tabs.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const PinjeminAppBar(title: 'Bantuan'),
        drawer: const LeftDrawer(),
        body: Column(
          children: [
            Material(
              color: theme.colorScheme.surface,
              child: TabBar(
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: colors.mutedText,
                labelStyle: theme.textTheme.labelLarge,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                dividerColor: colors.hairline,
                tabs: const [
                  Tab(text: 'Tutorial'),
                  Tab(text: 'Privasi'),
                  Tab(text: 'FAQ'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [_TutorialTab(), _PolicyTab(), _FaqTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _tabPadding = EdgeInsets.fromLTRB(20, 24, 20, 24);

class _TutorialTab extends StatelessWidget {
  const _TutorialTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _tabPadding,
      children: const [
        _SectionTitle('Cara meminjam barang', subtitle: 'Mode Minjem'),
        _StepList(steps: borrowSteps),
        SizedBox(height: 24),
        _SectionTitle('Cara meminjamkan barang', subtitle: 'Mode Minjemin'),
        _StepList(steps: lendSteps),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(subtitle!, style: theme.textTheme.bodySmall!.copyWith(color: colors.mutedText)),
          Text(title, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.steps});

  final List<HelpStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      child: Text('${i + 1}', style: theme.textTheme.labelLarge),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(steps[i].title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(steps[i].body, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PolicyTab extends StatelessWidget {
  const _PolicyTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PinjeminColors>()!;

    return ListView(
      padding: _tabPadding,
      children: [
        Text('Kebijakan privasi', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(policyUpdatedAt, style: theme.textTheme.bodySmall!.copyWith(color: colors.mutedText)),
        const SizedBox(height: 12),
        Text(policyIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        for (var i = 0; i < policySections.length; i++) ...[
          _PolicyCard(number: i + 1, section: policySections[i]),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.number, required this.section});

  final int number;
  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$number. ${section.title}', style: theme.textTheme.titleMedium),
            if (section.intro != null) ...[
              const SizedBox(height: 8),
              Text(section.intro!, style: theme.textTheme.bodyMedium),
            ],
            for (final point in section.points)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(child: Text('•', style: theme.textTheme.bodyMedium)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FaqTab extends StatelessWidget {
  const _FaqTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: _tabPadding,
      children: [
        Text('Pertanyaan umum', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        for (final item in faqItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: theme.colorScheme.onSurface,
                collapsedIconColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.onSurface,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.centerLeft,
                title: Text(item.question, style: theme.textTheme.titleMedium),
                children: [Text(item.answer, style: theme.textTheme.bodyMedium)],
              ),
            ),
          ),
      ],
    );
  }
}

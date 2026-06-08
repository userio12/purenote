import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];
  final _lastTapTime = [0, 0, 0];
  final _children = <Widget>[const SizedBox(), const SizedBox(), const SizedBox()];
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _children[0] = widget.child;
  }

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int _resolveIndex(String location) {
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final tabIndex = _resolveIndex(location);
    final colors = Theme.of(context).extension<AppColors>()!;

    if (tabIndex != _lastIndex) {
      _children[tabIndex] = widget.child;
      _lastIndex = tabIndex;
    } else {
      _children[tabIndex] = widget.child;
    }

    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: List.generate(
          3,
          (i) => PrimaryScrollController(
            controller: _scrollControllers[i],
            child: _children[i],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: NavigationBar(
            selectedIndex: tabIndex,
            backgroundColor: colors.surface.withValues(alpha: 0.85),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            onDestinationSelected: (i) {
              final now = DateTime.now().millisecondsSinceEpoch;
              if (i == tabIndex && now - _lastTapTime[i] < 500) {
                _scrollControllers[i].animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
              _lastTapTime[i] = now;
              switch (i) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/tasks');
                  break;
                case 2:
                  context.go('/settings');
                  break;
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.note_outlined),
                selectedIcon: const Icon(Icons.note),
                label: AppLocalizations.of(context)!.notes,
              ),
              NavigationDestination(
                icon: const Icon(Icons.checklist_outlined),
                selectedIcon: const Icon(Icons.checklist),
                label: AppLocalizations.of(context)!.tasks,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: AppLocalizations.of(context)!.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

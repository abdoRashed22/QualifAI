import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qualif_ai/core/cache/hive_cache.dart';
import 'package:qualif_ai/core/di/injection.dart';
import 'package:qualif_ai/core/router/app_router.dart';

import 'nav_rail_item.dart';

class SideRailNavigation extends StatefulWidget {
  final List<NavRailItem> mainItems;
  final List<NavRailItem> bottomItems;
  final Widget homeScreen;
  final String appTitle;

  const SideRailNavigation({
    Key? key,
    required this.mainItems,
    required this.bottomItems,
    required this.homeScreen,
    this.appTitle = 'QualifAI',
  }) : super(key: key);

  @override
  State<SideRailNavigation> createState() => SideRailNavigationState();

  static SideRailNavigationState? of(BuildContext context) {
    return context.findAncestorStateOfType<SideRailNavigationState>();
  }
}

class SideRailNavigationState extends State<SideRailNavigation> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  late List<Widget> _screens;
  final Set<int> _visitedIndices = {};

  @override
  void initState() {
    super.initState();
    _screens = widget.mainItems.map((item) => item.screen).toList();
    if (_screens.isNotEmpty) {
      _screens[0] =
          widget.homeScreen; // Ensure home is securely assigned to index 0
    }
    _visitedIndices.add(0); // دائمًا نحمل الشاشة الرئيسية أولاً
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedIndices.add(index); // حفظ الشاشة كمقروءة عند فتحها
      _isDrawerOpen = false;
    });
  }

  void openDrawer() => setState(() => _isDrawerOpen = true);

  void _onBottomItemTapped(NavRailItem item) async {
    setState(() {
      _isDrawerOpen = false;
    });
    if (item.label == 'الخروج') {
      final cache = sl<HiveCache>();
      await cache.clearAll();
      if (mounted) context.go(AppRoutes.login);
    } else if (item.label == 'دعم') {
      if (mounted) context.push(AppRoutes.support);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
    final inactiveIconColor = Colors.white.withOpacity(0.75);
    final activeIconColor = Colors.white;
    final activeBg = Colors.white.withOpacity(0.1);
    final activeBorder = theme.colorScheme.secondary;
    final labelStyle = theme.textTheme.bodyMedium ??
        const TextStyle(color: Colors.white, fontSize: 14);

    return Stack(
      children: [
        IndexedStack(
          index: _selectedIndex,
          children: List.generate(_screens.length, (index) {
            // نعرض الشاشة فقط إذا زارها المستخدم، غير ذلك نعرض عنصر فارغ
            return _visitedIndices.contains(index)
                ? _screens[index]
                : const SizedBox.shrink();
          }),
        ),

        // Overlay for drawer (dimming)
        if (_isDrawerOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isDrawerOpen = false),
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),

        // Drawer (Expanded state)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: _isDrawerOpen ? 0.0 : -220.0,
          width: 220.0,
          child: Material(
            color: bgColor,
            elevation: 8.0,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drawer Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isDrawerOpen = false),
                          child: Icon(Icons.close,
                              color: inactiveIconColor, size: 22),
                        ),
                        Expanded(
                          child: Text(
                            widget.appTitle,
                            style: labelStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Main Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.mainItems.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final item = widget.mainItems[index];
                        final isActive = _selectedIndex == index;
                        return InkWell(
                          onTap: () => _onItemTapped(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isActive ? activeBg : Colors.transparent,
                              border: isActive
                                  ? Border(
                                      right: BorderSide(
                                          color: activeBorder, width: 4))
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(item.label,
                                    style: labelStyle.copyWith(
                                      color: isActive
                                          ? activeIconColor
                                          : inactiveIconColor,
                                    )),
                                const SizedBox(width: 12),
                                Icon(item.icon,
                                    color: isActive
                                        ? activeIconColor
                                        : inactiveIconColor,
                                    size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Bottom Actions (Support / Logout)
                  ...widget.bottomItems.map((item) {
                    return InkWell(
                      onTap: () => _onBottomItemTapped(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(item.label,
                                style: labelStyle.copyWith(
                                  color: inactiveIconColor,
                                )),
                            const SizedBox(width: 12),
                            Icon(item.icon, color: inactiveIconColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

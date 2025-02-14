import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/foundation.dart' show YaruPageController;
import 'package:yaru_widgets/widgets.dart'
    show YaruTitleBarTheme, YaruTitleBarThemeData, YaruTitleBarStyle;

import 'yaru_master_detail_page.dart';
import 'yaru_master_detail_theme.dart';
import 'yaru_master_list_view.dart';

class YaruPortraitLayout extends StatefulWidget {
  const YaruPortraitLayout({
    super.key,
    required this.tileBuilder,
    required this.pageBuilder,
    this.onSelected,
    this.appBar,
    this.bottomBar,
    required this.controller,
  });

  final YaruMasterTileBuilder tileBuilder;
  final IndexedWidgetBuilder pageBuilder;
  final ValueChanged<int>? onSelected;

  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;

  final YaruPageController controller;

  @override
  State<YaruPortraitLayout> createState() => _YaruPortraitLayoutState();
}

class _YaruPortraitLayoutState extends State<YaruPortraitLayout> {
  late int _selectedIndex;
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  void initState() {
    widget.controller.addListener(_controllerCallback);
    _selectedIndex = widget.controller.index;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerCallback);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant YaruPortraitLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_controllerCallback);
      widget.controller.addListener(_controllerCallback);
      _selectedIndex = widget.controller.index;
    }
  }

  void _controllerCallback() {
    if (widget.controller.index != _selectedIndex) {
      setState(() => _selectedIndex = widget.controller.index);
    }
  }

  void _onTap(int index) {
    widget.controller.index = index;
    widget.onSelected?.call(_selectedIndex);
  }

  MaterialPage page(int index) {
    return MaterialPage(
      child: Builder(
        builder: (context) => widget.pageBuilder(context, _selectedIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = YaruMasterDetailTheme.of(context);
    return WillPopScope(
      onWillPop: () async => !await _navigator.maybePop(),
      child: Theme(
        data: Theme.of(context).copyWith(
          pageTransitionsTheme: theme.portraitTransitions,
        ),
        child: Navigator(
          key: _navigatorKey,
          onPopPage: (route, result) {
            _selectedIndex = -1;
            return route.didPop(result);
          },
          pages: [
            MaterialPage(
              child: YaruTitleBarTheme(
                data: const YaruTitleBarThemeData(
                  style: kIsWeb
                      ? YaruTitleBarStyle.undecorated
                      : YaruTitleBarStyle.normal,
                ),
                child: Scaffold(
                  appBar: widget.appBar,
                  body: LayoutBuilder(
                    builder: (context, constraints) => YaruMasterListView(
                      length: widget.controller.length,
                      selectedIndex: _selectedIndex,
                      onTap: _onTap,
                      builder: widget.tileBuilder,
                      availableWidth: constraints.maxWidth,
                    ),
                  ),
                  bottomNavigationBar: widget.bottomBar,
                ),
              ),
            ),
            if (_selectedIndex != -1) page(_selectedIndex)
          ],
          observers: [HeroController()],
        ),
      ),
    );
  }
}

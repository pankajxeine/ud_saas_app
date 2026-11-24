import 'package:flutter/material.dart';

enum AppFilterPresentation { overlay, split, auto }

enum AppFilterSheetMode { auto, right, bottom }

class AppFilterSheet extends StatefulWidget {
  final Widget mainContent;
  final Widget child;

  final bool open;
  final VoidCallback onClose;

  final String title;

  final AppFilterPresentation presentation;
  final AppFilterSheetMode mode;

  final double width;
  final double mobileHeightFactor;
  final double desktopBreakpoint;
  final double mobileBreakpoint;

  final Duration animationDuration;

  final bool showBackdrop;
  final bool showHeader;

  final EdgeInsetsGeometry padding;

  const AppFilterSheet({
    super.key,
    required this.mainContent,
    required this.child,
    required this.open,
    required this.onClose,
    this.title = 'Filters',
    this.presentation = AppFilterPresentation.overlay,
    this.mode = AppFilterSheetMode.auto,
    this.width = 360,
    this.mobileHeightFactor = 0.85,
    this.desktopBreakpoint = 1024,
    this.mobileBreakpoint = 600,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showBackdrop = true,
    this.showHeader = true,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<AppFilterSheet> createState() => _AppFilterSheetState();
}

class _AppFilterSheetState extends State<AppFilterSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _rightSlideAnimation;
  late final Animation<Offset> _bottomSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.animationDuration,
      value: widget.open ? 1 : 0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rightSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _bottomSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant AppFilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
      _controller.reverseDuration = widget.animationDuration;
    }

    if (oldWidget.open != widget.open) {
      if (widget.open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _useSplit(double screenWidth) {
    switch (widget.presentation) {
      case AppFilterPresentation.overlay:
        return false;

      case AppFilterPresentation.split:
        // A split panel is intended for the desktop main layout. On tablets
        // and phones it becomes a drawer, so it does not squeeze the content.
        return screenWidth >= widget.desktopBreakpoint;

      case AppFilterPresentation.auto:
        return screenWidth >= widget.desktopBreakpoint;
    }
  }

  Widget _buildPanel() {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Column(
        children: [
          if (widget.showHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          if (widget.showHeader) const Divider(height: 1),
          Expanded(
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitLayout() {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainer,
      child: Row(
        children: [
          Expanded(child: widget.mainContent),
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.centerRight,
                  widthFactor: _controller.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(width: widget.width, child: child),
                  ),
                );
              },
              child: _buildPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightOverlay() {
    return Stack(
      children: [
        widget.mainContent,

        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.showBackdrop || !widget.open,
            child: GestureDetector(
              onTap: widget.onClose,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ColoredBox(
                    color: Colors.black.withOpacity(0.25 * _controller.value),
                  );
                },
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: IgnorePointer(
              ignoring: !widget.open,
              child: SlideTransition(
                position: _rightSlideAnimation,
                child: SizedBox(width: widget.width, child: _buildPanel()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomOverlay() {
    return Stack(
      children: [
        widget.mainContent,

        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.showBackdrop || !widget.open,
            child: GestureDetector(
              onTap: widget.onClose,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ColoredBox(
                    color: Colors.black.withOpacity(0.25 * _controller.value),
                  );
                },
              ),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height:
              MediaQuery.of(context).size.height * widget.mobileHeightFactor,
          child: IgnorePointer(
            ignoring: !widget.open,
            child: SlideTransition(
              position: _bottomSlideAnimation,
              child: _buildPanel(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        if (_useSplit(screenWidth)) {
          return _buildSplitLayout();
        }

        // `auto` uses a right-side drawer at every non-desktop size. A bottom
        // sheet remains available as an explicit presentation via `mode`.
        if (widget.mode == AppFilterSheetMode.bottom) {
          return _buildBottomOverlay();
        }

        return _buildRightOverlay();
      },
    );
  }
}

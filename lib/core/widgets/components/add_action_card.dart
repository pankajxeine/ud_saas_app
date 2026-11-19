import 'package:flutter/material.dart';

import 'package:ud_sass_app/core/widgets/components/ink_well.dart';

class AddActionCard extends StatefulWidget {
  const AddActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.icon = Icons.add_rounded,
    this.showButton = true,
    this.buttonLabel,
    this.control,
  });

  final String title;
  final String description;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? control;
  final bool showButton;
  final String? buttonLabel;

  @override
  State<AddActionCard> createState() => _AddActionCardState();
}

class _AddActionCardState extends State<AddActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    final primaryColor = scheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _isHovered
              ? scheme.primaryContainer.withValues(alpha: 0.35)
              : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? primaryColor.withValues(alpha: 0.65)
                : scheme.outlineVariant,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWellWrapper(
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(scheme: scheme, size: isCompact ? 40 : 46),

                    SizedBox(height: isCompact ? 10 : 12),

                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),

                    if (widget.buttonLabel != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.buttonLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    if (widget.control != null) ...[
                      const SizedBox(height: 10),
                      widget.control!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({required ColorScheme scheme, required double size}) {
    final icon = widget.icon;

    if (!widget.showButton) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: size * 0.55, color: scheme.onPrimaryContainer),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.52, color: scheme.onPrimaryContainer),
    );
  }
}

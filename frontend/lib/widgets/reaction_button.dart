import 'package:flutter/material.dart';
import '../enums/reaction_type.dart';
import '../utils/app_color.dart';
import 'reaction_picker.dart';

class ReactionButton extends StatefulWidget {
  final ReactionType? currentReaction;
  final Function(ReactionType) onReactionSelected;
  final bool isDark;

  const ReactionButton({
    Key? key,
    this.currentReaction,
    required this.onReactionSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isHovering = false;

  void _showReactionPicker() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 280,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-20, -60),
          child: Material(
            color: Colors.transparent,
            child: ReactionPicker(
              onReactionSelected: (reaction) {
                widget.onReactionSelected(reaction);
                _hideReactionPicker();
              },
              isDark: widget.isDark,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideReactionPicker() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideReactionPicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasReaction = widget.currentReaction != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovering = true);
          _showReactionPicker();
        },
        onExit: (_) {
          setState(() => _isHovering = false);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!_isHovering) {
              _hideReactionPicker();
            }
          });
        },
        child: InkWell(
          onTap: () {
            if (hasReaction) {
              widget.onReactionSelected(ReactionType.LIKE);
            } else {
              widget.onReactionSelected(ReactionType.LIKE);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (hasReaction) ...[
                  Icon(
                    widget.currentReaction!.icon,
                    size: 20,
                    color: widget.currentReaction!.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.currentReaction!.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.currentReaction!.color,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 20,
                    color: widget.isDark
                        ? AppColors.darkIconGray
                        : AppColors.lightIconGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Like',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
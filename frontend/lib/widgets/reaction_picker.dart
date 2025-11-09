import 'package:flutter/material.dart';
import '../enums/reaction_type.dart';
import '../utils/app_color.dart';

class ReactionPicker extends StatefulWidget {
  final Function(ReactionType) onReactionSelected;
  final bool isDark;

  const ReactionPicker({
    Key? key,
    required this.onReactionSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppColors.darkCardBackground
                : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.darkDivider
                  : AppColors.lightDivider,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ReactionType.values.map((reaction) {
              return _ReactionButton(
                reaction: reaction,
                onTap: () => widget.onReactionSelected(reaction),
                isDark: widget.isDark,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  final ReactionType reaction;
  final VoidCallback onTap;
  final bool isDark;

  const _ReactionButton({
    Key? key,
    required this.reaction,
    required this.onTap,
    required this.isDark,
  }) : super(key: key);

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.3 : 1.0)
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.reaction.color.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.reaction.icon,
              size: 26,
              color: widget.reaction.color,
            ),
          ),
        ),
      ),
    );
  }
}
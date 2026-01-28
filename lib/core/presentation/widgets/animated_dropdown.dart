import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AnimatedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String hintText;
  final Widget? prefixIcon;
  final String Function(T) itemLabelBuilder;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const AnimatedDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<AnimatedDropdown<T>> createState() => _AnimatedDropdownState<T>();
}

class _AnimatedDropdownState<T> extends State<AnimatedDropdown<T>> {
  final MenuController _controller = MenuController();
  bool _isHovered = false;
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;

    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuAnchor(
              controller: _controller,
              onOpen: () => setState(() => _isMenuOpen = true),
              onClose: () => setState(() => _isMenuOpen = false),
              style: MenuStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(8),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              menuChildren: widget.items.map((item) {
                final isSelected = widget.value == item;
                return MenuItemButton(
                  onPressed: () {
                    // Start select animation logic if needed, but for now simple selection
                    widget.onChanged(item);
                    state.didChange(item);
                    _controller.close();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (isSelected) {
                        return AppColors.primaryAqua.withValues(alpha: 0.1);
                      }
                      return null;
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  child:
                      SizedBox(
                            width: double.infinity,
                            child: Text(
                              widget.itemLabelBuilder(item),
                              style: AppTypography.body.copyWith(
                                color: isSelected
                                    ? AppColors.primaryAqua
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .shimmer(
                            duration: 800.ms,
                            color: AppColors.primaryAqua.withValues(alpha: 0.2),
                          ),
                );
              }).toList(),
              builder: (context, controller, child) {
                return MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: GestureDetector(
                    onTap: () {
                      if (_controller.isOpen) {
                        _controller.close();
                      } else {
                        _controller.open();
                      }
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: state.hasError
                              ? AppColors.error
                              : _isMenuOpen || _isHovered
                              ? AppColors.primaryAqua
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: _isMenuOpen || _isHovered
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryAqua.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          if (widget.prefixIcon != null) ...[
                            IconTheme(
                              data: IconThemeData(
                                color: _isMenuOpen || hasValue
                                    ? AppColors.primaryAqua
                                    : AppColors.textTertiary,
                                size: 22,
                              ),
                              child: widget.prefixIcon!,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              hasValue
                                  ? widget.itemLabelBuilder(widget.value as T)
                                  : widget.hintText,
                              style: AppTypography.body.copyWith(
                                color: hasValue
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isMenuOpen ? 0.5 : 0,
                            duration: 300.ms,
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _isMenuOpen
                                  ? AppColors.primaryAqua
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../res/colors/app_color.dart';

class CustomAppBarMenu extends StatefulWidget {
  final List<String> options;
  final void Function(String) onSelected;

  const CustomAppBarMenu({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<CustomAppBarMenu> createState() => _CustomAppBarMenuState();
}

class _CustomAppBarMenuState extends State<CustomAppBarMenu> {
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showMenu() {
    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _hideMenu,
            behavior:
                HitTestBehavior
                    .translucent, // Ensures the entire screen detects taps
            child: Stack(
              children: [
                Positioned(
                  top: position.dy + renderBox.size.height,
                  left: position.dx - 125, // Adjust as needed
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColor.softBeige,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: AppColor.black26Color,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children:
                            widget.options
                                .map(
                                  (option) => InkWell(
                                    onTap: () {
                                      _hideMenu();
                                      widget.onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        option,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _menuKey,
      icon: const Icon(Icons.more_vert, color: AppColor.blackColor),
      onPressed: () {
        if (_overlayEntry == null) {
          _showMenu();
        } else {
          _hideMenu();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_colors.dart';

class TongiAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsPressed;

  const TongiAppbar({super.key, required this.onSettingsPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TongiColors.primary,
      title: Image.asset("assets/images/tongiWhite.png", height: 50),
      actions: [
        IconButton(
          onPressed: onSettingsPressed,
          icon: const Icon(Icons.settings),
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:image_app1/settings/app_settings.dart';

class NavArrowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const NavArrowButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) => IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: appSettings.arrowIconSize,
        style: IconButton.styleFrom(
          fixedSize: Size.square(appSettings.arrowButtonSize),
          backgroundColor: const Color(0xFF161616).withValues(alpha: 0.75),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          hoverColor: Colors.white.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

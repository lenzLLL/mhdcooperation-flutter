import 'package:flutter/material.dart';

class IconTextRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const IconTextRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 44,
          child: ListTile(
            leading: Icon(icon, size: 20, color: Colors.white),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

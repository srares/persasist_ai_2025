import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      backgroundColor: Colors.transparent, // Remove background color
      elevation: 0, // Remove shadow
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(
          color: Colors.grey,
          height: 1.0,
          thickness: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

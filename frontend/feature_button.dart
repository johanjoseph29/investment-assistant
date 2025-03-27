import 'package:flutter/material.dart';

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;

  FeatureButton({required this.icon, required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    );
  }
}

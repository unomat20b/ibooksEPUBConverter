import 'package:flutter/material.dart';

class TelegramSectionCard extends StatelessWidget {
  const TelegramSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Card(clipBehavior: Clip.antiAlias, child: child),
    );
  }
}

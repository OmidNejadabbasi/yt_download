import 'package:flutter/material.dart';

class NIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? rippleColor;
  final double iconSize;
  final double borderRadius;
  final double padding;

  const NIconButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.iconColor = Colors.black87,
    this.rippleColor,
    this.iconSize = 24,
    this.borderRadius = 6,
    this.padding = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Padding(

          padding: EdgeInsets.all(padding),
          child: Icon(icon, size: iconSize, color: iconColor ),
        ),
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        splashColor: rippleColor ?? Colors.tealAccent,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ClickableColumn extends StatelessWidget {
  final List<Widget> children;
  final void Function()? onClick;
  final Color splashColor;

  const ClickableColumn({Key? key, required this.children, this.onClick, this.splashColor=Colors.greenAccent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white,
          child: InkWell(

            splashColor: splashColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: onClick,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        )
      ],
    );
  }
}

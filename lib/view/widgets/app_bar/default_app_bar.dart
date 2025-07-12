import 'package:brasil_cripto/view/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
    this.height = 65,
    required this.title,
    required this.hasLeading,
    this.leading,
    this.color,
    this.titleStyle,
  });

  final double height;
  final String title;
  final bool hasLeading;
  final void Function()? leading;
  final Color? color;
  final MyTextStyle? titleStyle;
  final FontSize fontSize = FontSize.mediumSmall;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color ?? Colors.transparent,
      automaticallyImplyLeading: hasLeading,
      leading: Visibility(
        visible: hasLeading,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              leading ??
              () {
                Navigator.pop(context);
              },
        ),
      ),
      centerTitle: true,
      title: AppText(
        title,
        style: titleStyle ?? MyTextStyle(fontWeight: FontWeight.w600),
        fontSize: fontSize,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

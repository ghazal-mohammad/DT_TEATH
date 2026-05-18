import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_assets.dart';

/// لوغو التطبيق — SVG بدون خلفية
/// الاستخدام: AppLogo() أو AppLogo(iconOnly: true)
class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final bool iconOnly;

  const AppLogo({
    super.key,
    this.width = 160,
    this.height = 160,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconOnly ? AppAssets.logoIcon : AppAssets.logo,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

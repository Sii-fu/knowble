import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 12.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Image.asset(
          'assets/images/logo 3.png',
          width: 20.w,
          height: 10.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

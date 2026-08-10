import 'package:flutter/material.dart';

abstract final class AppColors {
  static const violet = Color(0xff2D006B);
  static const blue = Color(0xff168BEE);
  static const skyBlue = Color(0xff7FE3FF);
  static const orange = Color(0xffF59E42);
  static const paleOrange = Color(0xffFFF5EB);
  static const paleBlue = Color(0xffF1F8FF);
  static const paleViolet = Color(0xffF7F1FF);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.violet,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.violet,
          secondary: AppColors.blue,
          tertiary: AppColors.orange,
          surface: const Color(0xffFFFCFF),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xf7FFFFFF),
        foregroundColor: AppColors.violet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xf9FFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Color(0x1a2D006B),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xf5FFFFFF),
        prefixIconColor: AppColors.blue,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue,
      ),
    );
  }
}

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.paleOrange,
            AppColors.paleBlue,
            AppColors.paleViolet,
          ],
          stops: [0, 0.52, 1],
        ),
      ),
      child: child,
    );
  }
}

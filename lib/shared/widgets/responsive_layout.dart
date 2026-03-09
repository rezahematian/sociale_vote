import 'package:flutter/material.dart';

/// Breakpoints base dell'app.
class ResponsiveBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1100;
}

/// Widget che seleziona automaticamente il layout
/// in base alla larghezza dello schermo.
///
/// Uso:
///
/// ResponsiveLayout(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(),
///   desktop: DesktopWidget(),
/// )
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    }

    if (width >= ResponsiveBreakpoints.tablet) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}

/// Helper statici per controllare il tipo di dispositivo
class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <
        ResponsiveBreakpoints.tablet;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet &&
        width < ResponsiveBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        ResponsiveBreakpoints.desktop;
  }
}
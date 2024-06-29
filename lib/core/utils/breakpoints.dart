class Breakpoints {
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 425;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double laptopLarge = 1440;
  static const double desktop4K = 2560;

  static bool isMobile(double width) => width < tablet;
  static bool isTablet(double width) => width >= tablet && width < laptop;
  static bool isDesktop(double width) => width >= laptop;

  static String getDeviceType(double width) {
    if (width < mobileMedium) {
      return 'mobile_small';
    } else if (width < mobileLarge) {
      return 'mobile_medium';
    } else if (width < tablet) {
      return 'mobile_large';
    } else if (width < laptop) {
      return 'tablet';
    } else if (width < laptopLarge) {
      return 'laptop';
    } else if (width < desktop4K) {
      return 'laptop_large';
    } else {
      return 'desktop_4k';
    }
  }
}

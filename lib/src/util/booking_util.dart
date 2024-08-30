import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart'
    show StyledToastAnimation, StyledToastPosition, showToast;

class BookingUtil {
  BookingUtil._();

  static bool isOverLapping(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  static DateTime getLatestDateTime(DateTime first, DateTime second) {
    return first.isAfterOrEq(second) ? first : second;
  }

  static DateTime getEarliestDateTime(DateTime first, DateTime second) {
    return first.isBeforeOrEq(second) ? first : second;
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat.Hm().format(dt);
  }

  static displayToast(BuildContext context, String message, {Color? bgColor}) {
    showToast(message,
        context: context,
        animation: StyledToastAnimation.fade,
        backgroundColor: bgColor ?? Colors.red,
        position: StyledToastPosition.bottom);
  }
}

extension DateTimeExt on DateTime {
  bool isBeforeOrEq(DateTime second) {
    return isBefore(second) || isAtSameMomentAs(second);
  }

  bool isAfterOrEq(DateTime second) {
    return isAfter(second) || isAtSameMomentAs(second);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get startOfDay => DateTime(year, month, day, 0, 0);
  DateTime get endOfDay => DateTime(year, month, day + 1, 0, 0);
  DateTime startOfDayService(DateTime service) =>
      DateTime(year, month, day, service.hour, service.minute);
  DateTime endOfDayService(DateTime service) =>
      DateTime(year, month, day, service.hour, service.minute);
}

class ColorConstant {
  static Color mainColor = fromHex('#00AB32');
  static Color whiteColor = fromHex('#FFFFFF');
  static Color greyBackgroundColor = fromHex('#EEEEEE');
  static Color blackTextColor = fromHex('#444444');
  static Color lightGreenColor = fromHex('#D7FFE3');
  static Color divideGreyColor = fromHex('#000000');
  static Color divideColor = fromHex('#AFAFAF');
  static const Color main = Color(0xff00AB32);
  static const Color white = Color(0xffffffff);
  static const Color offWhite = Color(0xfff0f0f0);

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
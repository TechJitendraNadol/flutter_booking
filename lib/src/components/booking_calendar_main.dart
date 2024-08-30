import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart' as tc
    show StartingDayOfWeek;

import '../core/booking_controller.dart';
import '../model/booking_service.dart';
import '../model/enums.dart' as bc;
import '../util/booking_util.dart';
import 'booking_checkbox.dart';

import 'booking_explanation.dart';
import 'booking_slot.dart';
import 'common_button.dart';


class BookingCalendarMain extends StatefulWidget {
  const BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.uploadBooking,
    this.bookingExplanation,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonText,
    this.bookingButtonColor,
    this.bookedSlotColor,
    this.selectedSlotColor,
    this.availableSlotColor,
    this.bookedSlotText,
    this.bookedSlotTextStyle,
    this.selectedSlotText,
    this.selectedSlotTextStyle,
    this.availableSlotText,
    this.availableSlotTextStyle,
    this.gridScrollPhysics,
    this.loadingWidget,
    this.errorWidget,
    this.uploadingWidget,
    this.checkBoxTitle,
    this.wholeDayIsBookedWidget,
    this.pauseSlotColor,
    this.pauseSlotText,
    this.hideBreakTime = false,
    this.locale,
    this.startingDayOfWeek,
    this.disabledDays,
    this.isMultiSelect,
    this.disabledDates,
    this.onChangedCheckbox,
    this.lastDay
  }) : super(key: key);

  final Stream<dynamic>? Function({required DateTime start, required DateTime end}) getBookingStream;
  final Future<dynamic> Function({required BookingService newBooking}) uploadBooking;
  final List<DateTimeRange> Function({required dynamic streamResult}) convertStreamResultToDateTimeRanges;

  ///Customizable
  final Widget? bookingExplanation;
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final String? bookingButtonText;
  final Color? bookingButtonColor;
  final Color? bookedSlotColor;
  final Color? selectedSlotColor;
  final Color? availableSlotColor;
  final Color? pauseSlotColor;

  //Added optional TextStyle to available, booked and selected cards.
  final String? checkBoxTitle;
  final String? bookedSlotText;
  final String? selectedSlotText;
  final String? availableSlotText;
  final String? pauseSlotText;

  final TextStyle? bookedSlotTextStyle;
  final TextStyle? availableSlotTextStyle;
  final TextStyle? selectedSlotTextStyle;

  final ScrollPhysics? gridScrollPhysics;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? uploadingWidget;

  final bool? isMultiSelect;
  final bool? hideBreakTime;
  final DateTime? lastDay;
  final String? locale;
  final bc.StartingDayOfWeek? startingDayOfWeek;
  final List<int>? disabledDays;
  final List<DateTime>? disabledDates;

  final Widget? wholeDayIsBookedWidget;

  final ValueChanged<bool>? onChangedCheckbox;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();

}

class _BookingCalendarMainState extends State<BookingCalendarMain> {

  late BookingController controller;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller = context.read<BookingController>();
    final firstDay = calculateFirstDay();
    startOfDay = firstDay.startOfDayService(controller.serviceOpening!);
    endOfDay = firstDay.endOfDayService(controller.serviceClosing!);
    _focusedDay = firstDay;
    _selectedDay = firstDay;
    controller.selectFirstDayByHoliday(startOfDay, endOfDay);
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay
        .add(const Duration(days: 1))
        .endOfDayService(controller.serviceClosing!);

    controller.base = startOfDay;
    controller.resetSelectedSlot();
  }

  DateTime calculateFirstDay() {
    final now = DateTime.now();
    if (widget.disabledDays != null) {
      return widget.disabledDays!.contains(now.weekday)
          ? now.add(Duration(days: getFirstMissingDay(now.weekday)))
          : now;
    } else {
      return DateTime.now();
    }
  }

  int getFirstMissingDay(int now) {
    for (var i = 1; i <= 7; i++) {
      if (!widget.disabledDays!.contains(now + i)) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();
    return Consumer<BookingController>(
      builder: (_, controller, __) => Padding(
        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width *0.02,
            left: MediaQuery.of(context).size.width *0.02,
            bottom: MediaQuery.of(context).size.height *0.02,
            ),
        child: Column(
                children: [
                  TableCalendar(
                    startingDayOfWeek: widget.startingDayOfWeek?.toTC() ?? tc.StartingDayOfWeek.monday,
                    holidayPredicate: (day) {
                      if (widget.disabledDates == null) return false;

                      bool isHoliday = false;
                      for (var holiday in widget.disabledDates!) {
                        if (isSameDay(day, holiday)) {
                          isHoliday = true;
                        }
                      }
                      return isHoliday;
                    },
                    enabledDayPredicate: (day) {
                      if (widget.disabledDays == null &&
                          widget.disabledDates == null) return true;
                      bool isEnabled = true;
                      if (widget.disabledDates != null) {
                        for (var holiday in widget.disabledDates!) {
                          if (isSameDay(day, holiday)) {
                            isEnabled = false;
                          }
                        }
                        if (!isEnabled) return false;
                      }
                      if (widget.disabledDays != null) {
                        isEnabled =
                            !widget.disabledDays!.contains(day.weekday);
                      }
                      return isEnabled;
                    },
                    locale: widget.locale,
                    firstDay: calculateFirstDay(),
                    lastDay: widget.lastDay ?? DateTime.now().add(const Duration(days: 1000)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    calendarStyle: CalendarStyle(
                        isTodayHighlighted: true,
                        todayTextStyle: TextStyle(color: ColorConstant.blackTextColor),
                        todayDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstant.lightGreenColor
                        ),
                        selectedDecoration: BoxDecoration(
                            color: ColorConstant.mainColor,
                            shape: BoxShape.circle
                        )
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        controller.updateDate(selectedDay);
                        selectNewDateRange();
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  const SizedBox(height: 8),
                  widget.bookingExplanation ?? Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        direction: Axis.horizontal,
                        children: [
                          BookingExplanation(
                              color: widget.availableSlotColor ??
                                  Colors.greenAccent,
                              text: widget.availableSlotText ?? "Available"),
                          BookingExplanation(
                              color: widget.selectedSlotColor ??
                                  Colors.orangeAccent,
                              text: widget.selectedSlotText ?? "Selected"),
                          BookingExplanation(
                              color: widget.bookedSlotColor ?? Colors.redAccent,
                              text: widget.bookedSlotText ?? "Blocked"),
                          if (widget.hideBreakTime != null &&
                              widget.hideBreakTime == false)
                            BookingExplanation(
                                color: widget.pauseSlotColor ?? Colors.grey,
                                text: widget.pauseSlotText ?? "Break"),
                        ],
                      ),
                  SizedBox(height: MediaQuery.of(context).size.height *0.01),
                  BookingCheckbox(
                    onTap: () {
                      if (!controller.isWholeDayBlocked) {
                        controller.isWholeDay();
                      }
                    },
                    checkBoxValue: controller.isWholeDaySelect && !controller.isWholeDayBlocked,
                    checkBoxText: widget.checkBoxTitle ?? "Block whole day",
                    onChanged: (bool? value) {
                      if (!controller.isWholeDayBlocked) {
                        controller.isWholeDay();
                      }
                      if (widget.onChangedCheckbox != null) {
                        widget.onChangedCheckbox!(value ?? false);
                      }
                    },
                    isWholeDayBlocked: controller.isWholeDayBlocked,
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<dynamic>(
                    stream: widget.getBookingStream(start: startOfDay, end: endOfDay),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return widget.errorWidget ??
                            Center(
                              child: Text(snapshot.error.toString()),
                            );
                      }
                      if (!snapshot.hasData) {
                        return widget.loadingWidget ??
                            const Center(child: CircularProgressIndicator());
                      }
                      // Convert snapshot data to List<DateTimeRange>
                      final data = snapshot.requireData;
                      controller.generateBookedSlots(widget.convertStreamResultToDateTimeRanges(streamResult: data));
                      return Expanded(
                        child: (widget.wholeDayIsBookedWidget != null && controller.isWholeDayBooked())
                            ? widget.wholeDayIsBookedWidget!
                            : GridView.builder(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015),
                          physics: widget.gridScrollPhysics ?? const BouncingScrollPhysics(),
                          itemCount: controller.allBookingSlots.length,
                          itemBuilder: (context, index) {
                            TextStyle? getTextStyle() {
                              if (controller.isSlotBooked(index)) {
                                return widget.bookedSlotTextStyle;
                              } else if (controller.listSelectedSlots.contains(index)) {
                                return widget.selectedSlotTextStyle;
                              } else {
                                return widget.availableSlotTextStyle;
                              }
                            }
                            final slot = controller.allBookingSlots.elementAt(index);
                            return BookingSlot(
                              hideBreakSlot: widget.hideBreakTime,
                              pauseSlotColor: widget.pauseSlotColor,
                              availableSlotColor: widget.availableSlotColor,
                              bookedSlotColor: widget.bookedSlotColor,
                              selectedSlotColor: widget.selectedSlotColor,
                              isPauseTime: controller.isSlotInPauseTime(slot),
                              isBooked: controller.isSlotBooked(index),
                              isSelected: controller.listSelectedSlots.contains(index),
                              onTap: () => controller.selectSlot(index, isMultiSelect: widget.isMultiSelect),
                              child: Center(
                                child: Text(
                                  widget.formatDateTime?.call(slot)
                                      ??
                                      '${BookingUtil.formatDateTime(slot)} - ${BookingUtil.formatDateTime(slot.add( Duration(minutes: controller.setSlotDuration())))}',
                                  style: getTextStyle(),
                                ),
                              ),
                            );
                          },
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: MediaQuery.of(context).size.height * 0.015,
                            mainAxisExtent: MediaQuery.of(context).size.height * 0.06,
                            crossAxisSpacing: MediaQuery.of(context).size.height * 0.015,
                            crossAxisCount: widget.bookingGridCrossAxisCount ?? 3,
                            childAspectRatio: widget.bookingGridChildAspectRatio ?? 1.6,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height *0.01,
                  ),
                  CommonButton(
                    text: widget.bookingButtonText ?? 'BOOK',
                    onTap: () async {
                      controller.toggleUploading();
                      final bookings = controller.generateNewBookingsForUploading();
                      try {
                        await Future.wait(bookings.map((booking) =>
                             widget.uploadBooking(newBooking: booking)
                          )
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text("Bookings success"),
                            backgroundColor: ColorConstant.mainColor)
                        );
                      } catch (e) {
                        debugPrint("Error during booking: $e");
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bookings failed"),
                            backgroundColor: Colors.red,));
                      } finally {
                        controller.toggleUploading();
                        controller.resetSelectedSlot();
                      }
                    },
                    isLoading: controller.isUploading,
                    isDisabled: controller.listSelectedSlots.isEmpty,
                    buttonActiveColor: widget.bookingButtonColor,
                ),
             ],
          ),
       ),
    );
  }
}

// CommonButton(
//   text: widget.bookingButtonText ?? 'BOOK',
//   onTap: () async {
//     if (controller.listSelectedSlots.isEmpty) {
//       return;
//     }
//     controller.toggleUploading();
//     final bookings = controller.generateNewBookingsForUploading();
//     for (var booking in bookings) {
//       // debugPrint("booking ${booking}");
//       await widget.uploadBooking(newBooking: booking);
//     }
//     controller.toggleUploading();
//     controller.resetSelectedSlot();
//   },
//   isLoading: (controller.isUploading) ? true : false,
//   isDisabled: controller.listSelectedSlots.isEmpty,
//   buttonActiveColor: widget.bookingButtonColor,
// )
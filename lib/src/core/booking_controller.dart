import 'package:flutter_booking/src/model/booking_service.dart';
import 'package:flutter_booking/src/util/booking_util.dart';
import 'package:flutter/material.dart';

// class BookingController extends ChangeNotifier {
//   BookingService bookingService;
//   BookingController({required this.bookingService, this.pauseSlots}) {
//     serviceOpening = bookingService.bookingStart;
//     serviceClosing = bookingService.bookingEnd;
//     pauseSlots = pauseSlots;
//     if (serviceOpening!.isAfter(serviceClosing!)) {
//       throw "Service closing must be after opening";
//     }
//     base = serviceOpening!;
//     _generateBookingSlots();
//   }
//
//   late DateTime base;
//
//   DateTime? serviceOpening;
//   DateTime? serviceClosing;
//
//   List<DateTime> _allBookingSlots = [];
//   List<DateTime> get allBookingSlots => _allBookingSlots;
//
//   List<DateTimeRange> bookedSlots = [];
//   List<DateTimeRange>? pauseSlots = [];
//
//   int _selectedSlot = (-1);
//   bool _isUploading = false;
//
//   int get selectedSlot => _selectedSlot;
//   bool get isUploading => _isUploading;
//
//   bool _successfullUploaded = false;
//   bool get isSuccessfullUploaded => _successfullUploaded;
//
//   void initBack() {
//     _isUploading = false;
//     _successfullUploaded = false;
//   }
//
//   void selectFirstDayByHoliday(DateTime first, DateTime firstEnd) {
//     serviceOpening = first;
//     serviceClosing = firstEnd;
//     base = first;
//     _generateBookingSlots();
//   }
//
//   void _generateBookingSlots() {
//     allBookingSlots.clear();
//     _allBookingSlots = List.generate(
//         _maxServiceFitInADay(),
//         (index) => base
//             .add(Duration(minutes: bookingService.serviceDuration) * index));
//   }
//
//   bool isWholeDayBooked() {
//     bool isBooked = true;
//     for (var i = 0; i < allBookingSlots.length; i++) {
//       if (!isSlotBooked(i)) {
//         isBooked = false;
//         break;
//       }
//     }
//     return isBooked;
//   }
//
//   int _maxServiceFitInADay() {
//     ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
//     int openingHours = 24;
//     if (serviceOpening != null && serviceClosing != null) {
//       openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!)
//           .duration
//           .inHours;
//     }
//     ///round down if not the whole service would fit in the last hours
//     return ((openingHours * 60) / bookingService.serviceDuration).floor();
//   }
//
//   bool isSlotBooked(int index) {
//     DateTime checkSlot = allBookingSlots.elementAt(index);
//     bool result = false;
//     for (var slot in bookedSlots) {
//       if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
//           checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
//         result = true;
//         break;
//       }
//     }
//     return result;
//   }
//
//   void selectSlot(int idx) {
//     _selectedSlot = idx;
//     notifyListeners();
//   }
//
//   void resetSelectedSlot() {
//     _selectedSlot = -1;
//     notifyListeners();
//   }
//
//   void toggleUploading() {
//     _isUploading = !_isUploading;
//     notifyListeners();
//   }
//
//   Future<void> generateBookedSlots(List<DateTimeRange> data) async {
//     bookedSlots.clear();
//     _generateBookingSlots();
//
//     for (var i = 0; i < data.length; i++) {
//       final item = data[i];
//       bookedSlots.add(item);
//     }
//   }
//
//   BookingService generateNewBookingForUploading() {
//     final bookingDate = allBookingSlots.elementAt(selectedSlot);
//     bookingService
//       ..bookingStart = (bookingDate)
//       ..bookingEnd = (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
//     return bookingService;
//   }
//
//   bool isSlotInPauseTime(DateTime slot) {
//     bool result = false;
//     if (pauseSlots == null) {
//       return result;
//     }
//     for (var pauseSlot in pauseSlots!) {
//       if (BookingUtil.isOverLapping(pauseSlot.start, pauseSlot.end, slot,
//           slot.add(Duration(minutes: bookingService.serviceDuration)))) {
//         result = true;
//         break;
//       }
//     }
//     return result;
//   }
//
// }

class BookingController extends ChangeNotifier {
  BookingService bookingService;
  BookingController({required this.bookingService, this.pauseSlots}) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    pauseSlots = pauseSlots;
    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    base = serviceOpening!;
    _generateBookingSlots();
  }

  late DateTime base;

  late Future<dynamic> Function({required BookingService newBooking})
      uploadBooking;
  DateTime? serviceOpening;
  DateTime? serviceClosing;

  bool _isWholeDaySelect = false;
  bool get isWholeDaySelect => _isWholeDaySelect;

  List<DateTime> _allBookingSlots = [];
  List<DateTime> get allBookingSlots => _allBookingSlots;

  List<DateTimeRange> bookedSlots = [];
  List<DateTimeRange>? pauseSlots = [];

  List<int> _listSelectedSlots = [];
  List<int> get listSelectedSlots => _listSelectedSlots;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  bool _successfullUploaded = false;
  bool get isSuccessfullUploaded => _successfullUploaded;

  void updateDate(DateTime newDate) {
    base = newDate;
    _isWholeDaySelect = false;
    _listSelectedSlots.clear();
    notifyListeners();
  }

  void initBack() {
    _isUploading = false;
    _successfullUploaded = false;
  }

  void selectFirstDayByHoliday(DateTime first, DateTime firstEnd) {
    serviceOpening = first;
    serviceClosing = firstEnd;
    base = first;
    _generateBookingSlots();
  }

  int setSlotDuration() {
    return bookingService.serviceDuration.toInt();
  }

  void _generateBookingSlots() {
    allBookingSlots.clear();
    _allBookingSlots = List.generate(
        _maxServiceFitInADay(),
        (index) => base
            .add(Duration(minutes: bookingService.serviceDuration) * index));
  }

  bool get isWholeDayBlocked {
    return _isWholeDaySelect &&
        _allBookingSlots
            .every((slot) => isSlotBooked(_allBookingSlots.indexOf(slot)));
  }

  bool isWholeDayBooked() {
    return _allBookingSlots
        .every((slot) => isSlotBooked(_allBookingSlots.indexOf(slot)));
  }

  int _maxServiceFitInADay() {
    int openingHours = 24;
    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!)
          .duration
          .inHours;
    }
    return ((openingHours * 60) / bookingService.serviceDuration).floor();
  }

  bool isSlotBooked(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    return bookedSlots.any((slot) => BookingUtil.isOverLapping(
        slot.start,
        slot.end,
        checkSlot,
        checkSlot.add(Duration(minutes: bookingService.serviceDuration))));
  }

  void isWholeDay() {
    _isWholeDaySelect = !_isWholeDaySelect;
    if (_isWholeDaySelect) {
      _listSelectedSlots = List.generate(
        _allBookingSlots.length,
        (index) => index,
      ).where((index) => !isSlotBooked(index)).toList();
    } else {
      _listSelectedSlots.clear();
    }
    notifyListeners();
  }

  void selectSlot(int idx, {bool? isMultiSelect = false}) {
    if (isMultiSelect == true) {
      if (_listSelectedSlots.contains(idx)) {
        _listSelectedSlots.remove(idx);
      } else {
        _listSelectedSlots.add(idx);
      }
    } else {
      _listSelectedSlots
        ..clear()
        ..add(idx);
    }
    notifyListeners();
  }

  void selectMultipleSlots(List<int> indices) {
    _listSelectedSlots = indices;
    notifyListeners();
  }

  void resetSelectedSlot() {
    _listSelectedSlots.clear();
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<DateTimeRange> data) async {
    bookedSlots.clear();
    _generateBookingSlots();
    bookedSlots.addAll(data);
  }

  List<BookingService> generateNewBookingsForUploading() {
    return _listSelectedSlots.map((index) {
      final bookingDate = allBookingSlots.elementAt(index);
      final newBookingService = BookingService(
        bookingStart: bookingDate,
        serviceName: bookingService.serviceName,
        userName: bookingService.userName,
        bookingEnd:
            bookingDate.add(Duration(minutes: bookingService.serviceDuration)),
        serviceDuration: bookingService.serviceDuration,
      );
      return newBookingService;
    }).toList();
  }

  bool isSlotInPauseTime(DateTime slot) {
    if (pauseSlots == null) return false;
    return pauseSlots!.any((pauseSlot) => BookingUtil.isOverLapping(
        pauseSlot.start,
        pauseSlot.end,
        slot,
        slot.add(Duration(minutes: bookingService.serviceDuration))));
  }
}

// void isWholeDay() {
//   _isWholeDaySelect = !_isWholeDaySelect;
//   if (_isWholeDaySelect) {
//     _listSelectedSlots = List.generate(
//       _allBookingSlots.length,
//           (index) => index,
//     ).where((index) => !isSlotBooked(index)).toList();
//   } else {
//     _listSelectedSlots.clear();
//   }
//   notifyListeners();
// }



// void onSlotBookingTap() async {
//   final bookings = generateNewBookingsForUploading();
//   for (var booking in bookings) {
//     // debugPrint("booking ${booking}");
//     await uploadBooking(newBooking: booking);
//   }
// }

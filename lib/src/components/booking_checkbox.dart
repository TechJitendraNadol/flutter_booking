import 'package:flutter/material.dart';
import 'package:flutter_booking/src/util/booking_util.dart';

class BookingCheckbox extends StatelessWidget {
  const BookingCheckbox({
    Key? key,
    this.onTap,
    this.checkBoxValue,
    required this.checkBoxText,
    this.onChanged,
    this.isWholeDayBlocked = false,
  }) : super(key: key);

  final VoidCallback? onTap;
  final bool? checkBoxValue;
  final String checkBoxText;
  final void Function(bool?)? onChanged;
  final bool isWholeDayBlocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isWholeDayBlocked ? null : onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Container(
              width: 20,
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.02),
              alignment: Alignment.centerLeft,
              child: Transform.scale(
                scale: 1.12,
                child: Checkbox(
                  value: checkBoxValue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  side:
                      BorderSide(width: 1, color: ColorConstant.blackTextColor),
                  activeColor: ColorConstant.mainColor,
                  onChanged: isWholeDayBlocked ? null : onChanged,
                ),
              ),
            ),
            Text(
              checkBoxText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

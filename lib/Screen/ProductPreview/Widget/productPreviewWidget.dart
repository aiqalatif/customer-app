import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';

class IOSRundedButton extends StatelessWidget {
  const IOSRundedButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: 39.0,
      start: 11.0,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1a0400ff),
                    offset: Offset(0, 0),
                    blurRadius: 30)
              ],
              color: Theme.of(context).colorScheme.white,
              borderRadius: BorderRadius.circular(circularBorderRadius7),
            ),
            width: 33,
            height: 33,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

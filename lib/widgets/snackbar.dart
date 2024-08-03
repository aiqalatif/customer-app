import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../Helper/Constant.dart';

setSnackbar(String msg, BuildContext context) {
  return showToast(msg,
      fullWidth: true,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.slideToBottom,
      position: StyledToastPosition.bottom,
      animDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      borderRadius: BorderRadius.circular(10.0),
      backgroundColor: Theme.of(context).colorScheme.black.withOpacity(0.8),
      textStyle: TextStyle(color: Theme.of(context).colorScheme.white));
}
/*setSnackbar(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.black,
          fontFamily: 'ubuntu',
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ),
  );
}*/

void showOverlay(
  String msg,
  BuildContext context,
) async {
  // Declaring and Initializing OverlayState
  // and OverlayEntry objects
  OverlayState overlayState = Overlay.of(context);
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      // You can return any widget you like
      // here to be displayed on the Overlay
      return Positioned(
        // left: MediaQuery.of(context).size.width,
        bottom: 0,
        child: Material(
          child: Container(
            color: Theme.of(context).colorScheme.white,
            // height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.black,
                    fontSize: textFontSize14,
                    fontFamily: 'ubuntu',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  // Inserting the OverlayEntry into the Overlay
  overlayState.insert(overlayEntry);

  // Awaiting for 3 seconds
  await Future.delayed(const Duration(seconds: 2)).then(
    (value) {
      overlayEntry.remove();
    },
  );

  // Removing the OverlayEntry from the Overlay
}

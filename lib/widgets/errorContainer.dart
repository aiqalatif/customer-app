import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/cupertino.dart';

class ErrorContainer extends StatelessWidget {
  final String errorMessage;
  final Function onTapRetry;
  final bool? showBackButton;
  const ErrorContainer(
      {Key? key,
      required this.onTapRetry,
      required this.errorMessage,
      this.showBackButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          (showBackButton ?? true)
              ? CupertinoButton(
                  child: Text(getTranslated(context, tryAgainLabelKey)),
                  onPressed: () {
                    onTapRetry.call();
                  })
              : const SizedBox()
        ],
      ),
    );
  }
}

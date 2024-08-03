import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

showSpeechDialog(
    BuildContext context,
    StateSetter setStater,
    bool hasSpeech,
    double level,
    SpeechToText speech,
    String lastWords,
    Function initSpeechState,
    Function startListening) {
  return DesignConfiguration.dialogAnimate(
    context,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setStater1) {
        setStater = setStater1;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.lightWhite,
          title: Text(
            getTranslated(context, 'SEarchHint'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize16,
              fontFamily: 'ubuntu',
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: .26,
                      spreadRadius: level * 1.5,
                      color:
                          Theme.of(context).colorScheme.black.withOpacity(.05),
                    )
                  ],
                  color: Theme.of(context).colorScheme.white,
                  borderRadius: const BorderRadius.all(
                      Radius.circular(circularBorderRadius50)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.mic,
                    color: colors.primary,
                  ),
                  onPressed: () {
                    if (!hasSpeech) {
                      initSpeechState();
                    } else {
                      !hasSpeech || speech.isListening
                          ? null
                          : startListening();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(lastWords),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                child: Center(
                  child: speech.isListening
                      ? Text(
                          getTranslated(context, "I'm listening..."),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ubuntu',
                              ),
                        )
                      : Text(
                          getTranslated(context, 'Not listening'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ubuntu',
                              ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

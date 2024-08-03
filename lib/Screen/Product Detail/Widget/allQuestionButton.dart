import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';
import '../../Language/languageSettings.dart';
import '../../FAQsProduct/FaqsProduct.dart';

class AllQuesBtn extends StatelessWidget {
  String? id;
  AllQuesBtn({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => FaqsProduct(id),
            ),
          );
        },
        child: Row(
          children: [
            Text(
              getTranslated(context, 'See all answered questions'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w400,
                fontFamily: 'Ubuntu',
                fontStyle: FontStyle.normal,
                fontSize: textFontSize14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_right,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}

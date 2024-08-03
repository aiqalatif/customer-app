import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Provider/paymentProvider.dart';
import '../../Language/languageSettings.dart';

class GetBankTransferContent extends StatelessWidget {
  const GetBankTransferContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ext details***${context.read<PaymentProvider>().exDetails!}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
          child: Text(
            getTranslated(context, 'BANKTRAN'),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.lightBlack),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20.0,
            0,
            20.0,
            0,
          ),
          child: Text(getTranslated(context, 'BANK_INS'),
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            getTranslated(context, 'ACC_DETAIL'),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontFamily: 'ubuntu',
                    ),
                children: <TextSpan>[
                  TextSpan(
                      text: '${getTranslated(context, 'ACCNAME')} : ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: context.read<PaymentProvider>().acName!,
                  ),
                ],
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontFamily: 'ubuntu',
                    ),
                children: <TextSpan>[
                  TextSpan(
                      text: '${getTranslated(context, 'ACCNO')} : ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: context.read<PaymentProvider>().acNo!,
                  ),
                ],
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontFamily: 'ubuntu',
                    ),
                children: <TextSpan>[
                  TextSpan(
                      text: '${getTranslated(context, 'BANKNAME')} : ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: context.read<PaymentProvider>().bankName!,
                  ),
                ],
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontFamily: 'ubuntu',
                    ),
                children: <TextSpan>[
                  TextSpan(
                      text: '${getTranslated(context, 'BANKCODE')} : ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: context.read<PaymentProvider>().bankNo!,
                  ),
                ],
              ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            '${getTranslated(context, 'EXTRADETAIL')} : ',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(fontFamily: 'ubuntu', fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: HtmlWidget(
            context.read<PaymentProvider>().exDetails!,
            onTapUrl: (String? url) async {
              url = url.toString().replaceAll('\\', '');
              url = url.replaceAll('"', '');
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
                return true;
              } else {
                throw 'Could not launch $url';
              }
            },
            onErrorBuilder: (context, element, error) =>
                Text('$element error: $error'),
            onLoadingBuilder: (context, element, loadingProgress) =>
                DesignConfiguration.showCircularProgress(
                    true, Theme.of(context).primaryColor),

            renderMode: RenderMode.column,

            // set the default styling for text
            textStyle: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          ),
        ),
      ],
    );
  }
}

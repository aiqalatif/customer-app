import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Provider/customerSupportProvider.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/validation.dart';

class SetTitleWidget extends StatefulWidget {
  const SetTitleWidget({Key? key}) : super(key: key);

  @override
  State<SetTitleWidget> createState() => _SetTitleWidgetState();
}

class _SetTitleWidgetState extends State<SetTitleWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        focusNode: context.read<CustomerSupportProvider>().nameFocus,
        textInputAction: TextInputAction.next,
        controller: context.read<CustomerSupportProvider>().nameController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => StringValidation.validateField(
            val!, getTranslated(context, 'FIELD_REQUIRED')),
        onSaved: (String? value) {
          context.read<CustomerSupportProvider>().title = value;
        },
        onFieldSubmitted: (v) {
          fieldFocusChange(
              context,
              context.read<CustomerSupportProvider>().emailFocus!,
              context.read<CustomerSupportProvider>().nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'TITLE'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
        ),
      ),
    );
  }
}

fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

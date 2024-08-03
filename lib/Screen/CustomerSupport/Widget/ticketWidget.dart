import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/customerSupportProvider.dart';
import '../../Language/languageSettings.dart';

// ignore: must_be_immutable
class TicketIteamWidget extends StatefulWidget {
  int index;
  Function updateNow;
  TicketIteamWidget({Key? key, required this.index, required this.updateNow})
      : super(key: key);

  @override
  State<TicketIteamWidget> createState() => _TicketIteamWidgetState();
}

class _TicketIteamWidgetState extends State<TicketIteamWidget> {
  @override
  Widget build(BuildContext context) {
    Color back;
    String? status =
        context.read<CustomerSupportProvider>().ticketList[widget.index].status;
    //1 -> pending, 2 -> opened, 3 -> resolved, 4 -> closed, 5 -> reopened
    if (status == '1') {
      back = Colors.orange;
      status = 'Pending';
    } else if (status == '2') {
      back = Colors.cyan;
      status = 'Opened';
    } else if (status == '3') {
      back = Colors.green;
      status = 'Resolved';
    } else if (status == '5') {
      back = Colors.cyan;
      status = 'Reopen';
    } else {
      back = Colors.red;
      status = 'Close';
    }
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          Routes.navigateToChatScreen(
            context,
            context.read<CustomerSupportProvider>().ticketList[widget.index].id,
            context
                .read<CustomerSupportProvider>()
                .ticketList[widget.index]
                .status,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${getTranslated(context, 'Type')} : ${context.read<CustomerSupportProvider>().ticketList[widget.index].type!}',
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 2,
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: back,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius4),
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.white,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  )
                ],
              ),
              Text(
                '${getTranslated(context, 'TITLE')} : ${context.read<CustomerSupportProvider>().ticketList[widget.index].title!}',
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
              Text(
                '${getTranslated(context, 'DESCRIPTION')} : ${context.read<CustomerSupportProvider>().ticketList[widget.index].desc!}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
              Text(
                '${getTranslated(context, 'DATE')} : ${context.read<CustomerSupportProvider>().ticketList[widget.index].date!}',
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.lightWhite,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(circularBorderRadius4),
                          ),
                        ),
                        child: Text(
                          getTranslated(context, 'EDIT'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontSize: textFontSize11,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                      ),
                      onTap: () {
                        context.read<CustomerSupportProvider>().edit = true;
                        context.read<CustomerSupportProvider>().show = true;
                        context.read<CustomerSupportProvider>().curEdit =
                            widget.index;
                        context.read<CustomerSupportProvider>().id = context
                            .read<CustomerSupportProvider>()
                            .ticketList[widget.index]
                            .id;
                        context
                                .read<CustomerSupportProvider>()
                                .emailController
                                .text =
                            context
                                .read<CustomerSupportProvider>()
                                .ticketList[widget.index]
                                .email!;
                        context
                                .read<CustomerSupportProvider>()
                                .nameController
                                .text =
                            context
                                .read<CustomerSupportProvider>()
                                .ticketList[widget.index]
                                .title!;
                        context
                                .read<CustomerSupportProvider>()
                                .descController
                                .text =
                            context
                                .read<CustomerSupportProvider>()
                                .ticketList[widget.index]
                                .desc!;
                        context.read<CustomerSupportProvider>().type = context
                            .read<CustomerSupportProvider>()
                            .ticketList[widget.index]
                            .typeId;

                        widget.updateNow();
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.lightWhite,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(
                              circularBorderRadius4,
                            ),
                          ),
                        ),
                        child: Text(
                          getTranslated(context, 'CHAT'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontSize: textFontSize11,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                      ),
                      onTap: () {
                        Routes.navigateToChatScreen(
                          context,
                          context
                              .read<CustomerSupportProvider>()
                              .ticketList[widget.index]
                              .id,
                          context
                              .read<CustomerSupportProvider>()
                              .ticketList[widget.index]
                              .status,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

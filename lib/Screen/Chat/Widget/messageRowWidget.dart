import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/chatProvider.dart';

// ignore: must_be_immutable
class MessageRow extends StatefulWidget {
  String? status;
  Function update;
  String? id;
  MessageRow({
    Key? key,
    required this.update,
    required this.id,
    required this.status,
  }) : super(key: key);

  @override
  State<MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  List<PlatformFile> files = [];
  _imgFromGallery(BuildContext context) async {
    bool storagePermissionGiven = await hasStoragePermissionGiven();
    if (storagePermissionGiven) {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        if (result.count > 5) {
          setSnackbar('Can not select more than 5 files', context);
          return;
        }
        double fileSizes = 0.0;
        for (var element in result.files) {
          fileSizes = fileSizes + element.size;
        }
        if ((fileSizes / 1000000) > allowableTotalFileSizesInChatMediaInMB) {
          setSnackbar(
              'Total allowable attachement size is $allowableTotalFileSizesInChatMediaInMB MB',
              context);

          return;
        }
        files.addAll(result.files);
        context.read<ChatProvider>().files = files;
        // result.paths.map((path) => File(path!)).toList();
        widget.update();
      }
    } else {
      setSnackbar('Please give storage permission', context);
    }
  }

  Widget _buildAttachments() {
    return files.isEmpty
        ? const SizedBox()
        : Container(
            width: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).colorScheme.secondary))),
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children:
                  List.generate(files.length, (index) => index).map((index) {
                final file = files[index];
                return ListTile(
                  trailing: IconButton(
                      onPressed: () {
                        files.removeAt(index);
                        widget.update;
                      },
                      icon: const Icon(Icons.close)),
                  dense: true,
                  title: Text(file.name),
                );
              }).toList(),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return widget.status != '4'
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              color: Theme.of(context).colorScheme.white,
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _imgFromGallery(context);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius:
                            BorderRadius.circular(circularBorderRadius30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  files.isNotEmpty
                      ? _buildAttachments()
                      : Expanded(
                          child: TextField(
                            controller:
                                context.read<ChatProvider>().msgController,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText:
                                  getTranslated(context, 'Write message...'),
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                  files.isNotEmpty
                      ? const SizedBox()
                      : const SizedBox(
                          width: 15,
                        ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (!context.read<ChatProvider>().isProgress) {
                        if (context
                                .read<ChatProvider>()
                                .msgController
                                .text
                                .trim()
                                .isNotEmpty ||
                            files.isNotEmpty) {
                              context.read<ChatProvider>().isProgress = true;
                          context.read<ChatProvider>().sendMessage(
                                context
                                    .read<ChatProvider>()
                                    .msgController
                                    .text
                                    .trim(),
                                context,
                                widget.update,
                                widget.id,
                              );
                          context.read<ChatProvider>().getMsg(
                                context,
                                widget.id,
                                widget.update,
                              );
                          
                        }
                      }
                    },
                    backgroundColor: colors.primary,
                    elevation: 0,
                    child: context.read<ChatProvider>().isProgress
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.white,
                              strokeWidth: 1.5,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.white,
                            size: 18,
                          ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}

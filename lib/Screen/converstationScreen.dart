// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/groupDetails.dart';
import 'package:eshop_multivendor/Model/mediaFile.dart';
import 'package:eshop_multivendor/Model/message.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/cubits/converstationCubit.dart';
import 'package:eshop_multivendor/cubits/downloadFileCubit.dart';
import 'package:eshop_multivendor/cubits/personalConverstationsCubit.dart';
import 'package:eshop_multivendor/cubits/sendMessageCubit.dart';
import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:eshop_multivendor/repository/downloadRepository.dart';
import 'package:eshop_multivendor/widgets/downloadFileDialog.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class ConverstationScreen extends StatefulWidget {
  final PersonalChatHistory? personalChatHistory;
  final GroupDetails? groupDetails;
  final bool isGroup;

  const ConverstationScreen(
      {Key? key,
      this.personalChatHistory,
      required this.isGroup,
      this.groupDetails})
      : super(key: key);

  @override
  State<ConverstationScreen> createState() => ConverstationScreenState();
}

class ConverstationScreenState extends State<ConverstationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_scrollListener);

  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;

  List<PlatformFile> files = [];

  void _scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<ConverstationCubit>().hasMore()) {
        context.read<ConverstationCubit>().fetchMore(
            toId: context.read<UserProvider>().userId!,
            isGroup: widget.isGroup,
            fromUserId: widget.isGroup
                ? widget.groupDetails?.groupId ?? '0'
                : widget.personalChatHistory?.getOtherUserId() ?? '');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );

    Future.delayed(Duration.zero, () {
      context.read<ConverstationCubit>().fetchConverstation(
          toId: context.read<UserProvider>().userId!,
          isGroup: widget.isGroup,
          fromUserId: widget.isGroup
              ? widget.groupDetails?.groupId ?? '0'
              : widget.personalChatHistory?.getOtherUserId() ?? '');

      //Read messages
      if (widget.isGroup) {
        //Update group converstion
        // ChatRepository.readMessages(
        //     isGroup: widget.isGroup,
        //     fromId: widget.isGroup
        //         ? widget.groupDetails?.groupId ?? '0'
        //         : widget.personalChatHistory?.id ?? '0',
        //     userId: context.read<UserProvider>().userId!);
        // context
        //     .read<GroupConverstationsCubit>()
        //     .markMessagesReadOfGivenGroup(groupId: widget.groupDetails?.groupId);
      } else {
        if (widget.personalChatHistory?.getUnreadMessage(
                userId: context.read<UserProvider>().userId!) !=
            '0') {
          ChatRepository.readMessages(
              isGroup: widget.isGroup,
              fromId: widget.personalChatHistory?.getOtherUserId() ?? '',
              userId: context.read<UserProvider>().userId!);
          context.read<PersonalConverstationsCubit>().updatePersonalChatHistory(
              personalChatHistory:
                  widget.personalChatHistory!.copyWith(unreadMsg: '0'));
        }
      }
    });
  }

  @override
  void dispose() {
    buttonController.dispose();
    _textEditingController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void addMessage({required Message message}) {
    context.read<ConverstationCubit>().addMessage(message: message);
  }

  void addAttachment() async {
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
        setState(() {});
      }
    } else {
      setSnackbar('Please give storage permission', context);
    }
  }

  void openAttachment(
      {required MediaFile mediaFile,
      required bool downloadedInExternalStorage}) async {
    final fileExistWithPath = await checkIfFileAlreadyDownloaded(
        fileName: '${mediaFile.originalFileName}_${mediaFile.id}',
        fileExtension: mediaFile.fileExtension ?? '',
        downloadedInExternalStorage: downloadedInExternalStorage);

    if (fileExistWithPath.isNotEmpty) {
      OpenFilex.open(fileExistWithPath);
      return;
    }

    showDialog(
        context: context,
        builder: (_) => BlocProvider(
              create: (context) => DownloadFileCubit(DownloadRepository()),
              child: DownloadFileDialog(
                  fileExtension: mediaFile.fileExtension ?? '',
                  fileName: '${mediaFile.originalFileName}_${mediaFile.id}',
                  fileUrl: mediaFile.fileUrl ?? '',
                  storeInExternalStorage: downloadedInExternalStorage),
            ));
  }

  Widget _buildAttachments() {
    return files.isEmpty
        ? const SizedBox()
        : Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).colorScheme.secondary))),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              children:
                  List.generate(files.length, (index) => index).map((index) {
                final file = files[index];
                return ListTile(
                  trailing: IconButton(
                      onPressed: () {
                        if (context.read<SendMessageCubit>().state
                            is SendMessageInProgress) {
                          return;
                        }
                        files.removeAt(index);
                        setState(() {});
                      },
                      icon: const Icon(Icons.close)),
                  dense: true,
                  leading: const Icon(Icons.file_copy),
                  title: Text(file.name),
                );
              }).toList(),
            ),
          );
  }

  Widget _buildGroupInfoButton() {
    return IconButton(
        onPressed: () {
          Routes.navigateToGroupInfoScreen(context, widget.groupDetails!);
        },
        icon: const Icon(
          Icons.info,
          color: Colors.black,
        ));
  }

  Widget _buildSendMessageTextField() {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (0.25)),
      decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
              top: BorderSide(color: Theme.of(context).colorScheme.secondary)),
          color: Theme.of(context).colorScheme.white),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                if (context.read<SendMessageCubit>().state
                    is SendMessageInProgress) {
                  return;
                }
                addAttachment();
              },
              icon: const Icon(Icons.attachment)),
          Expanded(
            child: TextField(
              controller: _textEditingController,
              maxLines: null,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: 15.0),
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Send message'),
            ),
          ),
          BlocConsumer<SendMessageCubit, SendMessageState>(
            listener: (context, state) {
              if (state is SendMessageSuccess) {
                if (context.read<ConverstationCubit>().getMessages().isEmpty) {
                  context
                      .read<PersonalConverstationsCubit>()
                      .fetchConverstations(
                          currentUserId: context.read<UserProvider>().userId!);
                }
                FocusScope.of(context).unfocus();

                context
                    .read<ConverstationCubit>()
                    .addMessage(message: state.message);
                _textEditingController.clear();
                files.clear();
                setState(() {});
              } else if (state is SendMessageFailure) {
                FocusScope.of(context).unfocus();
                setSnackbar(state.errorMessage, context);
              }
            },
            builder: (context, state) {
              return IconButton(
                  onPressed: () {
                    if (state is SendMessageInProgress) {
                      return;
                    }
                    if (_textEditingController.text.trim().isEmpty &&
                        files.isEmpty) {
                      return;
                    }

                    context.read<SendMessageCubit>().sendMessage(
                        fromId: context.read<UserProvider>().userId!,
                        filePaths: files.map((e) => e.path!).toList(),
                        isGroup: widget.isGroup,
                        toUserId: widget.isGroup
                            ? widget.groupDetails?.groupId ?? '0'
                            : widget.personalChatHistory!.getOtherUserId(),
                        message: _textEditingController.text.trim());
                  },
                  icon: state is SendMessageInProgress
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                          ),
                        )
                      : const Icon(Icons.send));
            },
          )
        ],
      ),
    );
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        actions: [
          widget.isGroup ? _buildGroupInfoButton() : const SizedBox(),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(circularBorderRadius4),
                onTap: () {
                  Navigator.of(context).pop(context);
                } ,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        title: ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(
            widget.isGroup
                ? widget.groupDetails?.title ?? ''
                : widget.personalChatHistory?.opponentUsername ?? '',
            style: TextStyle(color: Theme.of(context).colorScheme.lightBlack),
          ),
          leading:
              (widget.isGroup ? '' : widget.personalChatHistory?.image ?? '')
                      .isEmpty
                  ? Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : SizedBox(
                      height: 25,
                      width: 25,
                      child: CachedNetworkImage(
                        imageUrl: widget.isGroup
                            ? ''
                            : widget.personalChatHistory!.image!,
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    ),
        ),
      ),
      body: BlocBuilder<ConverstationCubit, ConverstationState>(
        builder: (context, state) {
          if (state is ConverstationFetchSuccess) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: ListView(
                      controller: _scrollController,
                      reverse: true,
                      children: context
                          .read<ConverstationCubit>()
                          .getMessageDates()
                          .map((date) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.5),
                                      color:
                                          Theme.of(context).colorScheme.white),
                                  padding: const EdgeInsets.all(10),
                                  child: Text(isSameDay(
                                          dateTime: DateTime.parse(date),
                                          takeCurrentDate: true)
                                      ? getTranslated(context, 'TODAY')
                                      : formatDate(DateTime.parse(date)))),
                            ),
                            //
                            ...List.generate(
                                context
                                    .read<ConverstationCubit>()
                                    .getMessagesByDate(dateTime: date)
                                    .length, (index) {
                              //Get the message
                              final message = context
                                  .read<ConverstationCubit>()
                                  .getMessagesByDate(dateTime: date)[index];

                              //Convert message date into local
                              final messageDate = DateTime.parse(
                                  DateTime.parse(message.dateCreated!)
                                      .toLocal()
                                      .toString());

                              bool showProfileAndTime = true;

                              if ((index - 1) >= 0) {
                                final previousMessage = context
                                    .read<ConverstationCubit>()
                                    .getMessagesByDate(
                                        dateTime: date)[index - 1];
                                final previousMessageDateTime = DateTime.parse(
                                    DateTime.parse(previousMessage.dateCreated!)
                                        .toLocal()
                                        .toString());

                                //If the previous messgae is send by same user and falls in a same minute as current message
                                // then do not show the profile and time details
                                if (previousMessage.fromId == message.fromId &&
                                    TimeOfDay(
                                                hour: messageDate.hour,
                                                minute: messageDate.minute)
                                            .format(context) ==
                                        TimeOfDay(
                                                hour: previousMessageDateTime
                                                    .hour,
                                                minute: previousMessageDateTime
                                                    .minute)
                                            .format(context)) {
                                  showProfileAndTime = false;
                                }
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    showProfileAndTime
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${message.sendersName}',
                                                style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                TimeOfDay(
                                                        hour: messageDate.hour,
                                                        minute:
                                                            messageDate.minute)
                                                    .format(context),
                                                style: const TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    //hide message which is with a file
                                    (message.message ?? '')
                                                .toString()
                                                .isEmpty ||
                                            (message.mediaFiles?.isNotEmpty ??
                                                false)
                                        ? const SizedBox()
                                        : Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: showProfileAndTime
                                                    ? 7.5
                                                    : 5.0),
                                            child: Text(
                                              message.message!,
                                              style: const TextStyle(
                                                  fontSize: 15.0),
                                            ),
                                          ),
                                    message.mediaFiles?.isEmpty ?? true
                                        ? const SizedBox()
                                        : Column(
                                            children: message.mediaFiles!
                                                .map((mediaFile) => Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 7.5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      7.5)),
                                                      child: ListTile(
                                                        onTap: () async {
                                                          openAttachment(
                                                              mediaFile:
                                                                  mediaFile,
                                                              downloadedInExternalStorage:
                                                                  false);
                                                        },
                                                        dense: true,
                                                        leading: const Icon(
                                                            Icons.file_copy),
                                                        title: Text(
                                                          mediaFile
                                                                  .originalFileName ??
                                                              '',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .lightBlack,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        horizontalTitleGap: 0,
                                                        trailing: IconButton(
                                                            onPressed: () {
                                                              openAttachment(
                                                                  mediaFile:
                                                                      mediaFile,
                                                                  downloadedInExternalStorage:
                                                                      true);
                                                            },
                                                            icon: const Icon(
                                                                Icons
                                                                    .download)),
                                                      ),
                                                    ))
                                                .toList(),
                                          )
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    )),
                    _buildAttachments(),
                    _buildSendMessageTextField(),
                  ],
                ),
                state.fetchMoreInProgress
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context)
                                  .colorScheme
                                  .white
                                  .withOpacity(0.9)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            getTranslated(context, 'LOADING_OLD_MESSAGES'),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            );
          }
          if (state is ConverstationFetchFailure) {
            if (state.errorMessage == 'No Internet connection') {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: NoInterNet(
                      buttonController: buttonController,
                      buttonSqueezeanimation: buttonSqueezeanimation,
                      setStateNoInternate: () {
                        buttonController.forward().then((value) {
                          buttonController.value = 0;
                          context.read<ConverstationCubit>().fetchConverstation(
                              toId: context.read<UserProvider>().userId!,
                              isGroup: widget.isGroup,
                              fromUserId: widget.isGroup
                                  ? widget.groupDetails?.groupId ?? '0'
                                  : widget.personalChatHistory
                                          ?.getOtherUserId() ??
                                      '');
                        });
                      }),
                ),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage),
                    const SizedBox(
                      height: 10,
                    ),
                    CupertinoButton(
                        child: Text(getTranslated(context, tryAgainLabelKey)),
                        onPressed: () {
                          context.read<ConverstationCubit>().fetchConverstation(
                              toId: context.read<UserProvider>().userId!,
                              isGroup: widget.isGroup,
                              fromUserId: widget.isGroup
                                  ? widget.groupDetails?.groupId ?? '0'
                                  : widget.personalChatHistory
                                          ?.getOtherUserId() ??
                                      '');
                        })
                  ],
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}

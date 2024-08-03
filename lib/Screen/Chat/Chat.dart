import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Model/Model.dart';
import '../../Provider/chatProvider.dart';
import '../../widgets/appBar.dart';
import '../Language/languageSettings.dart';
import 'Widget/MessageIteam.dart';
import 'Widget/messageRowWidget.dart';

class Chat extends StatefulWidget {
  final String? id, status;

  const Chat({Key? key, this.id, this.status}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>().externalStorageDirectories =
        getExternalStorageDirectories(type: StorageDirectory.downloads);
    context.read<ChatProvider>().downloadlist = <String?, String>{};
    CUR_TICK_ID = widget.id;
    FlutterDownloader.registerCallback(downloadCallback);
    setupChannel();
   
    context.read<ChatProvider>().getMsg(
          context,
          widget.id,
          setStateNow,
        );
    Timer.periodic(
      const Duration(seconds: 10),
      (Timer t) => context.read<ChatProvider>().getMsg(
            context,
            widget.id,
            setStateNow,
          ),
    );
  }

  @override
  void dispose() {
    CUR_TICK_ID = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (context.read<ChatProvider>().chatstreamdata != null) {
      context.read<ChatProvider>().chatstreamdata!.sink.close();
    }
      }
    });
    

    super.dispose();
  }

  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'CHAT'), context),
      body: Column(
        children: <Widget>[
          buildListMessage(),
          MessageRow(
            update: setStateNow,
            id: widget.id,
            status: widget.status,
          )
        ],
      ),
    );
  }

  void setupChannel() {
    context.read<ChatProvider>().chatstreamdata = StreamController<String>();
    context.read<ChatProvider>().chatstreamdata!.stream.listen(
      (response) {
        setState(
          () {
            final res = json.decode(response);
            Model message;
            message = Model.fromChat(res['data']);

            context.read<ChatProvider>().chatList.insert(0, message);
            context.read<ChatProvider>().files.clear();
          },
        );
      },
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, index) => MessageIteam(
          index: index,
        ),
        itemCount: context.read<ChatProvider>().chatList.length,
        reverse: true,
        controller: context.read<ChatProvider>().scrollController,
      ),
    );
  }
}

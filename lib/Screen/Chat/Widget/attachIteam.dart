import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Model.dart';
import '../../../Provider/chatProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';

// ignore: must_be_immutable
class AttachIteam extends StatefulWidget {
  List<attachment> attach;
  Model message;
  int index;
  AttachIteam({
    Key? key,
    required this.attach,
    required this.message,
    required this.index,
  }) : super(key: key);

  @override
  State<AttachIteam> createState() => _AttachIteamState();
}

class _AttachIteamState extends State<AttachIteam> {
  void _requestDownload(
      String? url, String? mid, AsyncSnapshot snapshot) async {
    bool checkpermission = await Checkpermission(snapshot);
    if (checkpermission) {
      if (Platform.isIOS) {
        Directory target = await getApplicationDocumentsDirectory();
        context.read<ChatProvider>().filePath = target.path.toString();
      } else {
        if (snapshot.hasData) {
          context.read<ChatProvider>().filePath =
              snapshot.data!.map((Directory d) => d.path).join(', ');
        }
      }

      String fileName = url!.substring(url.lastIndexOf('/') + 1);
      File file = File('${context.read<ChatProvider>().filePath}/$fileName');
      bool hasExisted = await file.exists();

      if (context.read<ChatProvider>().downloadlist.containsKey(mid)) {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query:
                'SELECT status FROM task WHERE task_id=${context.read<ChatProvider>().downloadlist[mid]}');

        if (tasks == 4 || tasks == 5) {
          context.read<ChatProvider>().downloadlist.remove(mid);
        }
      }

      if (hasExisted) {
      } else if (context.read<ChatProvider>().downloadlist.containsKey(mid)) {
        setSnackbar(getTranslated(context, 'Downloading'), context);
      } else {
        setSnackbar(getTranslated(context, 'Downloading'), context);
        final taskid = await FlutterDownloader.enqueue(
            url: url,
            savedDir: context.read<ChatProvider>().filePath,
            headers: {'auth': 'test_for_sql_encoding'},
            showNotification: true,
            openFileFromNotification: true);
        setState(
          () {
            context.read<ChatProvider>().downloadlist[mid] = taskid.toString();
          },
        );
      }
    }
  }

  Future<bool> Checkpermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        FileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      FileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> FileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      context.read<ChatProvider>().filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        context.read<ChatProvider>().filePath =
            snapshot.data!.map((Directory d) => d.path).join(', ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? file = widget.attach[widget.index].media;
    String? type = widget.attach[widget.index].type;
    String icon;
    if (type == 'video') {
      icon = 'video';
    } else if (type == 'document') {
      icon = 'doc';
    } else if (type == 'spreadsheet') {
      icon = 'sheet';
    } else {
      icon = 'zip';
    }
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder<List<Directory>?>(
      future: context.read<ChatProvider>().externalStorageDirectories,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return file == null
            ? const SizedBox()
            : Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  Card(
                    elevation: 0.0,
                    color: widget.message.uid == userProvider.userId
                        ? Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.1)
                        : Theme.of(context).colorScheme.white,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment:
                            widget.message.uid == userProvider.userId
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              _requestDownload(
                                  widget.attach[widget.index].media,
                                  widget.message.id,
                                  snapshot);
                            },
                            child: type == 'image'
                                ? Image.network(file,
                                    width: 250,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            DesignConfiguration.erroWidget(150))
                                : SvgPicture.asset(
                                    DesignConfiguration.setSvgPath(icon),
                                    width: 100,
                                    height: 100,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        widget.message.date!,
                        style: TextStyle(
                          fontFamily: 'ubuntu',
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontSize: textFontSize9,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}

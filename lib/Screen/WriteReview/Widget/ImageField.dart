import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Provider/writeReviewProvider.dart';
import '../../Language/languageSettings.dart';

Widget getImageField() {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding: const EdgeInsetsDirectional.only(
          start: 20.0,
          end: 20.0,
          top: 5,
        ),
        height: 100,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 8.0,
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius:
                          BorderRadius.circular(circularBorderRadius50),
                    ),
                    child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          _reviewImgFromGallery(setModalState, context);
                        }),
                  ),
                  Text(
                    getTranslated(context, 'ADD_YOUR_PHOTOS'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: textFontSize11,
                      fontFamily: 'ubuntu',
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    context.read<WriteReviewProvider>().reviewPhotos.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  return InkWell(
                    child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Image.file(
                          context
                              .read<WriteReviewProvider>()
                              .getReviewPhotoatindex(i),
                          width: 100,
                          height: 100,
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.black26,
                          child: const Icon(
                            Icons.clear,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setModalState(
                        () {
                          context
                              .read<WriteReviewProvider>()
                              .reviewPhotos
                              .removeAt(i);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _reviewImgFromGallery(
    StateSetter setModalState, BuildContext context) async {
  var result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    allowMultiple: true,
  );
  if (result != null) {
    context
        .read<WriteReviewProvider>()
        .setreviewPhotos(result.paths.map((path) => File(path!)).toList());
    setModalState(() {});
  } else {
    // User canceled the picker
  }
}

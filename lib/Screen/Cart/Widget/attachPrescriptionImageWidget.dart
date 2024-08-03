import 'dart:io';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../Language/languageSettings.dart';

// ignore: must_be_immutable
class AttachPrescriptionImages extends StatelessWidget {
  List<SectionModel> cartList;
  AttachPrescriptionImages({Key? key, required this.cartList})
      : super(key: key);

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
        context.read<CartProvider>().checkoutState!(() {
        context.read<CartProvider>().setprescriptionImages(
            result.paths.map((path) => File(path!)).toList());
      });
        // files.addAll(result.files);
        // context.read<ChatProvider>().files = files;
          // result.paths.map((path) => File(path!)).toList();
      // widget.update();
      }
    } else {
      setSnackbar('Please give storage permission', context);
    }
    // var result = await FilePicker.platform
    //     .pickFiles(allowMultiple: true, type: FileType.image);
    // if (result != null) {
    //   // ignore: use_build_context_synchronously
    //   context.read<CartProvider>().checkoutState!(() {
    //     context.read<CartProvider>().setprescriptionImages(
    //         result.paths.map((path) => File(path!)).toList());
    //   });
    // } else {
    //   // User canceled the picker
    // }
  }

  @override
  Widget build(BuildContext context) {
    bool isAttachReq = false;
    for (int i = 0; i < cartList.length; i++) {
      if (cartList[i].productList![0].is_attch_req == '1') {
        isAttachReq = true;
      }
    }

    

    return isAttachReq
        ? Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'ADD_ATT_REQ'),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.lightBlack,
                              fontFamily: 'ubuntu',
                            ),
                      ),
                      SizedBox(
                        height: 30,
                        child: IconButton(
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              color: colors.primary,
                              size: 20.0,
                            ),
                            onPressed: () {
                              _imgFromGallery(context);
                            }),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.only(
                        start: 20.0, end: 20.0, top: 5),
                    height: context
                            .read<CartProvider>()
                            .prescriptionImages
                            .isNotEmpty
                        ? 180
                        : 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: context
                                .read<CartProvider>()
                                .prescriptionImages
                                .length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return InkWell(
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Image.file(
                                      context
                                          .read<CartProvider>()
                                          .prescriptionImages[i],
                                      width: 180,
                                      height: 180,
                                    ),
                                    Container(
                                      color:
                                          Theme.of(context).colorScheme.black26,
                                      child: const Icon(
                                        Icons.clear,
                                        size: 15,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  context.read<CartProvider>().checkoutState!(
                                    () {
                                      context
                                          .read<CartProvider>()
                                          .prescriptionImages
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
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}

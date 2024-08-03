import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/addressProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/User.dart';
import '../../Language/languageSettings.dart';

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  final int index;
  const RadioItem(this._item, {Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _item.addItem!.isDefault == '1'
          ? Theme.of(context).colorScheme.white
          : Theme.of(context).disabledColor.withOpacity(0.1),
      elevation: _item.addItem!.isDefault == '1' ? 5 : 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                _item.show
                    ? Container(
                        height: 20.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: 
                          // _item.isSelected!
                              index == Provider.of<AddressProvider>(context, listen: false).getaddresscheck
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          border: Border.all(
                            color: colors.primary,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: 
                          // _item.isSelected!
                          index == Provider.of<AddressProvider>(context, listen: false).getaddresscheck
                              ? const Icon(
                                  Icons.check,
                                  size: 15.0,
                                  color: colors.whiteTemp,
                                )
                              : Icon(
                                  Icons.circle,
                                  size: 15.0,
                                  color: Theme.of(context).colorScheme.white,
                                ),
                        ),
                      )
                    : const SizedBox(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(start: 10.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _item.onSetDefault!();
                          },
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_item.name!},',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'ubuntu',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _item.mobile!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'ubuntu',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  _item.add!,
                                  style: const TextStyle(
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _item.onEditSelected!();
                              },
                              child: Text(
                                getTranslated(context, 'EDIT'),
                                style: const TextStyle(
                                  color: colors.primary,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ),
                            const VerticalDivider(thickness: 5),
                            GestureDetector(
                              onTap: () {
                                _item.onDeleteSelected!();
                              },
                              child: Text(
                                getTranslated(context, 'DELETE'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: colors.primary,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadioModel {
  bool? isSelected;
  final String? add;
  final String? mobile;
  final String? name;
  final User? addItem;
  final VoidCallback? onEditSelected;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onSetDefault;
  final show;

  RadioModel({
    this.isSelected,
    this.name,
    this.mobile,
    this.add,
    this.addItem,
    this.onEditSelected,
    this.onSetDefault,
    this.show,
    this.onDeleteSelected,
  });
}

import 'package:flutter/material.dart';
import 'package:eosio_port_mobile_app/screen/theme.dart';
import 'package:flutter/services.dart';
import 'package:eosio_port_mobile_app/screen/flushbar.dart';
import 'package:bloc/bloc.dart';

class CardItem {
  String _itemTitle;
  String? _item;

  CardItem(this._itemTitle, this._item);

  bool isValidItem () => this._item != null;

  String getItem() {
    if (_item != null)
      return this._item!;
    else
      throw Exception("CardItem.getItem is null");
  }
  String get itemTitle => _itemTitle;
}

class CustomCard extends StatefulWidget {
  String title;
  List<CardItem> items;
  bool copyToClipboard;

  CustomCard(this.title, this.items,
      [this.copyToClipboard = false]);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  _CustomCardState();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0.0,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 14.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  widget.title,
                  style: TextStyle(
                      color: AndroidThemeST()
                          .getValues()
                          .themeValues["CUSTOM_CARD"]["COLOR_TEXT"]),
                ))),
        const SizedBox(height: 20),
        GestureDetector(
            onTap: () {
              if (! widget.copyToClipboard)
                return;

              String text = "";
              for (CardItem element in widget.items) {
                text = text + element.itemTitle + " ";
                if (element.isValidItem())
                  text = text + element.getItem()  + " ";
                text = text + "\n";
              }
              showFlushbar(context, "Clipboard", "Item was copied to clipboard.", Icons.info);
              Clipboard.setData(ClipboardData(text: text));
            },
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                elevation: 0.0, //no shadow
                margin: EdgeInsets.symmetric(horizontal: 0.0),
                child: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          for (CardItem element in widget.items)
                            Row(children: <Widget>[
                              Expanded(
                                  child: Text(
                                element.itemTitle,
                                style: TextStyle(fontSize: 15),
                              )),
                              if (element.isValidItem())
                                Expanded(
                                    child: Text(element.getItem(),
                                        style: TextStyle(fontSize: 15)))
                            ]),
                        ])))),
      ],
    );
  }
}

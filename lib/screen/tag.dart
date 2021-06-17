import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';


class CustomTag extends StatefulWidget {
  late Key key;
  late List items;
  CustomTag({required this.key, required this.items});

  @override
  _CustomTagState createState() => _CustomTagState(key: this.key, items:this.items);
}

class _CustomTagState extends State<CustomTag> {
  late Key _key;
  late List _items;
  late double _fontSize = 14;

  _CustomTagState({required Key key, required List items}){
    this._key = key;
    this._items = items;
}

  @override
  Widget build(BuildContext context) {
    return Tags(
      key: this._key,

      textField: TagsTextField(
        textStyle: TextStyle(fontSize: _fontSize),
        constraintSuggestion: true, suggestions: [],
        onSubmitted: (String str) {
          // Add item to the data source.
          setState(() {
            // required
            _items.add(str);
          });
        },
      ),
      itemCount: _items.length, // required
      itemBuilder: (int index) {
        final item = _items[index];

        return ItemTags(
          // Each ItemTags must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(index.toString()),
          index: index,
          // required
          title: "t",//item.title,
          active: true, //item.active,
          customData: "som", //item.customData,
          textStyle: TextStyle(fontSize: _fontSize,),
          combine: ItemTagsCombine.withTextBefore,
          removeButton: ItemTagsRemoveButton(
            onRemoved: () {
              // Remove the item from the data source.
              setState(() {
                // required
                _items.removeAt(index);
              });
              //required
              return true;
            },
          ),
          // OR null,
          onPressed: (item) => print(item),
          onLongPressed: (item) => print(item),
        );
      },
    );
  }
}
import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';


class CustomTag extends StatefulWidget {
  Key key;
  List items;
  CustomTag({@required this.key, @required this.items});

  @override
  _CustomTagState createState() => _CustomTagState(this.key, this.items);
}

class _CustomTagState extends State<CustomTag> {
  Key _key;
  List _items;
  double _fontSize = 14;

  _CustomTagState([@required this._key, @required this._items]);

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
          /*image: ItemTagsImage(
              image: AssetImage(
                  "img.jpg") // OR NetworkImage("https://...image.png")
          ),*/
          // OR null,
          /*icon: ItemTagsIcon(
            icon: Icons.add,
          ),*/
          // OR null,
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
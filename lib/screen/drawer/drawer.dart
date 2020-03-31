import 'package:flutter/material.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';


class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class CustomDrawer extends StatefulWidget {

  CustomDrawer();

  final drawerItems = [
    new DrawerItem("Fragment 1", Icons.rss_feed),
    new DrawerItem("Fragment 2", Icons.local_pizza),
    new DrawerItem("Fragment 3", Icons.info)
  ];

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _selectedDrawerIndex = 0;

  _CustomDrawerState();


  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
          new ListTile(
            leading: new Icon(d.icon),
            title: new Text(d.title),
            selected: i == _selectedDrawerIndex,
            onTap: () => _onSelectItem(i),
          )
      );
    }


    return Drawer(
        child: new Column(
            children: <Widget>[
                new UserAccountsDrawerHeader(
                accountName: new Text("John Doe"), accountEmail: null),
                    new Column(children: drawerOptions)
              ],
          )
    );
  }
}
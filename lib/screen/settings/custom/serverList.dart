import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:port_mobile_app/constants/constants.dart';
import 'package:port_mobile_app/screen/settings/custom/CustomCardSettingsButton.dart';
import 'package:port_mobile_app/screen/settings/network/server/updateServer.dart';
import 'package:port_mobile_app/screen/slideToSideRoute.dart';
import "dart:io" show Platform;

class ServerList extends StatefulWidget {
  List<Server> servers;
  NetworkType networkType;

  ServerList({required this.servers, required this.networkType});

  @override
  _ServerList createState() => _ServerList();
}

class _ServerList extends State<ServerList> {
  _ServerList();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.servers.length,
            itemBuilder: (BuildContext context, int idx) {
              return CustomCardSettingsButton(label: widget.servers[idx].toString(),
                  onPressed: (){
                    final page = SettingsUpdateServer(networkType: widget.networkType, server: widget.servers[idx] );
                    Navigator.of(context).push(SlideToSideRoute(page)).then((value) {
                      //refresh the screen
                      setState(() {
                      });
                    });
                  });
            })
    );
  }
}
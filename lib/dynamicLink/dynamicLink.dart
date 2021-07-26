import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';

class DynamicLink {
  
  late String uriPrefix;

  late bool isAndroidDefined;
  late String? androidPackageName;
  late int? androidMinVersion;

  late bool isIOSDefined;
  late String? iosBudleId;
  late String? iosAppStoreId;
  late String? iosMinVersion;


  DynamicLink({required this.uriPrefix}) :
    isAndroidDefined = false,
    isIOSDefined = false;


  void defineAndroid({required String androidPackageName, required int minVersion}) {
                  this.isAndroidDefined = true;
                  this.androidPackageName = androidPackageName;
                  this.androidMinVersion = minVersion;
  }


  Future<String> createLink(String title) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: this.uriPrefix,
      link: Uri.parse('https://www.port.link'),
      androidParameters: this.isAndroidDefined ? AndroidParameters(
        packageName: this.androidPackageName!,
        minimumVersion: this.androidMinVersion
      ) : null,

      iosParameters: isIOSDefined? IosParameters(
        bundleId: this.iosBudleId!,
        minimumVersion: this.iosMinVersion,
        appStoreId: this.iosAppStoreId,
      ): null
    );

    final Uri dynamicUrl = await parameters.buildUrl();

    return dynamicUrl.toString();
  }
}

DynamicLink dl = DynamicLink(uriPrefix: "https://portapp.page.link");
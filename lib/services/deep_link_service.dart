import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:port_mobile_app/screen/qr/readQR.dart';
import 'package:port_mobile_app/screen/qr/structure.dart';
import 'package:logging/logging.dart';

final _log = Logger('DeepLinkService');

class DeepLinkService {
  final _appLinks = AppLinks();
  final StreamController<QRserverStructure> _deepLinkStreamController = StreamController<QRserverStructure>.broadcast();

  Stream<QRserverStructure> get deepLinkStream => _deepLinkStreamController.stream;

  Future<void> init() async {
    // Handle deep links
    try {
      // Handle all deep links through the stream
      _appLinks.uriLinkStream.listen((uri) {
        _log.info('Received deep link: $uri');
        _handleDeepLink(uri);
      });

        AppLinks().uriLinkStream.listen((qrData) {
        _log.info('Received deep link: $qrData');
          //ReadQR.saveToDatabase(qrData);
          var neki = "done";
          //Navigator.pushNamed(context, '/home');
    });

    } catch (e, stackTrace) {
      _log.severe('Deep link init error: $e\n$stackTrace');
    }
  }

  void _handleDeepLink(Uri uri) {
    try {
      _log.info('Handling deep link: $uri');
      final queryParams = uri.queryParameters;
      
      // Handle both direct deep links and dynamic links
      if (uri.scheme == 'port') {
        // Handle direct port:// scheme
        _log.info('Handling port:// scheme with params: $queryParams');
        final qr = QRserverStructure.fromJson({
          'app': queryParams['app'],
          'version': queryParams['version'],
          'userID': queryParams['userID'],
          'requestType': queryParams['requestType'],
          'url': queryParams['url']
        });
        _log.info('Created QR structure: $qr');
        _deepLinkStreamController.add(qr);
      } else if (uri.host == 'portapp.page.link') {
        // Handle Firebase Dynamic Link
        _log.info('Deep Link: $uri');
        final qr = QRserverStructure.parseDynamicLink(uri.toString());
        _log.info('qr: $qr');
        if (qr != null) {
          _deepLinkStreamController.add(qr);
        }
      }
    } catch (e, stackTrace) {
      _log.severe('Error handling deep link: $e\n$stackTrace');
    }
  }

  void dispose() {
    _deepLinkStreamController.close();
  }
}

final deepLinkService = DeepLinkService(); 
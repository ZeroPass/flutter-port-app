//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.


import 'dart:io';

class ServerSecurityContext  {
  static SecurityContext _ctx;

  /// 'Globally' init ctx using server certificate (.cer) bytes.
  /// [servCertBytes] should be single certificate because sha1 
  /// is calculated over these bytes and checked against sha1 of 
  /// certificate in _certificateCheck.
  static init(List<int> servCertBytes) {
    _ctx = SecurityContext();
    _ctx.setTrustedCertificatesBytes(servCertBytes);
  }

  static HttpClient getHttpClient({Duration timeout}) {
    final c = HttpClient(context: _ctx);
    if(timeout != null) {
      c.connectionTimeout = timeout;
    }
    return c;
  }
}
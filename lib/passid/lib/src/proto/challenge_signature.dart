//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'dart:typed_data';
import 'package:dmrtd/extensions.dart';

/// Represents list of signatures made 
/// with MRTD over [ProtoChallenge].
class ChallengeSignature  {
  static const _serKey = 'csigs';
  var _sigs = <Uint8List>[];
  
  ChallengeSignature();
  ChallengeSignature.fromList(this._sigs);
  bool get isEmpty => _sigs.isEmpty;

  void addSignature(Uint8List sig) {
    _sigs.add(sig);
  }
  
  Map<String, dynamic> toJson() {
      final b64Sigs = <String>[];
      for( final s in _sigs) {
          b64Sigs.add(s.base64());
      }
      return { _serKey : b64Sigs };
  }
}
//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.
import 'package:dmrtd/dmrtd.dart';
import 'package:meta/meta.dart';
import 'proto/challenge_signature.dart';

/// Class holds data needed for passID authentication.
/// e.g.: used at registration and login.
class AuthnData  {
  final EfSOD sod;
  final EfDG1 dg1;
  final EfDG14 dg14;
  final EfDG15 dg15;
  final ChallengeSignature csig;
  AuthnData({ @required this.dg15, @required this.csig, this.sod, this.dg1, this.dg14});
}
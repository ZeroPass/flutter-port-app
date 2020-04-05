//  Created by smlu, copyright © 2020 ZeroPass. All rights reserved.

class PassIdError implements Exception{
  static const int accountConflict        = 409; // Returned when trying to register with existing account
  static const int credentialsExpired     = 498; // Signed challenge used in API call has expired
                                                 // or credentials used to make proto session has expired e.g. account expired
  static const int missingParam           = 422; // Missing protocol parameter (API call)
  static const int preconditionFailed     = 412; // One or more condition in verification of eMRTD PKI trustchain failed e.g.: CSCA not found or expired ...
                                                 // Or when EfSOD doesn't contain DG file e.g.: DG1, DG15 ...
  static const int preconditionRequired   = 428; // Returned when optional parameter in API call is required e.g. EfDG1, EfDG14
                                                 // or parameter doesn't contain required data e.g. EfDG14 not containing field 'ActiveAuthenticationInfo'
  static const int protoError             = 400; // General protocol error
  static const int credVerificationFailed = 401; // Server failed to verify challenge signature
                                                 // or failed to verify MAC made over message with session key


  final int code;
  final String message;
  PassIdError(this.code, this.message);
  @override
  String toString() => 'PassIdError(code=$code, error=$message)';

  bool isDG1Required() {
    return code == PassIdError.preconditionRequired &&
      message.toLowerCase().contains('dg1 required');
  }
}
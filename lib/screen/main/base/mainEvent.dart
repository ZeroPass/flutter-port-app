import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MainEvent extends Equatable {
  MainEvent();
}

class LoginButtonPressed extends MainEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}
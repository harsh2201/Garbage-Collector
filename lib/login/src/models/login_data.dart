import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;
  String uname;

  LoginData({@required this.name, @required this.password, this.uname});

  @override
  String toString() {
    return '$runtimeType($name, $password, $uname)';
  }

  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name &&
          password == other.password &&
          uname == other.uname;
    }
    return false;
  }

  int get hashCode => hash2(name, password);
}

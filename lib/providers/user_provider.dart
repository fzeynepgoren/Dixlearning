import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'Kullanıcı';
  String _userSurname = '';
  int _userAge = 10;
  String _avatar = '👦';

  // Getters
  String get userName => _userName;
  String get userSurname => _userSurname;
  int get userAge => _userAge;
  String get avatar => _avatar;

  // Setters
  void updateUser({
    String? name,
    String? surname,
    int? age,
    String? avatar,
  }) {
    if (name != null) _userName = name;
    if (surname != null) _userSurname = surname;
    if (age != null) _userAge = age;
    if (avatar != null) _avatar = avatar;
    notifyListeners();
  }

  String get fullName => _userName + (_userSurname.isNotEmpty ? ' $_userSurname' : '');
}

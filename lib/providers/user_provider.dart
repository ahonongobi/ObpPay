import 'package:flutter/material.dart';
import 'package:obppay/model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel user = UserModel(
    fullName: "Alice Dupont",
    obpayId: "04-235-987",
    phone: "+243 89 123 4567",
    points: 42, // Modifie pour tester
  );

  void updateUser(String fullName, String phone) {
    user.fullName = fullName;
    user.phone = phone;
    notifyListeners();
  }

  void addPoints(int value) {
    user.points += value;
    notifyListeners();
  }
}

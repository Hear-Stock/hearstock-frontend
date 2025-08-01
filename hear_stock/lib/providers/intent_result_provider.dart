import 'package:flutter/foundation.dart';

class IntentResultProvider with ChangeNotifier {
  String? name;
  String? code;
  String? market;
  String? intent;
  String? period;
  String? path;

  void setIntentResult(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    market = json['market'];
    intent = json['intent'];
    period = json['period'];
    path = json['path'];
    notifyListeners();
  }

  void clear() {
    name = null;
    code = null;
    market = null;
    intent = null;
    period = null;
    path = null;
    notifyListeners();
  }
}

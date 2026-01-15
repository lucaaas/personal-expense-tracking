import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static late SharedPreferences _prefs;
  static SharedPreferencesHelper? _instance;

  SharedPreferencesHelper._();

  static Future<SharedPreferencesHelper> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesHelper._();
      await _instance!._init();
    }

    return _instance!;
  }

  Future<void> setLastSyncTime(String entity, DateTime time) async {
    await _prefs.setString('${entity}LastSync', time.toIso8601String());
  }

  DateTime? getLastSyncTime(String entity) {
    String? timeString = _prefs.getString('${entity}LastSync');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }

    return null;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }
}

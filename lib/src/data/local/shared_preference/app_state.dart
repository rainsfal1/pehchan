import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../app/notification_service.dart';

class PKBAppState extends ChangeNotifier {
  static PKBAppState _instance = PKBAppState._internal();

  factory PKBAppState() {
    return _instance;
  }

  PKBAppState._internal();

  static void reset() {
    _instance = PKBAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _userAllergies =
          prefs.getStringList('pkb_userAllergies') ?? _userAllergies;
    });
    _safeInit(() {
      final savedMedsJson = prefs.getString('pkb_savedMedicines');
      if (savedMedsJson != null && savedMedsJson.isNotEmpty) {
        _savedMedicines = List<Map<String, dynamic>>.from(jsonDecode(savedMedsJson));
      }
    });
    _safeInit(() {
      final historyJson = prefs.getString('pkb_doseHistory');
      if (historyJson != null && historyJson.isNotEmpty) {
        _doseHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      }
    });
    _safeInit(() {
      final enabledJson = prefs.getString('pkb_reminderEnabled');
      if (enabledJson != null && enabledJson.isNotEmpty) {
        final decoded = jsonDecode(enabledJson) as Map<String, dynamic>;
        _reminderEnabled = Map<String, bool>.from(decoded);
      }
    });
    _safeInit(() {
      _primaryColor =
          _colorFromIntValue(prefs.getInt('pkb_primaryColor')) ?? _primaryColor;
      _secondaryColor =
          _colorFromIntValue(prefs.getInt('pkb_secondaryColor')) ?? _secondaryColor;
      _tertiaryColor =
          _colorFromIntValue(prefs.getInt('pkb_tertiaryColor')) ?? _tertiaryColor;
    });
    _safeInit(() {
      _useScreenReader = prefs.getBool('pkb_useScreenReader') ?? _useScreenReader; 
      _isFirstLaunch = prefs.getBool('pkb_isFirstLaunch') ?? _isFirstLaunch;
      _ttsSpeed = prefs.getDouble('pkb_ttsSpeed') ?? _ttsSpeed;
      _textScale = prefs.getDouble('pkb_textScale') ?? _textScale;
      _silentMode = prefs.getBool('pkb_silentMode') ?? _silentMode;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String infoChild = '';
  String infoExprDate = '';
  String infoIngredient = '';
  String infoHowToTake = '';
  String infoWarning = '';
  String infoSideEffect = '';
  String infoMedName = '';
  int pourAmount = 0;
  String slotOfDay = '';
  String infoPrescribedDate = '';
  String extractedDuration = '';

  double _textScale = 1.0;
  double get textScale => _textScale;
  set textScale(double value) {
    _textScale = value;
    prefs.setDouble('pkb_textScale', value);
    notifyListeners();
  }

  double _ttsSpeed = 0.5;
  double get ttsSpeed => _ttsSpeed;
  set ttsSpeed(double value) {
    _ttsSpeed = value;
    prefs.setDouble('pkb_ttsSpeed', value);
  }

  // boolean of whether you want to use screen reader or TTS
  bool _useScreenReader = false;
  bool get useScreenReader => _useScreenReader;
  set useScreenReader(bool value) {
    _useScreenReader = value;
    prefs.setBool('pkb_useScreenReader', value);
  }

  bool _silentMode = false;
  bool get silentMode => _silentMode;
  set silentMode(bool value) {
    _silentMode = value;
    prefs.setBool('pkb_silentMode', value);
  }

  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;
  set isFirstLaunch(bool value) {
    _isFirstLaunch = value;
    prefs.setBool('pkb_isFirstLaunch', value);
  }

  Color _primaryColor = const Color(0xFFF9E000);
  Color get primaryColor => _primaryColor;
  set primaryColor(Color value) {
    _primaryColor = value;
    prefs.setInt('pkb_primaryColor', value.value);
  }

  Color _secondaryColor = Colors.white;
  Color get secondaryColor => _secondaryColor;
  set secondaryColor(Color value) {
    _secondaryColor = value;
    prefs.setInt('pkb_secondaryColor', value.value);
  }

  Color _tertiaryColor = Colors.black;
  Color get tertiaryColor => _tertiaryColor;
  set tertiaryColor(Color value) {
    _tertiaryColor = value;
    prefs.setInt('pkb_tertiaryColor', value.value);
  }

  bool isRestAmountRecognized = false;


  String foundAllergies = '';


  List<String> _userAllergies = [];
  List<String> get userAllergies => _userAllergies;
  set userAllergies(List<String> value) {
    _userAllergies = value;
    prefs.setStringList('pkb_userAllergies', value);
  }

  void addToUserAllergies(String value) {
    _userAllergies.add(value);
    prefs.setStringList('pkb_userAllergies', _userAllergies);
  }

  void removeFromUserAllergies(String value) {
    _userAllergies.remove(value);
    prefs.setStringList('pkb_userAllergies', _userAllergies);
  }

  void removeAtIndexFromUserAllergies(int index) {
    _userAllergies.removeAt(index);
    prefs.setStringList('pkb_userAllergies', _userAllergies);
  }

  void updateUserAllergiesAtIndex(
      int index,
      String Function(String) updateFn,
      ) {
    _userAllergies[index] = updateFn(_userAllergies[index]);
    prefs.setStringList('pkb_userAllergies', _userAllergies);
  }

  void insertAtIndexInUserAllergies(int index, String value) {
    _userAllergies.insert(index, value);
    prefs.setStringList('pkb_userAllergies', _userAllergies);
  }

  // Recognition source tracker (barcode or text)
  String recognitionSource = 'barcode';

  // Saved Medicines
  List<Map<String, dynamic>> _savedMedicines = [];
  List<Map<String, dynamic>> get savedMedicines => _savedMedicines;
  set savedMedicines(List<Map<String, dynamic>> value) {
    _savedMedicines = value;
    prefs.setString('pkb_savedMedicines', jsonEncode(value));
    notifyListeners();
  }

  // Dose History
  List<Map<String, dynamic>> _doseHistory = [];
  List<Map<String, dynamic>> get doseHistory => _doseHistory;

  // Reminder Enabled State (per medicine)
  Map<String, bool> _reminderEnabled = {};

  void addMedicine(String medicineName, String category, String source, {String? note}) {
    final medicine = {
      'id': const Uuid().v4(),
      'medicineName': medicineName,
      'category': category,
      'source': source,
      'note': note ?? '',
      'addedDate': DateTime.now().millisecondsSinceEpoch,
    };
    _savedMedicines.add(medicine);
    prefs.setString('pkb_savedMedicines', jsonEncode(_savedMedicines));
    notifyListeners();
  }

  void removeMedicineAt(int index) {
    _savedMedicines.removeAt(index);
    prefs.setString('pkb_savedMedicines', jsonEncode(_savedMedicines));
    notifyListeners();
  }

  // Update medicine with prescription instructions
  Future<void> updateMedicineInstructions(
    String medicineId,
    List<String> slotOfDay,
    String? duration,
    String? prescribedDate,
  ) async {
    final index = _savedMedicines.indexWhere((m) => m['id'] == medicineId);
    if (index != -1) {
      _savedMedicines[index]['instructions'] = {
        'slotOfDay': slotOfDay,
        'duration': duration,
        'prescribedDate': prescribedDate,
      };
      prefs.setString('pkb_savedMedicines', jsonEncode(_savedMedicines));

      // Auto-schedule reminders
      try {
        await NotificationService().scheduleRemindersForMedicine(_savedMedicines[index]);
        _reminderEnabled[medicineId] = true;
        prefs.setString('pkb_reminderEnabled', jsonEncode(_reminderEnabled));
      } catch (e) {
        print('Failed to schedule reminders: $e');
        // Don't fail silently - user will see error in UI when they try to enable reminders
      }

      notifyListeners();
    }
  }

  // Check if medicine has instructions
  bool medicineHasInstructions(Map<String, dynamic> medicine) {
    return medicine['instructions'] != null &&
           medicine['instructions']['slotOfDay'] != null &&
           (medicine['instructions']['slotOfDay'] as List).isNotEmpty;
  }

  // Get formatted instructions text for display
  String formatInstructions(Map<String, dynamic> medicine) {
    if (!medicineHasInstructions(medicine)) {
      return 'no schedule set';
    }

    final instructions = medicine['instructions'];
    final slots = instructions['slotOfDay'] as List;
    final duration = instructions['duration'] as String?;

    String text = slots.join(' & ');
    if (duration != null && duration.isNotEmpty) {
      text += ' • $duration';
    }
    return text;
  }

  // Get count of medicines with instructions
  int getMedicinesWithInstructionsCount() {
    return _savedMedicines.where((m) => medicineHasInstructions(m)).length;
  }

  // Clear temporary prescription data
  void clearPrescriptionData() {
    slotOfDay = '';
    infoPrescribedDate = '';
    extractedDuration = '';
    notifyListeners();
  }

  // Record a dose as taken
  void recordDoseTaken(
    String medicineId,
    String medicineName,
    DateTime scheduledTime,
    String slot,
  ) {
    final dose = {
      'id': const Uuid().v4(),
      'medicineId': medicineId,
      'medicineName': medicineName,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'takenTime': DateTime.now().millisecondsSinceEpoch,
      'slot': slot,
      'markedDate': DateTime.now().millisecondsSinceEpoch,
    };
    _doseHistory.add(dose);
    prefs.setString('pkb_doseHistory', jsonEncode(_doseHistory));
    notifyListeners();
  }

  // Get dose history for a specific medicine
  List<Map<String, dynamic>> getDoseHistoryForMedicine(String medicineId) {
    return _doseHistory
        .where((d) => d['medicineId'] == medicineId)
        .toList()
      ..sort((a, b) => (b['takenTime'] as int).compareTo(a['takenTime'] as int));
  }

  // Get recent doses (last 7 days)
  List<Map<String, dynamic>> getRecentDoses() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    return _doseHistory
        .where((d) => d['takenTime'] > weekAgo)
        .toList()
      ..sort((a, b) => (b['takenTime'] as int).compareTo(a['takenTime'] as int));
  }

  // Check if reminder is enabled for a medicine
  bool isReminderEnabled(String medicineId) {
    return _reminderEnabled[medicineId] ?? true; // Default enabled
  }

  // Set reminder enabled state for a medicine
  void setReminderEnabled(String medicineId, bool enabled) {
    _reminderEnabled[medicineId] = enabled;
    prefs.setString('pkb_reminderEnabled', jsonEncode(_reminderEnabled));
    notifyListeners();
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Color? _colorFromIntValue(int? val) {
  if (val == null) {
    return null;
  }
  return Color(val);
}

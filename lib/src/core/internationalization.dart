import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class PKBLocalizations {
  PKBLocalizations(this.locale);

  final Locale locale;

  static PKBLocalizations of(BuildContext context) =>
      Localizations.of<PKBLocalizations>(context, PKBLocalizations)!;

  static List<String> languages() => ['en', 'ur'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? urText = '',
  }) =>
      [enText, urText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

class PKBLocalizationsDelegate extends LocalizationsDelegate<PKBLocalizations> {
  const PKBLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final language = locale.toString();
    return PKBLocalizations.languages().contains(
      language.endsWith('_')
          ? language.substring(0, language.length - 1)
          : language,
    );
  }

  @override
  Future<PKBLocalizations> load(Locale locale) =>
      SynchronousFuture<PKBLocalizations>(PKBLocalizations(locale));

  @override
  bool shouldReload(PKBLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

final kTranslationsMap = <String, Map<String, String>>{
  'menu_medicine_scan': {
    'en': 'Medicine Scan',
    'ur': 'ادویات اسکین',
  },
  'menu_prescription_scan': {
    'en': 'Prescription Scan',
    'ur': 'نسخہ اسکین',
  },
  'menu_settings': {
    'en': 'Settings',
    'ur': 'ترتیبات',
  },
  'menu_help': {
    'en': 'Help',
    'ur': 'مدد',
  },
  'scan_instruction_med': {
    'en': 'Hold the camera about 30 cm away and slowly rotate the package.',
    'ur': 'کیمرہ تقریباً 30 سینٹی میٹر دور رکھیں اور ڈبّہ آہستہ آہستہ گھمائیں۔',
  },
  'scan_instruction_rx': {
    'en': 'Hold the camera ~30 cm away, show one prescription packet, flip it, then show again.',
    'ur': 'کیمرہ تقریباً 30 سینٹی میٹر دور رکھیں، ایک نسخہ پیکٹ دکھائیں، پلٹیں اور دوبارہ دکھائیں۔',
  },
  'header_prescription_scan': {
    'en': 'Prescription Scan',
    'ur': 'نسخہ اسکین',
  },
  'header_med_scan': {
    'en': 'Medicine Scan',
    'ur': 'ادویات اسکین',
  },
  'settings_language': {
    'en': 'Language',
    'ur': 'زبان',
  },
  'settings_subtitle': {
    'en': 'Customize how Pehchan speaks and looks.',
    'ur': 'پہچان کی آواز اور انداز اپنی مرضی سے ترتیب دیں۔',
  },
  'language_subtitle': {
    'en': 'Choose the language for Pehchan.',
    'ur': 'پہچان کے لیے زبان منتخب کریں۔',
  },
  'category_label': {
    'en': 'Category (optional)',
    'ur': 'زمرہ (اختیاری)',
  },
  'category_general': {
    'en': 'General',
    'ur': 'عام',
  },
  'category_pain_relief': {
    'en': 'Pain relief',
    'ur': 'درد دور کرنے والی',
  },
  'category_antibiotic': {
    'en': 'Antibiotic',
    'ur': 'اینٹی بایوٹک',
  },
  'category_cold_cough': {
    'en': 'Cold & cough',
    'ur': 'نزلہ و کھانسی',
  },
  'category_vitamin': {
    'en': 'Vitamin',
    'ur': 'وٹامن',
  },
  'category_allergy': {
    'en': 'Allergy',
    'ur': 'الرجی',
  },
  'language_en': {
    'en': 'English',
    'ur': 'انگریزی',
  },
  'language_ur': {
    'en': 'Urdu',
    'ur': 'اردو',
  },
  'settings_allergy': {
    'en': 'Allergy settings',
    'ur': 'الرجی ترتیبات',
  },
  'settings_color': {
    'en': 'Color settings',
    'ur': 'رنگ کی ترتیبات',
  },
  'settings_audio': {
    'en': 'Audio settings',
    'ur': 'آڈیو ترتیبات',
  },
  'help_title': {
    'en': 'Help',
    'ur': 'مدد',
  },
  'help_subtitle': {
    'en': 'Quick tips and guidance.',
    'ur': 'فوری رہنمائی اور تجاویز۔',
  },
  'help_medicine': {
    'en': 'Medicine Scan',
    'ur': 'ادویات اسکین',
  },
  'help_prescription': {
    'en': 'Prescription Scan',
    'ur': 'نسخہ اسکین',
  },
  'help_my_meds': {
    'en': 'My medicines',
    'ur': 'میری دوائیں',
  },
  'help_text_my_meds': {
    'en': 'Save recognized medicines for quick access and reminders. You can review, edit, or remove them anytime.',
    'ur': 'پہچانی گئی دوائیں محفوظ کریں تاکہ فوری رسائی اور یاددہانی مل سکیں۔ آپ کسی بھی وقت انہیں دیکھ، ترمیم یا حذف کرسکتے ہیں۔',
  },
  'help_allergy': {
    'en': 'Allergy settings',
    'ur': 'الرجی ترتیبات',
  },
  'help_audio': {
    'en': 'Audio settings',
    'ur': 'آڈیو ترتیبات',
  },
  'help_source': {
    'en': 'Medicine info source',
    'ur': 'ادویات معلومات کا ماخذ',
  },
  'color_settings': {
    'en': 'Color settings',
    'ur': 'رنگ کی ترتیبات',
  },
  'color_background': {
    'en': 'Background color',
    'ur': 'پس منظر کا رنگ',
  },
  'color_contrast': {
    'en': 'Contrast color',
    'ur': 'متضاد رنگ',
  },
  'color_accent': {
    'en': 'Accent color',
    'ur': 'نمایاں رنگ',
  },
  'color_black': {
    'en': 'Black',
    'ur': 'سیاہ',
  },
  'color_white': {
    'en': 'White',
    'ur': 'سفید',
  },
  'color_gray': {
    'en': 'Gray',
    'ur': 'سرمئی',
  },
  'color_blue': {
    'en': 'Blue',
    'ur': 'نیلا',
  },
  'color_red': {
    'en': 'Red',
    'ur': 'سرخ',
  },
  'color_yellow': {
    'en': 'Yellow',
    'ur': 'پیلا',
  },
  'audio_settings': {
    'en': 'Audio settings',
    'ur': 'آڈیو ترتیبات',
  },
  'audio_use_screen_reader': {
    'en': 'Use screen reader',
    'ur': 'اسکرین ریڈر استعمال کریں',
  },
  'audio_mute': {
    'en': 'Mute app voice',
    'ur': 'ایپ کی آواز بند کریں',
  },
  'audio_speed_label': {
    'en': 'Current audio speed: {value}',
    'ur': 'موجودہ آواز کی رفتار: {value}',
  },
  'audio_toggle_sr_on': {
    'en': 'You are using the screen reader. Tap to switch to app audio.',
    'ur': 'آپ اسکرین ریڈر استعمال کر رہے ہیں۔ ایپ آڈیو پر جانے کے لیے ٹیپ کریں۔',
  },
  'audio_toggle_sr_off': {
    'en': 'You are using app audio. Tap to switch to screen reader.',
    'ur': 'آپ ایپ آڈیو استعمال کر رہے ہیں۔ اسکرین ریڈر پر جانے کے لیے ٹیپ کریں۔',
  },
  'settings_font_size': {
    'en': 'Text size',
    'ur': 'متن کا سائز',
  },
  'font_size_standard': {
    'en': 'Standard',
    'ur': 'معمول',
  },
  'font_size_large': {
    'en': 'Large',
    'ur': 'بڑا',
  },
  'font_size_xlarge': {
    'en': 'Extra large',
    'ur': 'انتہائی بڑا',
  },
  'font_size_desc': {
    'en': 'Pick a text size that is comfortable for you.',
    'ur': 'اپنے لیے آرام دہ متن کا سائز منتخب کریں۔',
  },
  'help_text_med': {
    'en': 'From Home, choose Medicine Scan. Hold the camera ~30 cm away and rotate the box. Vibrations indicate detections; you will hear the medicine name.',
    'ur': 'ہوم سے ادویات اسکین منتخب کریں۔ کیمرہ تقریباً 30 سینٹی میٹر دور رکھیں اور ڈبّہ آہستہ گھمائیں۔ کمپن سے اطلاع ملے گی اور نام سنایا جائے گا۔',
  },
  'help_text_rx': {
    'en': 'From Home, choose Prescription Scan. Show one packet, flip once. The app announces morning/noon/night when detected.',
    'ur': 'ہوم سے نسخہ اسکین منتخب کریں۔ ایک پیکٹ دکھائیں، پلٹیں۔ صبح/دوپہر/رات ملنے پر اعلان ہوگا۔',
  },
  'help_text_allergy': {
    'en': 'In Settings > Allergy, add allergens to flag. Warnings appear when a scanned medicine contains them.',
    'ur': 'ترتیبات > الرجی میں وہ اجزاء شامل کریں جن پر تنبیہ چاہیے۔ اسکین شدہ دوا میں ہوں تو اطلاع ملے گی۔',
  },
  'help_text_audio': {
    'en': 'In Settings > Audio, pick screen reader or app audio and adjust speed.',
    'ur': 'ترتیبات > آڈیو میں اسکرین ریڈر یا ایپ آڈیو منتخب کریں اور رفتار بدلیں۔',
  },
  'help_text_source': {
    'en': 'Current medicine info is from the bundled database.',
    'ur': 'موجودہ دوا کی معلومات بنڈلڈ ڈیٹا بیس سے ہیں۔',
  },
  'allergy_add_title': {
    'en': 'Add allergy',
    'ur': 'الرجی شامل کریں',
  },
  'allergy_add_hint': {
    'en': 'Enter an allergen',
    'ur': 'کوئی الرجی درج کریں',
  },
  'allergy_add_button': {
    'en': 'Add',
    'ur': 'شامل کریں',
  },
  'allergy_add_error': {
    'en': 'Please enter an allergen.',
    'ur': 'براہ کرم الرجی درج کریں۔',
  },
  'allergy_delete': {
    'en': 'Delete',
    'ur': 'حذف کریں',
  },
  'language_title': {
    'en': 'Language',
    'ur': 'زبان',
  },
  'language_subtitle': {
    'en': 'Choose the language for Pehchan.',
    'ur': 'پہچان کے لیے زبان منتخب کریں۔',
  },
  'my_medicines': {
    'en': 'My Medicines',
    'ur': 'میری دوائیں',
  },
  'identify_medicine': {
    'en': 'Identify Medicine',
    'ur': 'دوا کی شناخت کریں',
  },
  'add_prescription': {
    'en': 'Add Prescription',
    'ur': 'نسخہ شامل کریں',
  },
  'manual_rx_title': {
    'en': 'Add prescription',
    'ur': 'نسخہ شامل کریں',
  },
  'manual_rx_subtitle': {
    'en': 'Pick a medicine, then set when to take it.',
    'ur': 'دوائی منتخب کریں اور لینے کا وقت طے کریں۔',
  },
  'manual_rx_select_medicine': {
    'en': 'Select medicine',
    'ur': 'دوائی منتخب کریں',
  },
  'manual_rx_no_meds': {
    'en': 'No medicines yet. Add one first, then attach a prescription.',
    'ur': 'ابھی کوئی دوا موجود نہیں۔ پہلے دوا شامل کریں پھر نسخہ لگائیں۔',
  },
  'manual_rx_schedule': {
    'en': 'Schedule',
    'ur': 'شیڈول',
  },
  'manual_rx_when': {
    'en': 'When should reminders ring?',
    'ur': 'یاددہانی کب بجے؟',
  },
  'manual_rx_slot_morning': {
    'en': 'Morning',
    'ur': 'صبح',
  },
  'manual_rx_slot_noon': {
    'en': 'Afternoon',
    'ur': 'دوپہر',
  },
  'manual_rx_slot_night': {
    'en': 'Night',
    'ur': 'رات',
  },
  'manual_rx_start_date': {
    'en': 'Start date (optional)',
    'ur': 'شروع ہونے کی تاریخ (اختیاری)',
  },
  'manual_rx_date_label': {
    'en': 'Prescription date (optional)',
    'ur': 'نسخے کی تاریخ (اختیاری)',
  },
  'manual_rx_error_select_med': {
    'en': 'Select a medicine first',
    'ur': 'پہلے دوا منتخب کریں',
  },
  'manual_rx_error_pick_time': {
    'en': 'Pick at least one time to take it',
    'ur': 'کم از کم ایک وقت منتخب کریں',
  },
  'manual_rx_saved': {
    'en': 'Prescription added for {name}',
    'ur': '{name} کے لیے نسخہ شامل ہوگیا',
  },
  'manual_rx_back': {
    'en': 'Back',
    'ur': 'واپس',
  },
  'manual_rx_save': {
    'en': 'Save prescription',
    'ur': 'نسخہ محفوظ کریں',
  },
  'add_medicine': {
    'en': 'Add medicine',
    'ur': 'دوائی شامل کریں',
  },
  'manual_add_header': {
    'en': 'Add medicine',
    'ur': 'دوائی شامل کریں',
  },
  'manual_add_name': {
    'en': 'Medicine name *',
    'ur': 'دوائی کا نام *',
  },
  'manual_add_details': {
    'en': 'More details (optional)',
    'ur': 'مزید تفصیل (اختیاری)',
  },
  'manual_hide_details': {
    'en': 'Hide details',
    'ur': 'تفصیل چھپائیں',
  },
  'manual_add_note': {
    'en': 'Note (optional)',
    'ur': 'نوٹ (اختیاری)',
  },
  'manual_add_error': {
    'en': 'Please enter a medicine name',
    'ur': 'براہِ کرم دوائی کا نام درج کریں',
  },
  'manual_added_snackbar': {
    'en': 'Medicine added. Add reminders?',
    'ur': 'دوائی شامل ہوگئی۔ یاددہانی لگانی ہے؟',
  },
  'manual_add_reminders': {
    'en': 'Add reminders',
    'ur': 'یاددہانی لگائیں',
  },
  'manual_save': {
    'en': 'Save',
    'ur': 'محفوظ کریں',
  },
  'manual_cta_title': {
    'en': 'Prefer to add it manually?',
    'ur': 'دستی طور پر شامل کرنا چاہتے ہیں؟',
  },
  'manual_cta_body': {
    'en': 'Pick a medicine and set times without scanning.',
    'ur': 'بغیر اسکین کیے دوا منتخب کریں اور وقت مقرر کریں۔',
  },
  'manual_cta_button': {
    'en': 'Add manually',
    'ur': 'دستی طور پر شامل کریں',
  },
  'toggle_on': {
    'en': 'On',
    'ur': 'آن',
  },
  'toggle_off': {
    'en': 'Off',
    'ur': 'آف',
  },
  'status_take_now': {
    'en': 'Take medicine now',
    'ur': 'ابھی دوا لیں',
  },
  'status_next_dose': {
    'en': 'Next dose: {time}',
    'ur': 'اگلی خوراک: {time}',
  },
  'status_saved': {
    'en': '{count} saved',
    'ur': '{count} محفوظ',
  },
  'status_saved_scheduled': {
    'en': '{countSaved} saved, {countSched} scheduled',
    'ur': '{countSaved} محفوظ، {countSched} شیڈول',
  },
  'no_medicines_yet': {
    'en': 'No medicines added yet',
    'ur': 'ابھی تک کوئی دوا شامل نہیں کی گئی',
  },
  'no_schedule_set': {
    'en': 'no schedule set',
    'ur': 'کوئی شیڈول سیٹ نہیں',
  },
  'confirm_medicine': {
    'en': 'Confirm Medicine',
    'ur': 'دوا کی تصدیق کریں',
  },
  'confirm_medicine_text': {
    'en': 'Is this {medicineName}?',
    'ur': 'کیا یہ {medicineName} ہے؟',
  },
  'save_medicine': {
    'en': 'Save',
    'ur': 'محفوظ کریں',
  },
  'save_to_my_medicines': {
    'en': 'Save to My Medicines',
    'ur': 'میری دوائیوں میں محفوظ کریں',
  },
  'delete_medicine': {
    'en': 'Delete Medicine',
    'ur': 'دوا حذف کریں',
  },
  'delete_medicine_confirm': {
    'en': 'Are you sure you want to delete {medicineName}?',
    'ur': 'کیا آپ واقعی {medicineName} حذف کرنا چاہتے ہیں؟',
  },
  'cancel': {
    'en': 'Cancel',
    'ur': 'منسوخ کریں',
  },
  'delete': {
    'en': 'Delete',
    'ur': 'حذف کریں',
  },
  'medicine_saved': {
    'en': 'Medicine saved successfully',
    'ur': 'دوا کامیابی سے محفوظ ہوگئی',
  },
  'select_medicine': {
    'en': 'Select Medicine',
    'ur': 'دوا منتخب کریں',
  },
  'attach_to_medicine': {
    'en': 'Attach to Medicine',
    'ur': 'دوا سے منسلک کریں',
  },
  'extracted_instructions': {
    'en': 'Extracted Instructions',
    'ur': 'نکالی گئی ہدایات',
  },
  'no_medicines_to_link': {
    'en': 'No medicines saved yet. Please scan a medicine first.',
    'ur': 'ابھی تک کوئی دوا محفوظ نہیں ہوئی۔ براہ کرم پہلے دوا اسکین کریں۔',
  },
  'instructions_attached': {
    'en': 'Instructions attached successfully',
    'ur': 'ہدایات کامیابی سے منسلک ہوگئیں',
  },
  'dose_reminder': {
    'en': 'Dose Reminder',
    'ur': 'خوراک کی یاددہانی',
  },
  'mark_as_taken': {
    'en': 'Mark as Taken',
    'ur': 'لی گئی کے طور پر نشان زد کریں',
  },
  'skip_dose': {
    'en': 'Skip',
    'ur': 'چھوڑیں',
  },
};

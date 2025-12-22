import '../../../core/pillkaboo_util.dart';
import '../../../app/global_audio_player.dart';
import '../../../app/tts/tts_service.dart';
import '../views/detector_view.dart';
import '../../../data/local/database/barcode_db_helper.dart';
import '../../../data/local/database/ingredients_db_helper.dart';
import '../../../utils/date_parser.dart';
import '../../../utils/gs1_parser.dart';
import '../views/barcode_detector_painter.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:async';
import 'package:flutter/semantics.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';


class MedRecognizerWidget extends StatefulWidget {
  final StreamController<bool> controller;
  const MedRecognizerWidget({
    super.key,
    this.width,
    this.height,
    required this.controller,
  });
  final double? width;
  final double? height;
  @override
  _MedRecognizerWidgetState createState() => _MedRecognizerWidgetState();
}

class _MedRecognizerWidgetState extends State<MedRecognizerWidget> {

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true; // 이미지 처리 가능 여부
  bool _isBusy = false; // 이미지 처리 중 여부
  CustomPaint? _customPaint; // 이미지에 그려질 CustomPaint

  String? _recognizedBarcode; // 인식된 바코드
  String? _recognizedText;

  var _cameraLensDirection = CameraLensDirection.back; // 카메라 렌즈 방향

  bool _isDateRecognized = false; // 날짜 인식 여부
  bool _isBarcodeRecognized = false; // 바코드 인식 여부

  String _medTitle = "";
  String _exprDate = "";
  Map<String, dynamic> _medicineInfo = {}; // 약 정보
  final Map<String, List<String>> _synonymMap = {
    'paracetamol': ['acetaminophen', 'panadol'],
    'ibuprofen': ['advil', 'nurofen'],
    'amoxicillin': ['amox', 'amoxi'],
    'cetirizine': ['zyrtec'],
    'loratadine': ['claritin'],
    'metformin': ['glucophage'],
    'omeprazole': ['prilosec'],
  };
  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '').trim();

  bool _isAllergyMatch(String ingredientNorm, String allergyNorm) {
    if (ingredientNorm.isEmpty || allergyNorm.isEmpty) return false;
    if (ingredientNorm.contains(allergyNorm) || allergyNorm.contains(ingredientNorm)) {
      return true;
    }
    final synonyms = _synonymMap[allergyNorm] ?? [];
    for (final syn in synonyms) {
      final normSyn = _normalize(syn);
      if (ingredientNorm.contains(normSyn) || normSyn.contains(ingredientNorm)) {
        return true;
      }
      if (ratio(ingredientNorm, normSyn) >= 80) {
        return true;
      }
    }
    if (ratio(ingredientNorm, allergyNorm) >= 80) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    listenForPermissions();
    _isDateRecognized = false;
    _isBarcodeRecognized = false;
    GlobalAudioPlayer().playRepeat();
    setState(() {
      PKBAppState().infoMedName = "";
      PKBAppState().infoExprDate = "";
      PKBAppState().infoHowToTake = "";
      PKBAppState().infoWarning = "";
      PKBAppState().infoSideEffect = "";
      PKBAppState().infoIngredient = "";
      PKBAppState().infoChild = "";
      PKBAppState().foundAllergies = "";
    });
  }

  void listenForPermissions() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;
    if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    _barcodeScanner.close();
    GlobalAudioPlayer().pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Proceed if barcode is recognized and medicine name is set (date is optional)
      if (_isBarcodeRecognized && PKBAppState().infoMedName != "") {
        _isBarcodeRecognized = false;
        _isDateRecognized = false;
        widget.controller.add(true);
      }
    });

    return _isBarcodeRecognized
        ? const LinearProgressIndicator()
        : DetectorView(
          title: 'Barcode Scanner',
          customPaint: _customPaint,
          text: _recognizedBarcode,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        );
  }

  // 진동
  void triggerVibrationIfNecessary() {
    Vibration.vibrate();
  }

  /**
   * text recognition & barcode detection methods
   */
  // 이미지 처리
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _recognizedBarcode = '';
      _recognizedText = '';
    });

    final text = await _textRecognizer.processImage(inputImage);
    final barcodes = await _barcodeScanner.processImage(inputImage);

    if (!_isDateRecognized) {
      List<String> splitText = text.text.split(RegExp(r'\s+'));
      for (String word in splitText) {
        if (DateParser.isDate(word)) {
          final date = DateParser.parseDate(word);
          if (date != null) {
            if (mounted) {
              setState(() {
                _isDateRecognized = true;
              });
            }
            triggerVibrationIfNecessary();
            if (_exprDate == "") {
              _exprDate = "${date.year}-${date.month}-${date.day}";
            }
            PKBAppState().infoExprDate = _exprDate;
            _exprDate = "";
            break;
          }
        }
      }
    }
    if (!_isBarcodeRecognized) {
      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          final recognizedBarcode = barcode.rawValue!;

          // Parse GS1 DataMatrix if detected
          Map<String, String?>? parsedGS1;
          if (barcode.format == BarcodeFormat.dataMatrix || GS1Parser.isGS1Format(recognizedBarcode)) {
            parsedGS1 = GS1Parser.parseDataMatrix(recognizedBarcode);

            // Provide TTS feedback for DataMatrix detection
            if (!PKBAppState().useScreenReader) {
              TtsService().speak('DataMatrix detected');
            }

            // If expiry date found in DataMatrix, prefer it over OCR
            if (parsedGS1['expiry'] != null && !_isDateRecognized) {
              if (mounted) {
                setState(() {
                  _isDateRecognized = true;
                });
              }
              PKBAppState().infoExprDate = parsedGS1['expiry']!;
              triggerVibrationIfNecessary();

              // Announce expiry date via TTS
              if (!PKBAppState().useScreenReader) {
                TtsService().speak('Expiry date detected from barcode');
              }
            }
          }

          final matches = await BarcodeDBHelper.searchByBarcode(recognizedBarcode);
          if (matches.isNotEmpty) {
            if (mounted) {
              setState(() {
                _isBarcodeRecognized = true;
              });
            }
            triggerVibrationIfNecessary();
            _medicineInfo = matches[0];
            final itemSeq = _medicineInfo['product_id'];

            final ingreInfo = await IngredientsDBHelper.searchIngredientsByProductId(itemSeq);

            // Set medicine name from barcode data
            if (_medTitle == "") {
              _medTitle = _medicineInfo['product_name'] ?? '';
              PKBAppState().infoMedName = _medTitle;
              _medTitle = "";
            }

            // Set detailed info from ingredients data
            if (ingreInfo.isNotEmpty) {
              final ingre = ingreInfo.first;

              // Ingredients
              PKBAppState().infoIngredient = ingre['active_ingredients'] ?? 'No ingredient info';

              // Therapeutic class (used inside how-to section)
              final therapeuticClass = ingre['therapeutic_class'] ?? '';

              // How to take
              PKBAppState().infoHowToTake = [
                ingre['dosage_instructions'] ?? 'No dosage information available',
                if (therapeuticClass.isNotEmpty) 'Therapeutic Class: $therapeuticClass',
              ].where((part) => part != null && part.toString().trim().isNotEmpty).join('\n\n');

              // Warnings
              PKBAppState().infoWarning = ingre['warnings'] ?? 'No warnings available';

              // Side effects
              PKBAppState().infoSideEffect = ingre['side_effects'] ?? 'No side effect information available';

              // Allergy detection
              final found = <String>{};
              final ingredients = ingre['active_ingredients']
                  .toString()
                  .split(RegExp('[,;/|]'))
                  .map(_normalize)
                  .where((s) => s.isNotEmpty)
                  .toList();

              for (final allergy in PKBAppState().userAllergies) {
                final normAllergy = _normalize(allergy);
                for (final ing in ingredients) {
                  if (_isAllergyMatch(ing, normAllergy)) {
                    found.add(allergy);
                    break;
                  }
                }
              }

              if (found.isNotEmpty) {
                PKBAppState().foundAllergies = found.join(' ');
              }
            } else {
              // Fallback if no ingredient data
              PKBAppState().infoHowToTake = _medicineInfo['description'] ?? 'Consult your doctor or pharmacist';
              PKBAppState().infoWarning = 'Consult your doctor or pharmacist';
              PKBAppState().infoSideEffect = 'Consult your doctor or pharmacist';
            }

            _isBarcodeRecognized = true;
          }
        }
      }

    }
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = BarcodeDetectorPainter(
        barcodes,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
      }
      _recognizedBarcode = text;
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

}

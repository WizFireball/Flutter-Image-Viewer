import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-adjustable UI settings. Changes notify listeners instantly
/// call [save] to persist (the settings page does this on slider release)
/// I dont think i need to add much comments in this file since most of this
/// is self explanatory
class AppSettings extends ChangeNotifier {
  // ==== defaults ====
  static const defPillTextSize = 14.0;
  static const defPillIconSize = 24.0;
  static const defArrowIconSize = 28.0;
  static const defTooltipTextSize = 12.0;
  static const defPillOpacity = 0.78;
  static const defPillBlur = true;

  // Info panel: solid + no blur by default (cheapest to render)
  static const defInfoOpacity = 1.0;
  static const defInfoBlur = false;

  double _pillTextSize = defPillTextSize;
  double _pillIconSize = defPillIconSize;
  double _arrowIconSize = defArrowIconSize;
  double _pillOpacity = defPillOpacity;
  bool _pillBlur = defPillBlur;
  double _infoOpacity = defInfoOpacity;
  bool _infoBlur = defInfoBlur;

  /// Tooltip size has its own notifier so only tooltips rebuild.
  final tooltipSize = ValueNotifier<double>(defTooltipTextSize);

  double get pillTextSize => _pillTextSize;
  double get pillIconSize => _pillIconSize;
  double get arrowIconSize => _arrowIconSize;
  double get tooltipTextSize => tooltipSize.value;
  double get pillOpacity => _pillOpacity;
  bool get pillBlur => _pillBlur;
  double get infoOpacity => _infoOpacity;
  bool get infoBlur => _infoBlur;

  /// Arrow button grows with its icon.
  double get arrowButtonSize => _arrowIconSize + 20;

  set pillTextSize(double v) {
    _pillTextSize = v;
    notifyListeners();
  }

  set pillIconSize(double v) {
    _pillIconSize = v;
    notifyListeners();
  }

  set arrowIconSize(double v) {
    _arrowIconSize = v;
    notifyListeners();
  }

  set tooltipTextSize(double v) {
    tooltipSize.value = v;
    notifyListeners();
  }

  set pillOpacity(double v) {
    _pillOpacity = v;
    notifyListeners();
  }

  set pillBlur(bool v) {
    _pillBlur = v;
    notifyListeners();
  }

  set infoOpacity(double v) {
    _infoOpacity = v;
    notifyListeners();
  }

  set infoBlur(bool v) {
    _infoBlur = v;
    notifyListeners();
  }

// Hey you might need to read the documentation or tutorial
// of what 'getDouble' or 'setDouble' do or how they do that  

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _pillTextSize = p.getDouble('pillTextSize') ?? defPillTextSize;

      _pillIconSize = p.getDouble('pillIconSize') ?? defPillIconSize;

      _arrowIconSize = p.getDouble('arrowIconSize') ?? defArrowIconSize;

      tooltipSize.value = p.getDouble('tooltipTextSize') ?? defTooltipTextSize;

      _pillOpacity = p.getDouble('pillOpacity') ?? defPillOpacity;

      _pillBlur = p.getBool('pillBlur') ?? defPillBlur;

      _infoOpacity = p.getDouble('infoOpacity') ?? defInfoOpacity;

      _infoBlur = p.getBool('infoBlur') ?? defInfoBlur;

    } catch (_) {
      // fall back to defaults
    }
  }

  Future<void> save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble('pillTextSize', _pillTextSize);
      await p.setDouble('pillIconSize', _pillIconSize);
      await p.setDouble('arrowIconSize', _arrowIconSize);
      await p.setDouble('tooltipTextSize', tooltipSize.value);
      await p.setDouble('pillOpacity', _pillOpacity);
      await p.setBool('pillBlur', _pillBlur);
      await p.setDouble('infoOpacity', _infoOpacity);
      await p.setBool('infoBlur', _infoBlur);
    } catch (_) {}
  }

  Future<void> reset() async {
    _pillTextSize = defPillTextSize;
    _pillIconSize = defPillIconSize;
    _arrowIconSize = defArrowIconSize;
    tooltipSize.value = defTooltipTextSize;
    _pillOpacity = defPillOpacity;
    _pillBlur = defPillBlur;
    _infoOpacity = defInfoOpacity;
    _infoBlur = defInfoBlur;
    notifyListeners();
    await save();
  }
}

// App-wide instance (loaded in main()).
// So that i not end up creating this multiple times 
final appSettings = AppSettings();

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/quest_bank.dart';
import '../data/store_bank.dart';
import '../models/completed_quest.dart';
import '../models/quest.dart';
import '../models/quest_type.dart';
import '../models/store_item.dart';

/// Single source of truth for the app's mock local state: coins, scan
/// credits, dice skins, pro status, and quest history. No backend - all
/// state lives in memory for this MVP.
class AppState extends ChangeNotifier {
  static const int maxScanCredits = 2;
  static const int startingCoins = 100;

  int _coins = startingCoins;
  int _scanCredits = maxScanCredits;
  bool _isPro = false;
  String _activeSkinId = StoreBank.defaultSkinId;
  final Set<String> _ownedSkinIds = {StoreBank.defaultSkinId};
  final Map<String, int> _inventory = {}; // non-skin consumables, e.g. shields
  final List<CompletedQuest> _history = [];

  Quest? _pendingQuest;

  static const _secureStorage = FlutterSecureStorage();
  static const _geminiKeysStorageKey = 'gemini_api_keys';
  static const _geminiActiveIndexStorageKey = 'gemini_active_key_index';

  final List<String> _geminiApiKeys = [];
  int _activeGeminiKeyIndex = 0;

  List<String> get geminiApiKeys => List.unmodifiable(_geminiApiKeys);
  int get activeGeminiKeyIndex => _activeGeminiKeyIndex;
  bool get hasGeminiKeys => _geminiApiKeys.isNotEmpty;

  int get coins => _coins;
  int get scanCredits => _scanCredits;
  bool get isPro => _isPro;
  String get activeSkinId => _activeSkinId;
  Set<String> get ownedSkinIds => Set.unmodifiable(_ownedSkinIds);
  List<CompletedQuest> get history => List.unmodifiable(_history.reversed);
  Quest? get pendingQuest => _pendingQuest;

  int shieldCount() => _inventory['streak_shield'] ?? 0;

  int coinMultiplier() => _isPro ? 2 : 1;

  /// Rolls a fresh quest for the given type (except [QuestType.doctor],
  /// whose quest is built later from a mock diagnosis) and stashes it as
  /// the pending quest awaiting claim/forfeit.
  Quest rollQuest(QuestType type) {
    final quest = QuestBank.random(type);
    _pendingQuest = quest;
    notifyListeners();
    return quest;
  }

  /// Whether a scan can be consumed right now (Pro members are unlimited).
  bool get canScan => _isPro || _scanCredits > 0;

  /// Attempts to spend one scan credit. Returns false if none remain and
  /// the caller isn't Pro - the UI should route to the paywall in that case.
  bool consumeScanCredit() {
    if (_isPro) return true;
    if (_scanCredits <= 0) return false;
    _scanCredits -= 1;
    notifyListeners();
    return true;
  }

  /// Builds and stashes the dynamic AI Doctor quest from a mock diagnosis.
  Quest submitDiagnosis(String diagnosis) {
    final quest = QuestBank.buildDoctorQuest(diagnosis);
    _pendingQuest = quest;
    notifyListeners();
    return quest;
  }

  /// Claims the pending quest: awards coins (doubled for Pro) and logs it.
  int claimPendingQuest() {
    final quest = _pendingQuest;
    if (quest == null) return 0;
    final earned = quest.coinReward * coinMultiplier();
    _coins += earned;
    _history.add(CompletedQuest(
      quest: quest,
      completedAt: DateTime.now(),
      coinsEarned: earned,
    ));
    _pendingQuest = null;
    notifyListeners();
    return earned;
  }

  /// Forfeits the pending quest with no reward, still logged for the record.
  void forfeitPendingQuest() {
    final quest = _pendingQuest;
    if (quest == null) return;
    _history.add(CompletedQuest(
      quest: quest,
      completedAt: DateTime.now(),
      coinsEarned: 0,
      forfeited: true,
    ));
    _pendingQuest = null;
    notifyListeners();
  }

  void clearPendingQuest() {
    _pendingQuest = null;
    notifyListeners();
  }

  bool ownsSkin(String skinId) => _ownedSkinIds.contains(skinId);

  bool canAfford(int cost) => _coins >= cost;

  /// Redeems a store item: unlocks a skin or stacks a consumable.
  bool redeem(StoreItem item) {
    if (!canAfford(item.cost)) return false;
    if (item.type == StoreItemType.diceSkin && _ownedSkinIds.contains(item.id)) {
      return false; // already owned
    }
    _coins -= item.cost;
    if (item.type == StoreItemType.diceSkin) {
      _ownedSkinIds.add(item.id);
      _activeSkinId = item.id;
    } else {
      _inventory[item.id] = (_inventory[item.id] ?? 0) + 1;
    }
    notifyListeners();
    return true;
  }

  void equipSkin(String skinId) {
    if (!_ownedSkinIds.contains(skinId)) return;
    _activeSkinId = skinId;
    notifyListeners();
  }

  /// Mocked purchase flow triggered from the paywall modal.
  void unlockPro() {
    _isPro = true;
    notifyListeners();
  }

  /// Debug/demo helper to top the scan credits back up (e.g. new day).
  void resetDailyScans() {
    _scanCredits = maxScanCredits;
    notifyListeners();
  }

  /// Loads persisted Gemini API keys from secure storage. Call once at
  /// startup, before the first frame, so Settings shows saved keys right
  /// away.
  Future<void> init() async {
    try {
      final storedKeys = await _secureStorage.read(key: _geminiKeysStorageKey);
      if (storedKeys != null && storedKeys.isNotEmpty) {
        final decoded = (jsonDecode(storedKeys) as List<dynamic>).cast<String>();
        _geminiApiKeys
          ..clear()
          ..addAll(decoded);
      }
      final storedIndex = await _secureStorage.read(key: _geminiActiveIndexStorageKey);
      if (storedIndex != null) {
        _activeGeminiKeyIndex = int.tryParse(storedIndex) ?? 0;
      }
    } catch (e) {
      // Secure storage can be unavailable (e.g. a locked keyring on desktop
      // Linux, or a first-run platform quirk). Degrade to "no saved keys"
      // rather than blocking app startup entirely.
      debugPrint('AppState.init: could not read secure storage: $e');
    }
    if (_geminiApiKeys.isEmpty || _activeGeminiKeyIndex >= _geminiApiKeys.length) {
      _activeGeminiKeyIndex = 0;
    }
    notifyListeners();
  }

  Future<void> _persistGeminiKeys() async {
    try {
      await _secureStorage.write(key: _geminiKeysStorageKey, value: jsonEncode(_geminiApiKeys));
    } catch (e) {
      debugPrint('AppState: could not persist Gemini API keys: $e');
    }
  }

  Future<void> _persistActiveGeminiIndex() async {
    try {
      await _secureStorage.write(
        key: _geminiActiveIndexStorageKey,
        value: '$_activeGeminiKeyIndex',
      );
    } catch (e) {
      debugPrint('AppState: could not persist active Gemini key index: $e');
    }
  }

  /// Adds a Gemini API key to the fallback pool (persisted to secure
  /// storage). Returns false if the key is blank or already added.
  Future<bool> addGeminiApiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty || _geminiApiKeys.contains(trimmed)) return false;
    _geminiApiKeys.add(trimmed);
    await _persistGeminiKeys();
    notifyListeners();
    return true;
  }

  /// Removes a key from the pool, adjusting the active index if needed.
  Future<void> removeGeminiApiKey(int index) async {
    if (index < 0 || index >= _geminiApiKeys.length) return;
    _geminiApiKeys.removeAt(index);
    if (_activeGeminiKeyIndex >= _geminiApiKeys.length) {
      _activeGeminiKeyIndex = _geminiApiKeys.isEmpty ? 0 : _geminiApiKeys.length - 1;
    }
    await _persistGeminiKeys();
    await _persistActiveGeminiIndex();
    notifyListeners();
  }

  /// Called after a successful Gemini call so future requests start from
  /// whichever key actually worked, skipping straight past exhausted ones
  /// instead of retrying them every time.
  void reportWorkingGeminiKeyIndex(int index) {
    if (index == _activeGeminiKeyIndex || index < 0 || index >= _geminiApiKeys.length) return;
    _activeGeminiKeyIndex = index;
    _persistActiveGeminiIndex();
    notifyListeners();
  }
}

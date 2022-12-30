import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

class MetamaskProvider extends ChangeNotifier {
  static const operatingChain = 4;

  String currentAddress = '';

  int currentChain = -1;

  bool get isEnabled => ethereum != null;

  bool get isInOperatingChain => currentChain == operatingChain;

  bool get isConnected => isEnabled && currentAddress.isNotEmpty;

  var account = "";

  Future<void> connect() async {
    if (isEnabled) {
      final accs = await ethereum!.requestAccount();

      account = accs[0];

      if (account.isNotEmpty) currentAddress = accs.first;
      currentChain = await ethereum!.getChainId();
      final balance = await provider!.getBalance(account);
      notifyListeners();
    }
  }

  clear() {
    currentAddress = '';
    currentChain = -1;
  }

  init() {
    if (isEnabled) {
      ethereum!.onAccountsChanged((accounts) {
        clear();
      });
      ethereum!.onChainChanged((accounts) {
        clear();
      });
    }
  }
}

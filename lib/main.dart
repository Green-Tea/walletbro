import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walletbro/screens/home_screen.dart';
import 'package:walletbro/screens/scan_qr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalletBro',
      home: HomeScreen(storage: BillerStorage()),
      routes: {
        '/home': (context) => HomeScreen(storage: BillerStorage()),
        '/scan': (context) => const ScanQr()
      },
    );
  }
}

class BillerStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/biller_data.json');
  }

  Future<Map<String, List<String>>> readBillerData() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        return {};
      }

      final contents = await file.readAsString();
      final decodedData = json.decode(contents);

      // Verify if the decoded data is a Map with String keys and List<String> values
      if (decodedData is Map<String, dynamic>) {
        return decodedData
            .map((key, value) => MapEntry(key, List<String>.from(value)));
      } else {
        return {};
      }
    } catch (e) {
      print("ERROR READING FILE: $e");
      return {};
    }
  }

  Future<void> writeBillerData(Map<String, List<String>> data) async {
    try {
      final file = await _localFile;
      final encodedData = json.encode(data);
      await file.writeAsString(encodedData);
    } catch (e) {
      print("ERROR WRITING TO FILE: $e");
    }
  }

  Future<void> clearBillerIdJsonFile() async {
    try {
      final file = await _localFile;

      // Clear the content of the file
      await file.writeAsString('');
    } catch (e) {
      print("ERROR CLEARING FILE: $e");
    }
  }
}

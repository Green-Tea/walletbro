import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.storage});

  final BillerStorage storage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? imagePath;
  final picker = ImagePicker();
  int _currentIndex = 0;
  Set<String> uniqueBillerIDs = <String>{};
  List<String> categories = [
    "Electricity",
    "Water",
    "Spotify",
    "Eat Out/Order",
    "Drinks",
    "Food Stalls",
    "Snacks",
    "Groceries",
    "Motorbike",
    "Taxi",
    "Train/Bus",
    "Utilities",
    "Weed",
    "Vape",
    "Alcohol",
    "Game Topup",
    "Others"
  ];
  late final List<String> _readBillers = [];
  List<String> _parsedText = [];
  String _billerId = "";
  String _amount = "";
  String _date = "";
  late Map<String, List<String>> _billerData;

  @override
  void initState() {
    super.initState();
    _loadBillerData();
  }

  Future<void> _loadBillerData() async {
    await widget.storage.readBillerData().then((value) => setState(() {
          _billerData = value;
        }));
  }

  Future<void> processImageAndReadText() async {
    if (imagePath != null) {
      List<String> result = await readTextFromImage();
      setState(() {
        _parsedText = result;
      });
    }
  }

  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  List<String> parseText(String text) {
    List<String> lines = text.split("\n");
    String biller = "";
    for (String line in lines) {
      try {
        if (line.length >= 10 && line.substring(0, 10) == "Biller ID:") {
          List<String> splitted = line.split(":");
          biller =
              splitted[1].trim(); // Remove leading and trailing whitespaces
        }
      } catch (e) {
        print("ERROR PARSING TEXT: $e");
        break;
      }
    }

    String amount =
        lines.last.trim(); // Remove leading and trailing whitespaces
    var date = lines[5].split(" ");
    date.removeRange(3, 5);
    print(text);
    print("BILLER ID: $biller\nAMOUNT: $amount\nDATE: $date");

    setState(() {
      _billerId = biller;
      _amount = amount;
      _date = date.join(", ");
    });

    return [biller, amount, date.join(", ")];
  }

  Future<List<String>> readTextFromImage() async {
    final inputImage = InputImage.fromFilePath(imagePath!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;

    textRecognizer.close();

    if (text.isEmpty) return [];

    List<String> parsedText = parseText(text);
    uniqueBillerIDs.add(parsedText[0]);

    return parsedText;
  }

  void navigateToScanScreen() {
    setState(() {
      _currentIndex = 1;
      Navigator.pushNamed(context, '/scan');
    });
  }

  Future<void> clearBillerIds() async {
    await widget.storage.clearBillerIdJsonFile();
    setState(() {
      uniqueBillerIDs.clear();
      _readBillers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Saved Biller IDs: $uniqueBillerIDs',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Biller ID: ${_parsedText.isNotEmpty ? _parsedText[0] : ''}',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              'Amount: ${_parsedText.isNotEmpty ? _parsedText[1] : ''}',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              'Date: ${_parsedText.isNotEmpty ? _parsedText[2] : ''}',
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await pickImageFromGallery();
              await processImageAndReadText();
              widget.storage.writeBillerData(_billerData);
            },
            tooltip: 'Pick Image',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: clearBillerIds,
            tooltip: 'Clear Biller IDs',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Pick Image"),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_outlined),
            label: "Scan QR",
          )
        ],
        onTap: (index) {
          navigateToScanScreen();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({Key? key}) : super(key: key);

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String? imagePath;
  final picker = ImagePicker();
  int _currentIndex = 1;
  String qrcode = 'Unknown';

  Future pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
      String? str = await Scan.parse(imagePath!);
      if (str != null) {
        setState(() {
          qrcode = str;
        });
      }
    }
    print("SCAN RESULT: $qrcode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => pickImageFromGallery(),
        tooltip: 'Pick Image',
        child: const Icon(Icons.document_scanner_outlined),
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
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              Navigator.pushNamed(context, '/home');
            }
          });
        },
      ),
    );
  }
}

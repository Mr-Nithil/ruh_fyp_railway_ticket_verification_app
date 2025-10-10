import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/qr_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() {
          isScanned = true;
        });

        // Stop scanning
        cameraController.stop();

        // Navigate to result screen with the QR data
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => QRResultScreen(qrData: code)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Ticket QR Code',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Overlay with scanning frame
          CustomPaint(painter: ScannerOverlay(), child: Container()),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Position QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Flash toggle button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => cameraController.toggleTorch(),
                      iconSize: 32,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final centerSquareSize = size.width * 0.7;
    final left = (size.width - centerSquareSize) / 2;
    final top = (size.height - centerSquareSize) / 2;

    // Draw dark overlay with transparent center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, centerSquareSize, centerSquareSize),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final bracketLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + bracketLength),
      Offset(left, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + centerSquareSize - bracketLength, top),
      Offset(left + centerSquareSize, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + centerSquareSize, top),
      Offset(left + centerSquareSize, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + centerSquareSize - bracketLength),
      Offset(left, top + centerSquareSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top + centerSquareSize),
      Offset(left + bracketLength, top + centerSquareSize),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + centerSquareSize - bracketLength, top + centerSquareSize),
      Offset(left + centerSquareSize, top + centerSquareSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + centerSquareSize, top + centerSquareSize - bracketLength),
      Offset(left + centerSquareSize, top + centerSquareSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

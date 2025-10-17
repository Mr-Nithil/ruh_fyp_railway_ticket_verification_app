import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/firestore_service.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/permission_service.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/qr_scanner_screen.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/shared_preferences_service.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/schedule/train_selection_popup.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<Map<String, dynamic>?> userData = FirestoreService()
      .getUserData();
  final PermissionService _permissionService = PermissionService();
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  bool _permissionChecked = false;
  bool _hasSelectedTrain = false;
  String? _selectedTrainName;

  @override
  void initState() {
    super.initState();
    _checkCameraPermissionOnLoad();
    _loadSelectedTrain();
  }

  Future<void> _loadSelectedTrain() async {
    final hasSelected = await _prefsService.hasSelectedSchedule();
    final trainName = await _prefsService.getSelectedTrainName();

    if (mounted) {
      setState(() {
        _hasSelectedTrain = hasSelected;
        _selectedTrainName = trainName;
      });
    }
  }

  Future<void> _checkCameraPermissionOnLoad() async {
    // Get current permission status WITHOUT requesting
    final status = await Permission.camera.status;

    // Only show dialog if permission was explicitly denied or permanently denied
    // Don't show on first visit (when status is undetermined/notAsked)
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionInfoBanner();
      }
    }

    setState(() {
      _permissionChecked = true;
    });
  }

  void _showPermissionInfoBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Camera permission required for ticket scanning',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Enable',
          textColor: Colors.white,
          onPressed: () {
            _permissionService.openSettings();
          },
        ),
      ),
    );
  }

  Future<void> _handleVerifyTicket() async {
    // Check if train is selected
    if (!_hasSelectedTrain) {
      _showTrainNotSelectedDialog();
      return;
    }

    // Check and request camera permission WITHOUT showing loading dialog
    // This allows the system permission dialog to appear
    final hasPermission = await _permissionService
        .checkAndRequestCameraPermission();

    if (hasPermission) {
      // Permission granted, open scanner
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const QRScannerScreen()),
        );
      }
    } else {
      // Permission denied - check if permanently denied
      final status = await Permission.camera.status;

      if (mounted) {
        if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog();
        } else if (status.isDenied) {
          // User just denied - show a snackbar instead of full dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Camera permission is required to scan tickets',
              ),
              action: SnackBarAction(
                label: 'Grant',
                onPressed: () {
                  _handleVerifyTicket(); // Try again
                },
              ),
            ),
          );
        }
      }
    }
  }

  void _showTrainNotSelectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.train, color: Colors.orange),
            SizedBox(width: 10),
            Text('Train Not Selected'),
          ],
        ),
        content: const Text(
          'Please select a train schedule before scanning tickets. Tap the "Select Train" button to choose a train.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTrainSelectionPopup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select Train'),
          ),
        ],
      ),
    );
  }

  void _showTrainSelectionPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TrainSelectionPopup(
        onTrainSelected: () {
          _loadSelectedTrain();
        },
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.orange),
            SizedBox(width: 10),
            Text('Camera Permission Required'),
          ],
        ),
        content: const Text(
          'Camera access is required to scan QR codes. Please grant camera permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _permissionService.openSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Background Image with Overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/home.jpg",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Text Content
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sri Lanka Railways',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ticket Verification System',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black38,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Fast, Secure & Reliable',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // User Status Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: userData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  } else if (snapshot.hasError) {
                    return _buildUserCard("Guest User", "Unknown", "Offline");
                  } else {
                    final name = snapshot.data?['name'] ?? "Guest User";
                    final checkerId = snapshot.data?['checkerId'] ?? "N/A";
                    return _buildUserCard(name, checkerId, "On Duty");
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Selected Train Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: _buildSelectedTrainCard(),
            ),

            const SizedBox(height: 20),

            // Quick Actions Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Feature Buttons Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureButton(
                        icon: Icons.train,
                        label: 'Select Train',
                        onTap: _showTrainSelectionPopup,
                        //color: Colors.blue,
                      ),
                      _buildFeatureButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Ticket',
                        onTap: _handleVerifyTicket,
                        isDisabled: !_hasSelectedTrain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureButton(
                        icon: Icons.list_alt,
                        label: 'Ticket List',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ticket List coming soon!'),
                            ),
                          );
                        },
                      ),
                      _buildFeatureButton(
                        icon: Icons.analytics,
                        label: 'Reports',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reports coming soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(String name, String checkerId, String status) {
    final bool isOnDuty = status.toLowerCase() == 'on duty';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'ID: $checkerId',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOnDuty ? Colors.green : Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTrainCard() {
    return GestureDetector(
      onTap: _showTrainSelectionPopup,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hasSelectedTrain
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.orange.shade50, Colors.orange.shade100],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasSelectedTrain
                ? Colors.green.shade300
                : Colors.orange.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _hasSelectedTrain ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _hasSelectedTrain ? Icons.train : Icons.warning_amber,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasSelectedTrain ? 'Selected Train' : 'No Train Selected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hasSelectedTrain
                        ? (_selectedTrainName ?? 'Unknown Train')
                        : 'Tap to select a train',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _hasSelectedTrain
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isDisabled = false,
  }) {
    // Get gradient colors based on the button color
    List<Color> getGradientColors() {
      if (color == Colors.blue) {
        return [Colors.blue.shade400, Colors.blue.shade600];
      }
      return [Colors.green.shade400, Colors.green.shade600];
    }

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: getGradientColors(),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                if (isDisabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Select train first',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

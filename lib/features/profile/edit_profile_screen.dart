import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _checkerIdController = TextEditingController();
  final _firestoreService = FirestoreService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _nameController.text = widget.userData['name'] ?? '';
    _nicController.text = widget.userData['nic'] ?? '';
    _checkerIdController.text = widget.userData['checkerId'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _checkerIdController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateNIC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your NIC';
    }
    // NIC validation for Sri Lankan NIC format
    // Old format: 9 digits + V (e.g., 123456789V)
    // New format: 12 digits (e.g., 199012345678)
    final nicRegex = RegExp(r'^(\d{9}[vVxX]|\d{12})$');
    if (!nicRegex.hasMatch(value.trim())) {
      return 'Please enter a valid NIC (9 digits + V or 12 digits)';
    }
    return null;
  }

  String? _validateCheckerId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Checker ID';
    }
    if (value.trim().length < 3) {
      return 'Checker ID must be at least 3 characters';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Prepare updates
      final updates = {
        'name': _nameController.text.trim(),
        'nic': _nicController.text.trim().toUpperCase(),
        'checkerId': _checkerIdController.text.trim(),
      };

      // Update Firestore
      await _firestoreService.updateUserDocument(
        uid: user.uid,
        updates: updates,
      );

      // Update Firebase Auth display name if changed
      if (updates['name'] != user.displayName) {
        await user.updateDisplayName(updates['name']);
        await user.reload();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Return true to indicate successful update
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // appBar: AppBar(
        //   title: const Text(
        //     'Edit Profile',
        //     style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        //   ),
        //   backgroundColor: Colors.green.shade700,
        //   foregroundColor: Colors.white,
        //   elevation: 0,
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/profile.jpg",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Header Section
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.green.shade700,
                      //       Colors.green.shade500,
                      //     ],
                      //   ),
                      // ),
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Update Your Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Edit your personal details below',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //const SizedBox(height: 28),

              // Form Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email (Read-only)
                      _buildReadOnlyField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: widget.userData['email'] ?? 'Not available',
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      _buildTextField(
                        controller: _nameController,
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        validator: _validateName,
                        iconColor: Colors.green,
                      ),
                      const SizedBox(height: 20),

                      // NIC Field
                      _buildTextField(
                        controller: _nicController,
                        icon: Icons.badge_outlined,
                        label: 'NIC Number',
                        hint:
                            'Enter your NIC (e.g., 123456789V or 199012345678)',
                        validator: _validateNIC,
                        iconColor: Colors.orange,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 20),

                      // Checker ID Field
                      _buildTextField(
                        controller: _checkerIdController,
                        icon: Icons.verified_user_outlined,
                        label: 'Checker ID',
                        hint: 'Enter your Checker ID',
                        validator: _validateCheckerId,
                        iconColor: Colors.purple,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Cancel Button
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.lock_outline,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required Color iconColor,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: iconColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

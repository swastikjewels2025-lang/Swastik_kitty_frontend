import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/providers/auth_state_provider.dart';

/// Shows the unified Edit Profile dialog across Hamburger Menu and Post-KYC Screen.
Future<void> showEditProfileDialog(
  BuildContext context, {
  AppAuthState? authState,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => EditProfileDialog(initialAuthState: authState),
  );
}

/// Unified Edit Profile Dialog with borderless input fields and photo change support.
class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key, this.initialAuthState});

  final AppAuthState? initialAuthState;

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _phoneController;
  String? _photoPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final AppAuthState auth = widget.initialAuthState ?? ref.read(appAuthStateProvider);
    final List<String> parts = auth.userName.trim().split(' ');
    final String firstName = parts.isNotEmpty ? parts.first : '';
    final String surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    _nameController = TextEditingController(text: firstName);
    _surnameController = TextEditingController(text: surname);
    _phoneController = TextEditingController(text: auth.userPhone);
    _photoPath = auth.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final String fullName = surname.isNotEmpty ? '$name $surname' : name;

    await ref.read(appAuthStateProvider.notifier).updateProfile(
      userName: fullName,
      userPhone: phone,
      photoPath: _photoPath,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF063B2C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppAuthState authState = ref.watch(appAuthStateProvider);
    final String initialLetter = authState.userName.trim().isNotEmpty
        ? authState.userName.trim()[0].toUpperCase()
        : 'S';

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Edit Profile',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A2120),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6E7876)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Update your personal information below',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E7876),
              ),
            ),

            const SizedBox(height: 16),

            // Profile Photo / Avatar with Upload action
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFF063B2C), Color(0xFF0F5A44)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _photoPath != null && _photoPath!.isNotEmpty
                            ? (kIsWeb
                                ? Image.network(
                                    _photoPath!,
                                    fit: BoxFit.cover,
                                    width: 68,
                                    height: 68,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildInitialAvatar(initialLetter),
                                  )
                                : Image.file(
                                    io.File(_photoPath!),
                                    fit: BoxFit.cover,
                                    width: 68,
                                    height: 68,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildInitialAvatar(initialLetter),
                                  ))
                            : _buildInitialAvatar(initialLetter),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF063B2C),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Tap to change photo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF063B2C),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name Field (Borderless input)
            _buildField(
              label: 'First Name',
              controller: _nameController,
              hint: 'Enter your name',
            ),

            const SizedBox(height: 12),

            // Surname Field (Borderless input)
            _buildField(
              label: 'Surname',
              controller: _surnameController,
              hint: 'Enter your surname',
            ),

            const SizedBox(height: 12),

            // Mobile Number Field (Borderless input)
            _buildField(
              label: 'Mobile Number',
              controller: _phoneController,
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            // Actions Row
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A2120),
                      side: const BorderSide(color: Color(0xFFEFE7DA)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF063B2C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String initialLetter) {
    return Center(
      child: Text(
        initialLetter,
        style: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A2120),
          ),
        ),
        const SizedBox(height: 5),
        // Container background with ZERO border
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2120),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: const Color(0xFFA8B2B0),
              ),
              // All border styles strictly set to none
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
      ],
    );
  }
}

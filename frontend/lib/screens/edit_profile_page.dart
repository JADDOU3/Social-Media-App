import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/profile_picture_service.dart';
import '../services/user_service.dart';
import '../utils/app_color.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;
  final UserService userService;
  final ProfilePictureService profilePictureService;

  const EditProfilePage({
    Key? key,
    required this.user,
    required this.userService,
    required this.profilePictureService,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final UserService userService;
  late final ProfilePictureService profilePictureService;
  late UserProfile user;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _newImageFile;
  Uint8List? _newImageBytes;
  String? _newImageFilename;
  String? _profileImage;
  Uint8List? _currentProfileImageBytes;
  bool _profileImageChanged = false;
  bool _profileImageDeleted = false;
  bool _isLoadingImage = true;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController bioController;
  late TextEditingController jobController;
  late TextEditingController locationController;
  late TextEditingController phoneController;
  late TextEditingController dateOfBirthController;

  String? genderValue;
  String? socialSituationValue;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    user = widget.user;
    userService = widget.userService;
    profilePictureService = widget.profilePictureService;

    nameController = TextEditingController(text: user.name ?? "");
    emailController = TextEditingController(text: user.email ?? "");
    bioController = TextEditingController(text: user.bio ?? "");
    jobController = TextEditingController(text: user.job ?? "");
    locationController = TextEditingController(text: user.location ?? "");
    phoneController = TextEditingController(text: user.phoneNumber ?? "");
    dateOfBirthController = TextEditingController(
      text: user.dateOfBirth != null ? user.dateOfBirth!.split("T")[0] : "",
    );

    genderValue = user.gender;
    socialSituationValue = user.socialSituation;
    _profileImage = user.profilePicture;

    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
      try {
        final imageBytes = await profilePictureService.getProfilePicture();
        if (mounted && imageBytes != null) {
          setState(() {
            _currentProfileImageBytes = imageBytes;
            _isLoadingImage = false;
          });
        } else {
          // Image doesn't exist or returned null
          if (mounted) {
            setState(() {
              _isLoadingImage = false;
              _currentProfileImageBytes = null;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingImage = false;
            _currentProfileImageBytes = null;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
          _currentProfileImageBytes = null;
        });
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _newImageBytes = bytes;
        _newImageFilename = picked.name;
        _profileImageChanged = true;
        _profileImageDeleted = false;
        _currentProfileImageBytes = null;
        if (!kIsWeb) {
          _newImageFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate =
        DateTime.tryParse(dateOfBirthController.text) ?? DateTime(2000);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightCardBackground,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateOfBirthController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _removeProfilePicture() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              "Remove Profile Picture",
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove your profile picture?",
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Remove",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Call backend to delete
      await profilePictureService.deleteProfilePicture();

      // Update UI state
      setState(() {
        _newImageFile = null;
        _newImageBytes = null;
        _newImageFilename = null;
        _profileImage = null;
        _currentProfileImageBytes = null;
        _profileImageChanged = true;
        _profileImageDeleted = true;
      });

      // SUCCESS NOTIFICATION
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile picture removed successfully"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // FAILURE NOTIFICATION
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove profile picture: $e"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_profileImageChanged) {
        try {
          if (_profileImageDeleted) {
            if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
              try {
                await profilePictureService.deleteProfilePicture();
              } catch (e) {
                if (!e.toString().contains('404')) {
                  rethrow;
                }
              }
            }
          } else if (_newImageBytes != null && _newImageFilename != null) {
            if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
              try {
                await profilePictureService.updateProfilePicture(
                  _newImageBytes!,
                  _newImageFilename!,
                );
              } catch (e) {
                if (e.toString().contains('404')) {
                  await profilePictureService.uploadProfilePicture(
                    _newImageBytes!,
                    _newImageFilename!,
                  );
                } else {
                  rethrow;
                }
              }
            } else {
              await profilePictureService.uploadProfilePicture(
                _newImageBytes!,
                _newImageFilename!,
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error updating profile picture: $e"),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      // Update user profile
      final updatedUser = user.copyWith(
        name: nameController.text.isNotEmpty ? nameController.text : null,
        email: emailController.text.isNotEmpty ? emailController.text : null,
        bio: bioController.text.isNotEmpty ? bioController.text : null,
        job: jobController.text.isNotEmpty ? jobController.text : null,
        location: locationController.text.isNotEmpty ? locationController.text : null,
        phoneNumber: phoneController.text.isNotEmpty ? phoneController.text : null,
        gender: genderValue,
        dateOfBirth: dateOfBirthController.text.isNotEmpty
            ? dateOfBirthController.text
            : null,
        socialSituation: socialSituationValue,
      );

      await userService.updateFullProfile(updatedUser);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: $e"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() => _isSaving = false);
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.lightCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Change Password",
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // OLD PASSWORD
                  TextFormField(
                    controller: oldPasswordController,
                    obscureText: obscureOld,
                    style: TextStyle(color: AppColors.lightTextPrimary),
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      labelStyle: TextStyle(color: AppColors.lightTextSecondary),
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOld ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.lightTextSecondary,
                        ),
                        onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your current password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // NEW PASSWORD
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    style: TextStyle(color: AppColors.lightTextPrimary),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: TextStyle(color: AppColors.lightTextSecondary),
                      prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.lightTextSecondary,
                        ),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a new password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CONFIRM NEW PASSWORD
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    style: TextStyle(color: AppColors.lightTextPrimary),
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      labelStyle: TextStyle(color: AppColors.lightTextSecondary),
                      prefixIcon: Icon(Icons.lock_clock, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.lightTextSecondary,
                        ),
                        onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.error, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your new password";
                      }
                      if (value != newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (!formKey.currentState!.validate()) return;

                setDialogState(() => isLoading = true);

                try {
                  await userService.changePassword(
                    oldPassword: oldPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Password changed successfully"),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.lightCardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Error",
                                style: TextStyle(
                                  color: AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          e.toString().replaceAll('Exception: ', '').replaceAll('Failed to change password: ', ''),
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Change Password",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: AppColors.lightCardBackground,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // PROFILE IMAGE
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppColors.lightCardBackground,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 16),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightDivider,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: Icon(
                                    Icons.photo_library,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    "Gallery",
                                    style: TextStyle(
                                      color: AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    pickImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    "Remove profile image",
                                    style: TextStyle(
                                      color: AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Future.delayed(Duration(milliseconds: 150), () {
                                      _removeProfilePicture();
                                    });
                                  },

                                ),
                                if (_profileImage != null || _newImageBytes != null || _currentProfileImageBytes != null)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                    ),
                                    title: const Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _removeProfilePicture();
                                    },
                                  ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: _isLoadingImage
                                    ? Container(
                                  color: AppColors.lightBackground,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                    : (_newImageBytes != null
                                    ? Image.memory(_newImageBytes!, fit: BoxFit.cover)
                                    : (_currentProfileImageBytes != null
                                    ? Image.memory(_currentProfileImageBytes!, fit: BoxFit.cover)
                                    : Container(
                                  color: AppColors.lightBackground,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.lightTextSecondary,
                                  ),
                                ))),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // NAME
                    _buildTextField(
                      controller: nameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // EMAIL (Read-only)
                    _buildTextField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // PHONE
                    _buildTextField(
                      controller: phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // JOB
                    _buildTextField(
                      controller: jobController,
                      label: "Job",
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 16),

                    // LOCATION
                    _buildTextField(
                      controller: locationController,
                      label: "Location",
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // BIO
                    _buildTextField(
                      controller: bioController,
                      label: "Bio",
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // GENDER DROPDOWN
                    _buildDropdown(
                      value: genderValue,
                      label: "Gender",
                      icon: Icons.wc_outlined,
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(value: "Female", child: Text("Female")),
                      ],
                      onChanged: (value) => setState(() => genderValue = value),
                    ),
                    const SizedBox(height: 16),

                    // SOCIAL SITUATION DROPDOWN
                    _buildDropdown(
                      value: socialSituationValue,
                      label: "Social Situation",
                      icon: Icons.favorite_outline,
                      items: const [
                        DropdownMenuItem(value: "Single", child: Text("Single")),
                        DropdownMenuItem(value: "Married", child: Text("Married")),
                        DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
                      ],
                      onChanged: (value) => setState(() => socialSituationValue = value),
                    ),
                    const SizedBox(height: 16),

                    // DATE OF BIRTH
                    _buildTextField(
                      controller: dateOfBirthController,
                      label: "Date of Birth",
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 32),

                    // CHANGE PASSWORD BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        icon: Icon(Icons.lock_outline, color: AppColors.primary),
                        label: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      style: TextStyle(
        color: enabled ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.lightTextSecondary,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.lightTextLight,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.lightTextSecondary,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: AppColors.lightCardBackground,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    jobController.dispose();
    locationController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }
}
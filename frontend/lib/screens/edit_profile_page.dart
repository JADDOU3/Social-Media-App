import 'dart:io';
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
  String? _profileImage;

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
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
        _profileImage = picked.path;
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
    );
    if (picked != null) {
      setState(() {
        dateOfBirthController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

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
      profilePicture: _profileImage,
    );

    try {
      await userService.updateFullProfile(updatedUser);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // PROFILE IMAGE
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text("Gallery"),
                            onTap: () {
                              pickImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text("Camera"),
                            onTap: () {
                              pickImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                          if (_profileImage != null)
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text("Remove"),
                              onTap: () {
                                setState(() {
                                  _newImageFile = null;
                                  _profileImage = null;
                                });
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _newImageFile != null
                            ? Image.file(_newImageFile!, fit: BoxFit.cover)
                            : (_profileImage != null
                            ? Image.network(_profileImage!, fit: BoxFit.cover)
                            : Image.asset("assets/default_avatar.png", fit: BoxFit.cover)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.camera_alt, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              const SizedBox(height: 10),

              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),

              // PHONE
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              const SizedBox(height: 10),

              // JOB
              TextFormField(
                controller: jobController,
                decoration: const InputDecoration(labelText: "Job"),
              ),
              const SizedBox(height: 10),

              // LOCATION
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 10),

              // BIO
              TextFormField(
                controller: bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              // GENDER DROPDOWN
              DropdownButtonFormField<String>(
                value: genderValue,
                decoration: const InputDecoration(labelText: "Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) => setState(() => genderValue = value),
              ),
              const SizedBox(height: 10),

              // SOCIAL SITUATION DROPDOWN
              DropdownButtonFormField<String>(
                value: socialSituationValue,
                decoration:
                const InputDecoration(labelText: "Social Situation"),
                items: const [
                  DropdownMenuItem(value: "Single", child: Text("Single")),
                  DropdownMenuItem(value: "Married", child: Text("Married")),
                  DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
                ],
                onChanged: (value) =>
                    setState(() => socialSituationValue = value),
              ),
              const SizedBox(height: 10),

              // DATE OF BIRTH
              TextFormField(
                controller: dateOfBirthController,
                decoration: const InputDecoration(
                    labelText: "Date of Birth (YYYY-MM-DD)"),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

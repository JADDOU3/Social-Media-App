import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/password_field.dart';
import '../widgets/custom_text_field.dart';
import '../utils/snackbar_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  final _job = TextEditingController();
  final _phone = TextEditingController();
  final _birthdate = TextEditingController();

  String? _selectedGender;
  String? _selectedSocialSituation;
  bool _loading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdate.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _handleRegister(AuthService authService) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'email': _email.text.trim(),
      'password': _password.text.trim(),
      'name': _name.text.trim().isEmpty ? null : _name.text.trim(),
      'job': _job.text.trim().isEmpty ? null : _job.text.trim(),
      'phoneNumber': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'gender': _selectedGender,
      'dateOfBirth': _birthdate.text.trim().isEmpty ? null : _birthdate.text.trim(),
      'socialSituation': _selectedSocialSituation,
    };

    try {
      await authService.register(data);
      if (mounted) {
        showSuccessSnackbar(context, "Account created successfully!");
        context.go('/login');
      }
    } catch (e) {
      showErrorSnackbar(context, e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final localStorage = Provider.of<LocalStorageService>(context, listen: false);
    final authService = AuthService(apiService, localStorage);

    return Scaffold(
      backgroundColor: const Color(0xFFAF92D7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: Colors.white.withOpacity(0.9),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(controller: _name, label: "Full Name"),
                    const SizedBox(height: 12),
                    CustomTextField(
                        controller: _email,
                        label: "Email",
                        validator: Validators.validateEmail),
                    const SizedBox(height: 12),
                    PasswordField(
                        controller: _password,
                        label: "Password",
                        validator: Validators.validatePassword),
                    const SizedBox(height: 12),
                    PasswordField(
                        controller: _confirm,
                        label: "Confirm Password",
                        validator: (v) =>
                            Validators.validateConfirmPassword(_password.text, v)),
                    const SizedBox(height: 12),

                    const Text("Gender (optional):"),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Male"),
                          selected: _selectedGender == "Male",
                          onSelected: (v) =>
                              setState(() => _selectedGender = v ? "Male" : null),
                          selectedColor: const Color(0xFFAF92D7).withOpacity(0.3),
                        ),
                        ChoiceChip(
                          label: const Text("Female"),
                          selected: _selectedGender == "Female",
                          onSelected: (v) =>
                              setState(() => _selectedGender = v ? "Female" : null),
                          selectedColor: const Color(0xFFAF92D7).withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(controller: _job, label: "Job (optional)"),
                    const SizedBox(height: 12),
                    CustomTextField(controller: _phone, label: "Phone Number (optional)"),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: CustomTextField(
                            controller: _birthdate, label: "Birthdate (optional)"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Social Situation (optional):"),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var status
                        in ["Single", "Married", "Widowed", "Divorced"])
                          ChoiceChip(
                            label: Text(status),
                            selected: _selectedSocialSituation == status,
                            onSelected: (v) => setState(() =>
                            _selectedSocialSituation = v ? status : null),
                            selectedColor:
                            const Color(0xFFAF92D7).withOpacity(0.3),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _loading ? null : () => _handleRegister(authService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAF92D7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign Up"),
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
}

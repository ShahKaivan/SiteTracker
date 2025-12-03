import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../core/app_spacing.dart';
import '../core/app_styles.dart';
import '../services/auth_service.dart';
import '../services/toast_service.dart';
import '../utils/constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // State variables
  String _selectedCountryCode = Constants.defaultCountryCode;
  String _selectedRole = 'worker';
  File? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<String> _countryCodes = ['+91', '+1', '+44', '+61', '+81', '+86'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final int fileSize = await imageFile.length();
        
        // Check file size (5MB max)
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ToastService.showError(context, 'Image size must be less than 5MB');
          }
          return;
        }

        setState(() {
          _profileImage = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mobile number must contain only digits';
    }
    if (value.length < 10 || value.length > 15) {
      return 'Mobile number must be 10-15 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain both letters and numbers';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        fullName: _fullNameController.text.trim(),
        countryCode: _selectedCountryCode,
        mobileNumber: _mobileController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        profileImagePath: _profileImage?.path,
      );

      if (mounted) {
        if (result['success'] == true) {
          ToastService.showSuccess(context, 'Registration successful! Please login.');
          Navigator.of(context).pop(); // Go back to login screen
        } else {
          ToastService.showError(
            context,
            result['message'] as String? ?? 'Registration failed',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                
                // Title
                Text(
                  'Create Account',
                  style: AppStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Fill in your details to register',
                  style: AppStyles.bodyTextSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Profile Image Upload
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.textOnPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Profile Picture (Optional)',
                  style: AppStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: _validateFullName,
                ),
                const SizedBox(height: AppSpacing.md),

                // Country Code and Mobile Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Code Dropdown
                    SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountryCode,
                        decoration: InputDecoration(
                          labelText: 'Code',
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSM,
                          ),
                        ),
                        items: _countryCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Mobile Number
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: 'Enter mobile number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusSM,
                          ),
                        ),
                        validator: _validateMobileNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Role Selection
                Text(
                  'Select Role',
                  style: AppStyles.bodyTextBold,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppSpacing.borderRadiusSM,
                  ),
                  padding: AppSpacing.paddingSM,
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Worker'),
                        value: 'worker',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: const Text('Site-Coordinator'),
                        value: 'site_coordinator',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Register',
                          style: AppStyles.buttonText,
                        ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Back to Login
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Back to Login'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

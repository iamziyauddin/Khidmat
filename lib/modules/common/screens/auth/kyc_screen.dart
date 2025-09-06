import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../local_db/models/user_model.dart';
import '../../../../routing/app_router.dart';
import '../../../../services/database_service.dart';
import '../../../../ui/theme/app_theme.dart';

class KycScreen extends ConsumerStatefulWidget {
  final String userRole;

  const KycScreen({super.key, required this.userRole});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile photo.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phone =
          GoRouterState.of(context).uri.queryParameters['phone'] ?? '';
      final role = widget.userRole == 'applicant'
          ? UserRole.applicant
          : UserRole.donor;

      final user = UserModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        phone: phone,
        age: int.parse(_ageController.text),
        city: _cityController.text.trim(),
        photoPath: _selectedImage?.path,
        role: role,
        isVerified: false, // Admin verification needed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to database
      await DatabaseService.instance.saveUser(user);
      await DatabaseService.instance.setCurrentUser(user.id);

      if (mounted) {
        // Navigate to appropriate dashboard
        if (role == UserRole.applicant) {
          context.go(AppRouter.applicantDashboard);
        } else {
          context.go(AppRouter.donorDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating account: $e'),
            backgroundColor: AppTheme.error,
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Tell Us About Yourself',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'This information helps build a trustworthy community.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),

                const SizedBox(height: 32),

                // Profile Photo
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryTeal.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    LucideIcons.camera,
                                    size: 40,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _showImagePickerOptions,
                        icon: const Icon(LucideIcons.edit),
                        label: Text(
                          _selectedImage != null
                              ? 'Change Photo'
                              : 'Upload Photo *',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Name Field
                Text(
                  'Full Name *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(LucideIcons.user),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Age & City Fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Age *',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g., 25',
                              prefixIcon: Icon(LucideIcons.calendar),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Age is required';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 18 || age > 100) {
                                return 'Enter a valid age (18-100)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City *',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cityController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Karachi',
                              prefixIcon: Icon(LucideIcons.mapPin),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitKyc,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Creating Account...'),
                            ],
                          )
                        : const Text('Complete Profile & Continue'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

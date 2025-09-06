import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../local_db/models/application_model.dart';
import '../../../routing/app_router.dart';
import '../../../services/database_service.dart';
import '../../../ui/theme/app_theme.dart';

class ApplyHelpScreen extends ConsumerStatefulWidget {
  const ApplyHelpScreen({super.key});

  @override
  ConsumerState<ApplyHelpScreen> createState() => _ApplyHelpScreenState();
}

class _ApplyHelpScreenState extends ConsumerState<ApplyHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();

  HelpCategory _selectedCategory = HelpCategory.medical;
  bool _isUrgent = false;
  bool _isLoading = false;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      _showMessage('Maximum 5 images allowed', isError: true);
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remainingSlots = 5 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots);

        setState(() {
          _selectedImages.addAll(imagesToAdd.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      _showMessage('Error picking images: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      _showMessage('Please add at least one image', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = DatabaseService.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not found. Please login again.');
      }

      // Create application
      final application = ApplicationModel(
        id: const Uuid().v4(),
        applicantId: currentUser.id,
        applicantName: currentUser.name,
        applicantPhone: currentUser.phone,
        applicantAge: currentUser.age,
        address: _addressController.text.trim(),
        category: _selectedCategory,
        description:
            '${_titleController.text.trim()}\n\n${_descriptionController.text.trim()}',
        amountNeeded: double.tryParse(
          _amountController.text.replaceAll(',', ''),
        ),
        documentPaths: _selectedImages.map((img) => img.path).toList(),
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isUrgent: _isUrgent,
      );

      // Save to database
      await DatabaseService.instance.saveApplication(application);

      if (mounted) {
        _showMessage('Application submitted successfully!');
        context.go(AppRouter.applicantDashboard);
      }
    } catch (e) {
      _showMessage('Error submitting application: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Help'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us how we can help',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Provide detailed information to help donors understand your situation',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Category *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategorySelection(),

              const SizedBox(height: 24),

              // Title Field
              Text(
                'Title *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Brief title describing your need',
                  prefixIcon: Icon(LucideIcons.fileText),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 10) {
                    return 'Title must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description Field
              Text(
                'Detailed Description *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Explain your situation in detail...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a detailed description';
                  }
                  if (value.trim().length < 50) {
                    return 'Description must be at least 50 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Amount and Address Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount Needed',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CurrencyInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'e.g., 50,000',
                            prefixText: '₹ ',
                            prefixIcon: Icon(LucideIcons.banknote),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final amount = double.tryParse(
                                value.replaceAll(',', ''),
                              );
                              if (amount == null || amount <= 0) {
                                return 'Invalid amount';
                              }
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
                          'Location *',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'City, Area',
                            prefixIcon: Icon(LucideIcons.mapPin),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Location required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Urgency Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      color: _isUrgent
                          ? AppTheme.warning
                          : theme.iconTheme.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urgent Request',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Mark if this is time-sensitive',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isUrgent,
                      onChanged: (value) => setState(() => _isUrgent = value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Images Section
              Text(
                'Supporting Images *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add photos that support your request (max 5)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              _buildImageSection(),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                            Text('Submitting...'),
                          ],
                        )
                      : const Text('Submit Application'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: HelpCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 8),
                Text(
                  _getCategoryName(category),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Add Images Button
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.plus,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Images',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedImages.length}/5 selected',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        // Selected Images
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.x,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  IconData _getCategoryIcon(HelpCategory category) {
    switch (category) {
      case HelpCategory.medical:
        return LucideIcons.heart;
      case HelpCategory.education:
        return LucideIcons.graduationCap;
      case HelpCategory.housing:
        return LucideIcons.home;
      case HelpCategory.marriage:
        return LucideIcons.heartHandshake;
      case HelpCategory.orphan:
        return LucideIcons.baby;
      case HelpCategory.other:
        return LucideIcons.moreHorizontal;
    }
  }

  String _getCategoryName(HelpCategory category) {
    switch (category) {
      case HelpCategory.medical:
        return 'Medical';
      case HelpCategory.education:
        return 'Education';
      case HelpCategory.housing:
        return 'Housing';
      case HelpCategory.marriage:
        return 'Marriage';
      case HelpCategory.orphan:
        return 'Orphan Care';
      case HelpCategory.other:
        return 'Other';
    }
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any existing formatting
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Add comma formatting
    String formatted = '';
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = digits[i] + formatted;
      count++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

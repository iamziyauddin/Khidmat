import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../local_db/models/application_model.dart';
import '../../../local_db/models/donation_model.dart';
import '../../../services/database_service.dart';
import '../../../ui/theme/app_theme.dart';

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicantDetailScreen({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicantDetailScreen> createState() =>
      _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  ApplicationModel? application;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  void _loadApplication() {
    setState(() {
      application = DatabaseService.instance.getApplication(
        widget.applicationId,
      );
    });
  }

  Future<void> _showDonationDialog() async {
    if (application == null) return;

    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    DonationType selectedType = DonationType.financial;
    bool isAnonymous = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Make a Donation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help ${application!.applicantName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Donation Type
                Text(
                  'Donation Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DonationType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(LucideIcons.gift),
                  ),
                  items: DonationType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getDonationTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Amount (only for financial donations)
                if (selectedType == DonationType.financial) ...[
                  Text(
                    'Amount (₹)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter amount',
                      prefixIcon: Icon(LucideIcons.banknote),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Note
                Text(
                  'Note (Optional)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add a personal message...',
                    prefixIcon: Icon(LucideIcons.messageSquare),
                  ),
                ),

                const SizedBox(height: 16),

                // Anonymous option
                CheckboxListTile(
                  title: const Text('Donate anonymously'),
                  value: isAnonymous,
                  onChanged: (value) {
                    setDialogState(() => isAnonymous = value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'type': selectedType,
                  'amount': selectedType == DonationType.financial
                      ? double.tryParse(amountController.text)
                      : null,
                  'note': noteController.text.trim(),
                  'anonymous': isAnonymous,
                });
              },
              child: const Text('Donate'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _processDonation(result);
    }
  }

  Future<void> _processDonation(Map<String, dynamic> donationData) async {
    if (application == null) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = DatabaseService.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create donation record
      final donation = DonationModel(
        id: const Uuid().v4(),
        donorId: currentUser.id,
        donorName: donationData['anonymous'] ? 'Anonymous' : currentUser.name,
        applicationId: application!.id,
        applicantName: application!.applicantName,
        category: application!.category,
        amount: donationData['amount'],
        type: donationData['type'],
        status: DonationStatus.completed, // For offline app, mark as completed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: donationData['note'].isNotEmpty ? donationData['note'] : null,
      );

      // Save donation
      await DatabaseService.instance.saveDonation(donation);

      // Update application status to fulfilled if it's a financial donation
      if (donationData['type'] == DonationType.financial &&
          donationData['amount'] != null) {
        final updatedApplication = application!.copyWith(
          status: ApplicationStatus.fulfilled,
          donorId: currentUser.id,
          helpProvidedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await DatabaseService.instance.updateApplication(updatedApplication);
        setState(() => application = updatedApplication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your generous donation!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing donation: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: const Center(child: Text('Application not found')),
      );
    }

    final theme = Theme.of(context);
    final canDonate = application!.status == ApplicationStatus.verified;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      LucideIcons.user,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name and Age
                  Text(
                    application!.applicantName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${application!.applicantAge} years old',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusChip(application!.status),
                      const SizedBox(width: 12),
                      _buildCategoryChip(application!.category),
                      if (application!.isUrgent) ...[
                        const SizedBox(width: 12),
                        _buildUrgentChip(),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  _buildSection(
                    'Description',
                    application!.description,
                    LucideIcons.fileText,
                  ),

                  const SizedBox(height: 24),

                  // Location and Contact
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Location',
                          application!.address,
                          LucideIcons.mapPin,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Contact',
                          application!.applicantPhone,
                          LucideIcons.phone,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Amount Needed
                  if (application!.amountNeeded != null)
                    _buildAmountCard(application!.amountNeeded!),

                  const SizedBox(height: 24),

                  // Images
                  if (application!.documentPaths.isNotEmpty) ...[
                    _buildSection(
                      'Supporting Images',
                      '',
                      LucideIcons.image,
                      child: _buildImageGallery(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Application Timeline
                  _buildTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: canDonate
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _showDonationDialog,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(LucideIcons.heart),
                  label: Text(_isLoading ? 'Processing...' : 'Help Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon, {
    Widget? child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (child != null)
          child
        else if (content.isNotEmpty)
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(double amount) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.banknote,
            size: 32,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Amount Needed',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_formatAmount(amount)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: application!.documentPaths.length,
        itemBuilder: (context, index) {
          final imagePath = application!.documentPaths[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: File(imagePath).existsSync()
                  ? Image.file(
                      File(imagePath),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.1),
                      child: Icon(
                        LucideIcons.image,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.clock, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Timeline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          'Application Submitted',
          _formatFullDate(application!.createdAt),
          true,
        ),
        if (application!.helpProvidedAt != null)
          _buildTimelineItem(
            'Help Provided',
            _formatFullDate(application!.helpProvidedAt!),
            true,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.success : theme.colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.pending:
        color = AppTheme.warning;
        label = 'Pending';
        break;
      case ApplicationStatus.verified:
        color = AppTheme.info;
        label = 'Verified';
        break;
      case ApplicationStatus.fulfilled:
        color = AppTheme.success;
        label = 'Helped';
        break;
      case ApplicationStatus.rejected:
        color = AppTheme.error;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(HelpCategory category) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _getCategoryName(category),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertTriangle, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'URGENT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDonationTypeName(DonationType type) {
    switch (type) {
      case DonationType.financial:
        return 'Financial';
      case DonationType.material:
        return 'Material/Goods';
      case DonationType.service:
        return 'Service/Volunteer';
    }
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

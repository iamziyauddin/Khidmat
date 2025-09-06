import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../local_db/models/application_model.dart';
import '../../../services/database_service.dart';
import '../../../ui/theme/app_theme.dart';

class ApplicationStatusScreen extends ConsumerStatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  ConsumerState<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState
    extends ConsumerState<ApplicationStatusScreen> {
  ApplicationStatus? _selectedStatus;

  List<ApplicationModel> _getFilteredApplications() {
    final currentUser = DatabaseService.instance.getCurrentUser();
    if (currentUser == null) return [];

    List<ApplicationModel> applications = DatabaseService.instance
        .getApplicationsByApplicant(currentUser.id);

    if (_selectedStatus != null) {
      applications = applications
          .where((app) => app.status == _selectedStatus)
          .toList();
    }

    // Sort by creation date (newest first)
    applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return applications;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applications = _getFilteredApplications();
    final stats = _getStatusStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        stats['total']!,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        stats['pending']!,
                        AppTheme.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Verified',
                        stats['verified']!,
                        AppTheme.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Helped',
                        stats['fulfilled']!,
                        AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', ApplicationStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Verified', ApplicationStatus.verified),
                  const SizedBox(width: 8),
                  _buildFilterChip('Helped', ApplicationStatus.fulfilled),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', ApplicationStatus.rejected),
                ],
              ),
            ),
          ),

          // Applications List
          Expanded(
            child: applications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      return _buildApplicationCard(applications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildEmptyState() {
    final hasFilter = _selectedStatus != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? LucideIcons.filter : LucideIcons.fileText,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No applications found' : 'No applications yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try changing your filter'
                  : 'Your submitted applications will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(ApplicationModel application) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(application.category),
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Category and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(application.category),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(application.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status and Urgent Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusChip(application.status),
                    if (application.isUrgent) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'URGENT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              _getShortDescription(application.description),
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Amount and Location
            Row(
              children: [
                if (application.amountNeeded != null) ...[
                  Icon(
                    LucideIcons.banknote,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PKR ${_formatAmount(application.amountNeeded!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  LucideIcons.mapPin,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    application.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Images Preview
            if (application.documentPaths.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: application.documentPaths.take(3).length,
                  itemBuilder: (context, index) {
                    final imagePath = application.documentPaths[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: File(imagePath).existsSync()
                            ? Image.file(
                                File(imagePath),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: theme.colorScheme.outline.withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  LucideIcons.image,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Progress Indicator
            const SizedBox(height: 12),
            _buildProgressIndicator(application.status),

            // Action Buttons
            if (application.status == ApplicationStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(application),
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: BorderSide(color: AppTheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to edit screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildProgressIndicator(ApplicationStatus status) {
    final theme = Theme.of(context);
    final steps = [
      ('Submitted', ApplicationStatus.pending),
      ('Under Review', ApplicationStatus.verified),
      ('Helped', ApplicationStatus.fulfilled),
    ];

    final currentStep = status == ApplicationStatus.rejected
        ? 0
        : steps.indexWhere((step) => step.$2 == status) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep - 1;

            return Expanded(
              child: Row(
                children: [
                  // Step Circle
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(
                            LucideIcons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  // Step Line (except for last step)
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps
              .map(
                (step) => Text(
                  step.$1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(ApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.instance.deleteApplication(application.id);
              setState(() {}); // Refresh the list
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Application deleted'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getStatusStats() {
    final currentUser = DatabaseService.instance.getCurrentUser();
    if (currentUser == null) {
      return {
        'total': 0,
        'pending': 0,
        'verified': 0,
        'fulfilled': 0,
        'rejected': 0,
      };
    }

    final applications = DatabaseService.instance.getApplicationsByApplicant(
      currentUser.id,
    );

    return {
      'total': applications.length,
      'pending': applications
          .where((app) => app.status == ApplicationStatus.pending)
          .length,
      'verified': applications
          .where((app) => app.status == ApplicationStatus.verified)
          .length,
      'fulfilled': applications
          .where((app) => app.status == ApplicationStatus.fulfilled)
          .length,
      'rejected': applications
          .where((app) => app.status == ApplicationStatus.rejected)
          .length,
    };
  }

  String _getShortDescription(String description) {
    final lines = description.split('\n');
    if (lines.isNotEmpty && lines[0].isNotEmpty) {
      return lines[0].length > 80
          ? '${lines[0].substring(0, 80)}...'
          : lines[0];
    }
    return description.length > 80
        ? '${description.substring(0, 80)}...'
        : description;
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

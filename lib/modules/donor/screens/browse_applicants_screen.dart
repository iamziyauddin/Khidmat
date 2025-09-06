import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../local_db/models/application_model.dart';
import '../../../routing/app_router.dart';
import '../../../services/database_service.dart';
import '../../../ui/theme/app_theme.dart';

class BrowseApplicantsScreen extends ConsumerStatefulWidget {
  const BrowseApplicantsScreen({super.key});

  @override
  ConsumerState<BrowseApplicantsScreen> createState() =>
      _BrowseApplicantsScreenState();
}

class _BrowseApplicantsScreenState
    extends ConsumerState<BrowseApplicantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  HelpCategory? _selectedCategory;
  bool _showUrgentOnly = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApplicationModel> _getFilteredApplications() {
    List<ApplicationModel> applications = DatabaseService.instance
        .getVerifiedApplications();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      applications = applications.where((app) {
        return app.applicantName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            app.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            app.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      applications = applications
          .where((app) => app.category == _selectedCategory)
          .toList();
    }

    // Filter by urgency
    if (_showUrgentOnly) {
      applications = applications.where((app) => app.isUrgent).toList();
    }

    // Sort by urgency and date
    applications.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return applications;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applications = _getFilteredApplications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Applications'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search applications...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.background,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filter Chips
          if (_selectedCategory != null || _showUrgentOnly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_getCategoryName(_selectedCategory!)),
                        deleteIcon: const Icon(LucideIcons.x, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedCategory = null),
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                    ),
                  if (_showUrgentOnly)
                    Chip(
                      label: const Text('Urgent Only'),
                      deleteIcon: const Icon(LucideIcons.x, size: 16),
                      onDeleted: () => setState(() => _showUrgentOnly = false),
                      backgroundColor: AppTheme.warning.withOpacity(0.1),
                    ),
                ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
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
      child: InkWell(
        onTap: () =>
            context.push('${AppRouter.applicantDetail}/${application.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Profile Picture or Icon
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      LucideIcons.user,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicantName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(application.category),
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getCategoryName(application.category),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Urgent Badge
                  if (application.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.circular(12),
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

              // Amount and Location Row
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
                      '₹${_formatAmount(application.amountNeeded!)}',
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

              const SizedBox(height: 12),

              // Bottom Row
              Row(
                children: [
                  // Date
                  Text(
                    _formatDate(application.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Spacer(),

                  // Help Button
                  ElevatedButton.icon(
                    onPressed: () => context.push(
                      '${AppRouter.applicantDetail}/${application.id}',
                    ),
                    icon: const Icon(LucideIcons.heart, size: 16),
                    label: const Text('Help'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
                if (application.documentPaths.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${application.documentPaths.length - 3} more images',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Filter Applications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Category Filter
              Text(
                'Category',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setModalState(() => _selectedCategory = null);
                    },
                  ),
                  ...HelpCategory.values.map(
                    (category) => FilterChip(
                      label: Text(_getCategoryName(category)),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Urgency Filter
              SwitchListTile(
                title: const Text('Show urgent only'),
                subtitle: const Text(
                  'Priority applications requiring immediate help',
                ),
                value: _showUrgentOnly,
                onChanged: (value) {
                  setModalState(() => _showUrgentOnly = value);
                },
                secondary: const Icon(LucideIcons.alertTriangle),
              ),

              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Update the main screen
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortDescription(String description) {
    // Extract the first line (title part) or first 100 characters
    final lines = description.split('\n');
    if (lines.isNotEmpty && lines[0].isNotEmpty) {
      return lines[0].length > 100
          ? '${lines[0].substring(0, 100)}...'
          : lines[0];
    }
    return description.length > 100
        ? '${description.substring(0, 100)}...'
        : description;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
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

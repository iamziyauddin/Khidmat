import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../services/database_service.dart';
import '../../../local_db/models/application_model.dart';
import '../../../ui/theme/app_theme.dart';

class ApplicantDashboard extends ConsumerStatefulWidget {
  const ApplicantDashboard({super.key});

  @override
  ConsumerState<ApplicantDashboard> createState() => _ApplicantDashboardState();
}

class _ApplicantDashboardState extends ConsumerState<ApplicantDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = DatabaseService.instance.getCurrentUser();
    final applications = currentUser != null
        ? DatabaseService.instance.getApplicationsByApplicant(currentUser.id)
        : <ApplicationModel>[];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardHome(applications: applications),
          _ApplicationsList(applications: applications),
          _ApplicantProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.fileText),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/applicant-dashboard/apply-help'),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Apply for Help'),
            )
          : null,
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final List<ApplicationModel> applications;

  const _DashboardHome({required this.applications});

  @override
  Widget build(BuildContext context) {
    final currentUser = DatabaseService.instance.getCurrentUser();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Welcome ${currentUser?.name ?? 'User'}',
              style: const TextStyle(color: Colors.white),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick Stats
              _buildQuickStats(context, applications),

              const SizedBox(height: 24),

              // Recent Applications
              _buildRecentApplications(context, applications),

              const SizedBox(height: 24),

              // Help Categories
              _buildHelpCategories(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    List<ApplicationModel> applications,
  ) {
    final stats = {
      'Total': applications.length,
      'Pending': applications
          .where((app) => app.status == ApplicationStatus.pending)
          .length,
      'Verified': applications
          .where((app) => app.status == ApplicationStatus.verified)
          .length,
      'Fulfilled': applications
          .where((app) => app.status == ApplicationStatus.fulfilled)
          .length,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Applications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: stats.entries.map((entry) {
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApplications(
    BuildContext context,
    List<ApplicationModel> applications,
  ) {
    final recentApps = applications.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Applications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (applications.isNotEmpty)
              TextButton(
                onPressed: () {}, // Navigate to full list
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentApps.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to submit your first application for help',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...recentApps.map((app) => _ApplicationCard(application: app)),
      ],
    );
  }

  Widget _buildHelpCategories(BuildContext context) {
    final categories = [
      {'icon': LucideIcons.heart, 'title': 'Medical', 'color': Colors.red},
      {'icon': LucideIcons.home, 'title': 'Housing', 'color': Colors.blue},
      {
        'icon': LucideIcons.graduationCap,
        'title': 'Education',
        'color': Colors.green,
      },
      {'icon': LucideIcons.users, 'title': 'Marriage', 'color': Colors.purple},
      {
        'icon': LucideIcons.baby,
        'title': 'Orphan Care',
        'color': Colors.orange,
      },
      {
        'icon': LucideIcons.moreHorizontal,
        'title': 'Other',
        'color': Colors.grey,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              child: InkWell(
                onTap: () => context.go('/applicant-dashboard/apply-help'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 32,
                        color: category['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['title'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(
                      application.status.name,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    application.status.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getStatusColor(application.status.name),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  application.category.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              application.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Applied on ${application.createdAt.day}/${application.createdAt.month}/${application.createdAt.year}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationsList extends StatelessWidget {
  final List<ApplicationModel> applications;

  const _ApplicationsList({required this.applications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        automaticallyImplyLeading: false,
      ),
      body: applications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No applications yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                return _ApplicationCard(application: applications[index]);
              },
            ),
    );
  }
}

class _ApplicantProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = DatabaseService.instance.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                LucideIcons.user,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              currentUser?.name ?? 'User',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '+91 ${currentUser?.phone ?? ''}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 32),

            // Profile Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ProfileInfoRow('Age', '${currentUser?.age ?? 0} years'),
                    const Divider(),
                    _ProfileInfoRow('City', currentUser?.city ?? ''),
                    const Divider(),
                    _ProfileInfoRow('Role', 'Applicant'),
                    const Divider(),
                    _ProfileInfoRow(
                      'Member Since',
                      '${currentUser?.createdAt.day}/${currentUser?.createdAt.month}/${currentUser?.createdAt.year}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

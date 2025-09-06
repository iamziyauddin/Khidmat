import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../local_db/models/application_model.dart';
import '../../../routing/app_router.dart';
import '../../../services/database_service.dart';
import '../../../ui/theme/app_theme.dart';

class DonorDashboard extends ConsumerStatefulWidget {
  const DonorDashboard({super.key});

  @override
  ConsumerState<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends ConsumerState<DonorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('DonorDashboard build method called');
    print('Current route: ${GoRouterState.of(context).uri}');

    try {
      final stats = DatabaseService.instance.getApplicationStatistics();
      final recentApplications = DatabaseService.instance
          .getVerifiedApplications()
          .take(5)
          .toList();

      print('Stats loaded: $stats');
      print('Recent applications count: ${recentApplications.length}');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Donor Dashboard'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardHome(
              stats: stats,
              recentApplications: recentApplications,
              onSwitchTab: (index) => setState(() => _selectedIndex = index),
            ),
            _BrowseApplicationsTab(),
            _DonorProfile(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.search),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      print('Error in DonorDashboard build: $e');
      print('StackTrace: $stackTrace');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Donor Dashboard'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading dashboard'),
              const SizedBox(height: 8),
              Text('$e'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _DashboardHome extends StatelessWidget {
  final Map<String, int> stats;
  final List<ApplicationModel> recentApplications;
  final Function(int) onSwitchTab;

  const _DashboardHome({
    required this.stats,
    required this.recentApplications,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = DatabaseService.instance.getCurrentUser();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Welcome ${currentUser?.name ?? 'Donor'}',
              style: const TextStyle(color: Colors.white),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                Text(
                  'Community Impact',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatsGrid(context, stats),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickActions(context),

                const SizedBox(height: 32),

                // Recent Applications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Applications',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Switch to Browse tab (index 1)
                        onSwitchTab(1);
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecentApplications(context, recentApplications),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, int> stats) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          'Total Applications',
          stats['total']?.toString() ?? '0',
          LucideIcons.fileText,
          theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          'Verified',
          stats['verified']?.toString() ?? '0',
          LucideIcons.checkCircle,
          AppTheme.success,
        ),
        _buildStatCard(
          context,
          'Pending Review',
          stats['pending']?.toString() ?? '0',
          LucideIcons.clock,
          AppTheme.warning,
        ),
        _buildStatCard(
          context,
          'Helped',
          stats['fulfilled']?.toString() ?? '0',
          LucideIcons.heart,
          AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            'Browse Applications',
            'Find people to help',
            LucideIcons.search,
            () => onSwitchTab(1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            'Donation History',
            'View your impact',
            LucideIcons.history,
            () => context.go(AppRouter.donationHistory),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentApplications(
    BuildContext context,
    List<ApplicationModel> applications,
  ) {
    if (applications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.inbox,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here once people start applying for help',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: applications
          .map((app) => _buildApplicationCard(context, app))
          .toList(),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    ApplicationModel application,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            context.push('${AppRouter.applicantDetail}/${application.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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

              // Application Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryName(application.category),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (application.amountNeeded != null)
                      Text(
                        '₹${_formatAmount(application.amountNeeded!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
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
                    borderRadius: BorderRadius.circular(8),
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
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
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

class _BrowseApplicationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final applications = DatabaseService.instance.getVerifiedApplications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Applications'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: applications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No applications available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: Text(
                                application.applicantName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    application.applicantName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    application.category
                                        .toString()
                                        .split('.')
                                        .last,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            if (application.amountNeeded != null)
                              Text(
                                '₹${application.amountNeeded!.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${application.status.toString().split('.').last}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to applicant detail with the application ID
                                context.go(
                                  '/applicant-detail/${application.id}',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Help'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _DonorProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = DatabaseService.instance.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
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
                  Text(
                    currentUser?.name ?? 'Donor',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.phone ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Verified Donor',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Actions
            _buildProfileAction(
              context,
              'Edit Profile',
              'Update your information',
              LucideIcons.edit,
              () {
                // TODO: Implement edit profile
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon'),
                  ),
                );
              },
            ),
            _buildProfileAction(
              context,
              'Donation History',
              'View all your donations',
              LucideIcons.history,
              () => context.go(AppRouter.donationHistory),
            ),
            _buildProfileAction(
              context,
              'Settings',
              'App preferences',
              LucideIcons.settings,
              () {
                // TODO: Implement settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings feature coming soon')),
                );
              },
            ),
            _buildProfileAction(
              context,
              'About',
              'Learn more about Khidmat',
              LucideIcons.info,
              () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About Khidmat'),
                    content: const Text(
                      'Khidmat is a platform that connects people in need with generous donors. '
                      'Together, we can make a difference in our community.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            DatabaseService.instance.clearCurrentUser();
                            context.go('/');
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(LucideIcons.logOut),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(LucideIcons.chevronRight),
      ),
    );
  }
}

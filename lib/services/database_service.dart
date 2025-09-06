import 'package:hive_flutter/hive_flutter.dart';
import '../local_db/models/user_model.dart';
import '../local_db/models/application_model.dart';
import '../local_db/models/donation_model.dart';

class DatabaseService {
  static const String _usersBox = 'users';
  static const String _applicationsBox = 'applications';
  static const String _donationsBox = 'donations';
  static const String _settingsBox = 'settings';

  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  DatabaseService._();

  late Box<UserModel> _usersDatabase;
  late Box<ApplicationModel> _applicationsDatabase;
  late Box<DonationModel> _donationsDatabase;
  late Box<dynamic> _settingsDatabase;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ApplicationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HelpCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ApplicationStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(DonationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(DonationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(DonationStatusAdapter());
    }

    // Open boxes
    _usersDatabase = await Hive.openBox<UserModel>(_usersBox);
    _applicationsDatabase = await Hive.openBox<ApplicationModel>(
      _applicationsBox,
    );
    _donationsDatabase = await Hive.openBox<DonationModel>(_donationsBox);
    _settingsDatabase = await Hive.openBox(_settingsBox);

    _isInitialized = true;
  }

  // User operations
  Future<void> saveUser(UserModel user) async {
    await _usersDatabase.put(user.id, user);
  }

  UserModel? getUser(String id) {
    return _usersDatabase.get(id);
  }

  UserModel? getCurrentUser() {
    final currentUserId = _settingsDatabase.get('currentUserId');
    if (currentUserId != null) {
      return _usersDatabase.get(currentUserId);
    }
    return null;
  }

  Future<void> setCurrentUser(String userId) async {
    await _settingsDatabase.put('currentUserId', userId);
  }

  Future<void> clearCurrentUser() async {
    await _settingsDatabase.delete('currentUserId');
  }

  Future<void> updateUser(UserModel user) async {
    await _usersDatabase.put(user.id, user);
  }

  Future<void> deleteUser(String id) async {
    await _usersDatabase.delete(id);
  }

  List<UserModel> getAllUsers() {
    return _usersDatabase.values.toList();
  }

  List<UserModel> getUsersByRole(UserRole role) {
    return _usersDatabase.values.where((user) => user.role == role).toList();
  }

  Future<void> saveUsers(List<UserModel> users) async {
    final userMap = {for (var user in users) user.id: user};
    await _usersDatabase.putAll(userMap);
  }

  Future<void> deleteUsers(List<String> ids) async {
    await _usersDatabase.deleteAll(ids);
  }

  // Application operations
  Future<void> saveApplication(ApplicationModel application) async {
    await _applicationsDatabase.put(application.id, application);
  }

  ApplicationModel? getApplication(String id) {
    return _applicationsDatabase.get(id);
  }

  Future<void> updateApplication(ApplicationModel application) async {
    await _applicationsDatabase.put(application.id, application);
  }

  Future<void> deleteApplication(String id) async {
    await _applicationsDatabase.delete(id);
  }

  List<ApplicationModel> getAllApplications() {
    return _applicationsDatabase.values.toList();
  }

  List<ApplicationModel> getApplicationsByApplicant(String applicantId) {
    return _applicationsDatabase.values
        .where((app) => app.applicantId == applicantId)
        .toList();
  }

  List<ApplicationModel> getApplicationsByStatus(ApplicationStatus status) {
    return _applicationsDatabase.values
        .where((app) => app.status == status)
        .toList();
  }

  List<ApplicationModel> getApplicationsByCategory(HelpCategory category) {
    return _applicationsDatabase.values
        .where((app) => app.category == category)
        .toList();
  }

  List<ApplicationModel> getVerifiedApplications() {
    return _applicationsDatabase.values
        .where((app) => app.status == ApplicationStatus.verified)
        .toList();
  }

  List<ApplicationModel> getUrgentApplications() {
    return _applicationsDatabase.values
        .where(
          (app) => app.isUrgent && app.status == ApplicationStatus.verified,
        )
        .toList();
  }

  Future<void> saveApplications(List<ApplicationModel> applications) async {
    final applicationMap = {for (var app in applications) app.id: app};
    await _applicationsDatabase.putAll(applicationMap);
  }

  Future<void> deleteApplications(List<String> ids) async {
    await _applicationsDatabase.deleteAll(ids);
  }

  // Donation operations
  Future<void> saveDonation(DonationModel donation) async {
    await _donationsDatabase.put(donation.id, donation);
  }

  DonationModel? getDonation(String id) {
    return _donationsDatabase.get(id);
  }

  Future<void> updateDonation(DonationModel donation) async {
    await _donationsDatabase.put(donation.id, donation);
  }

  Future<void> deleteDonation(String id) async {
    await _donationsDatabase.delete(id);
  }

  List<DonationModel> getAllDonations() {
    return _donationsDatabase.values.toList();
  }

  List<DonationModel> getDonationsByDonor(String donorId) {
    return _donationsDatabase.values
        .where((donation) => donation.donorId == donorId)
        .toList();
  }

  List<DonationModel> getDonationsByApplication(String applicationId) {
    return _donationsDatabase.values
        .where((donation) => donation.applicationId == applicationId)
        .toList();
  }

  List<DonationModel> getDonationsByStatus(DonationStatus status) {
    return _donationsDatabase.values
        .where((donation) => donation.status == status)
        .toList();
  }

  Future<void> saveDonations(List<DonationModel> donations) async {
    final donationMap = {for (var d in donations) d.id: d};
    await _donationsDatabase.putAll(donationMap);
  }

  Future<void> deleteDonations(List<String> ids) async {
    await _donationsDatabase.deleteAll(ids);
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsDatabase.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsDatabase.get(key) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsDatabase.delete(key);
  }

  // Utility methods
  Future<void> clearAllData() async {
    await _usersDatabase.clear();
    await _applicationsDatabase.clear();
    await _donationsDatabase.clear();
    await _settingsDatabase.clear();
  }

  Future<void> closeDatabase() async {
    await _usersDatabase.close();
    await _applicationsDatabase.close();
    await _donationsDatabase.close();
    await _settingsDatabase.close();
  }

  // Search and filter methods
  List<ApplicationModel> searchApplications(String query) {
    final lowerQuery = query.toLowerCase();
    return _applicationsDatabase.values.where((app) {
      return app.applicantName.toLowerCase().contains(lowerQuery) ||
          app.description.toLowerCase().contains(lowerQuery) ||
          app.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<ApplicationModel> filterApplications({
    HelpCategory? category,
    ApplicationStatus? status,
    String? city,
    bool? isUrgent,
  }) {
    return _applicationsDatabase.values.where((app) {
      if (category != null && app.category != category) return false;
      if (status != null && app.status != status) return false;
      if (city != null &&
          !app.address.toLowerCase().contains(city.toLowerCase()))
        return false;
      if (isUrgent != null && app.isUrgent != isUrgent) return false;
      return true;
    }).toList();
  }

  // Statistics methods
  Map<String, int> getApplicationStatistics() {
    final apps = getAllApplications();
    return {
      'total': apps.length,
      'pending': apps
          .where((app) => app.status == ApplicationStatus.pending)
          .length,
      'verified': apps
          .where((app) => app.status == ApplicationStatus.verified)
          .length,
      'fulfilled': apps
          .where((app) => app.status == ApplicationStatus.fulfilled)
          .length,
      'rejected': apps
          .where((app) => app.status == ApplicationStatus.rejected)
          .length,
    };
  }

  Map<String, int> getDonationStatistics(String donorId) {
    final donations = getDonationsByDonor(donorId);
    return {
      'total': donations.length,
      'completed': donations
          .where((d) => d.status == DonationStatus.completed)
          .length,
      'pending': donations
          .where((d) => d.status == DonationStatus.pending)
          .length,
      'cancelled': donations
          .where((d) => d.status == DonationStatus.cancelled)
          .length,
    };
  }

  // Donation processing methods
  Future<void> processDonation(
    String applicationId,
    DonationModel donation,
  ) async {
    // Add the donation
    await saveDonation(donation);

    // Update the application with donation info
    final application = getApplication(applicationId);
    if (application != null) {
      final updatedDonationIds = List<String>.from(application.donationIds);
      updatedDonationIds.add(donation.id);

      final totalReceived = getTotalDonationsForApplication(applicationId);

      await updateApplication(
        application.copyWith(
          donationIds: updatedDonationIds,
          amountReceived: totalReceived,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  double getTotalDonationsForApplication(String applicationId) {
    final donations = _donationsDatabase.values
        .where(
          (d) =>
              d.applicationId == applicationId &&
              d.status == DonationStatus.completed,
        )
        .toList();

    return donations.fold(
      0.0,
      (total, donation) => total + (donation.amount ?? 0.0),
    );
  }

  List<DonationModel> getDonationsForApplication(String applicationId) {
    return _donationsDatabase.values
        .where((d) => d.applicationId == applicationId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> updateApplicationAmountReceived(String applicationId) async {
    final application = getApplication(applicationId);
    if (application != null) {
      final totalReceived = getTotalDonationsForApplication(applicationId);
      await updateApplication(
        application.copyWith(
          amountReceived: totalReceived,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/work_report_model.dart';

class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('work_reports');

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------

  Future<void> createUser(UserModel user) =>
      _users.doc(user.id).set(user.toMap());

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Stream<List<UserModel>> getAllUsers() {
    return _users.snapshots().map(
          (s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Future<List<UserModel>> getAllUsersOnce() async {
    final s = await _users.get();
    return s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Stream<List<UserModel>> getUsersByDesignation(String designation) {
    return _users
        .where('designation', isEqualTo: designation)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<UserModel>> getUsersByDepartmentAndDesignation(
    String department,
    String designation,
  ) {
    return _users
        .where('department', isEqualTo: department)
        .where('designation', isEqualTo: designation)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  Future<List<String>> getAllDesignations() async {
    final s = await _users.get();
    final designations = <String>{};
    for (final d in s.docs) {
      final v = (d.data()['designation'] ?? '').toString();
      if (v.isNotEmpty) designations.add(v);
    }
    return designations.toList()..sort();
  }

  Future<void> updateUserProfile(UserModel user) =>
      _users.doc(user.id).update(user.toMap());

  /// True when the user is an admin. Treats the boolean flag as authoritative
  /// and additionally accepts a designation that contains "admin" so that
  /// existing accounts created before the flag rollout still work.
  Future<bool> isUserAdmin(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return false;
    final data = doc.data() ?? {};
    if (data['isAdmin'] == true) return true;
    final designation = (data['designation'] ?? '').toString().toLowerCase();
    return designation.contains('admin');
  }

  Future<Map<String, int>> getStaffCountByDesignation() async {
    final s = await _users.get();
    final counts = <String, int>{};
    for (final d in s.docs) {
      final designation = (d.data()['designation'] ?? 'Unknown').toString();
      counts[designation] = (counts[designation] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<String, Map<String, int>>>
      getStaffCountByDepartmentAndDesignation() async {
    final s = await _users.get();
    final counts = <String, Map<String, int>>{};
    for (final d in s.docs) {
      final dept = (d.data()['department'] ?? 'Unknown').toString();
      final desig = (d.data()['designation'] ?? 'Unknown').toString();
      counts[dept] ??= {};
      counts[dept]![desig] = (counts[dept]![desig] ?? 0) + 1;
    }
    return counts;
  }

  // ---------------------------------------------------------------------------
  // Work reports
  // ---------------------------------------------------------------------------

  Future<void> submitWorkReport(WorkReportModel report) =>
      _reports.add(report.toMap());

  Stream<List<WorkReportModel>> getWorkReports() {
    return _reports
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => WorkReportModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<WorkReportModel>> getUserWorkReports(String userId) {
    return _reports
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => WorkReportModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<WorkReportModel>> getAllWorkReports() => getWorkReports();

  Future<List<WorkReportModel>> getAllWorkReportsOnce() async {
    final s = await _reports.orderBy('date', descending: true).get();
    return s.docs
        .map((d) => WorkReportModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<List<String>> getAllDepartments() async {
    final users = await _users.get();
    final reports = await _reports.get();
    final set = <String>{};
    for (final d in users.docs) {
      set.add((d.data()['department'] ?? 'Unknown').toString());
    }
    for (final d in reports.docs) {
      set.add((d.data()['department'] ?? 'Unknown').toString());
    }
    return set.toList()..sort();
  }

  Future<void> updateUserLocation(String userId, GeoPoint location) {
    return _users.doc(userId).update({
      'lastKnownLocation': location,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  Stream<GeoPoint?> getUserLocation(String userId) {
    return _users.doc(userId).snapshots().map(
          (s) => s.data()?['lastKnownLocation'] as GeoPoint?,
        );
  }

  Future<Map<String, int>> getTaskCountByDepartment() async {
    final s = await _reports.get();
    final counts = <String, int>{};
    for (final d in s.docs) {
      final dept = (d.data()['department'] ?? 'Unknown').toString();
      counts[dept] = (counts[dept] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<WorkReportModel>> getRecentWorkReports({int limit = 10}) async {
    final s = await _reports
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return s.docs
        .map((d) => WorkReportModel.fromMap(d.data(), d.id))
        .toList();
  }

  Stream<List<UserModel>> getUsersByWard(
    String ward, {
    String? designation,
  }) {
    Query<Map<String, dynamic>> query =
        _users.where('ward', isEqualTo: ward);
    if (designation != null) {
      query = query.where('designation', isEqualTo: designation);
    }
    return query.snapshots().map(
          (s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Stream<List<UserModel>> getUsersBySubCounty(
    String subCounty, {
    String? designation,
  }) {
    Query<Map<String, dynamic>> query =
        _users.where('subCounty', isEqualTo: subCounty);
    if (designation != null) {
      query = query.where('designation', isEqualTo: designation);
    }
    return query.snapshots().map(
          (s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Stream<List<WorkReportModel>> getWorkReportsByDesignation(
    String designation,
  ) {
    return _reports
        .where('userDesignation', isEqualTo: designation)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => WorkReportModel.fromMap(d.data(), d.id))
            .toList());
  }
}

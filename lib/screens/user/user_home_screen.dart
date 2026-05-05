import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/work_report_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../about_screen.dart';
import 'report_router.dart';
import 'user_profile_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  Future<void> _printReports(
    BuildContext context,
    List<WorkReportModel> reports,
    UserModel user,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Baringo County Government',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Work Reports - ${user.firstName} ${user.surname}',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Department: ${user.department}'),
            pw.Text('Sub-Department: ${user.subDepartment ?? "N/A"}'),
            pw.Text('Workstation: ${user.workstation}'),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: const ['Task', 'Location', 'Date & Time', 'Status'],
            data: reports
                .map((r) => [
                      r.task,
                      r.location,
                      DateFormat('yyyy-MM-dd HH:mm').format(r.date),
                      'Completed',
                    ])
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'bcg_work_reports.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final databaseService = DatabaseService();
    final firebaseUser = authProvider.firebaseUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BCG Staff Monitor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (firebaseUser != null)
            StreamBuilder<List<WorkReportModel>>(
              stream: databaseService.getUserWorkReports(firebaseUser.uid),
              builder: (context, snap) {
                final reports = snap.data ?? const <WorkReportModel>[];
                return IconButton(
                  icon: const Icon(Icons.print, color: Colors.white),
                  onPressed: reports.isEmpty
                      ? null
                      : () async {
                          final user = await databaseService
                              .getUserById(firebaseUser.uid);
                          if (user != null && context.mounted) {
                            _printReports(context, reports, user);
                          }
                        },
                  tooltip: 'Print reports',
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(),
                    ),
                  );
                case 'about':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                case 'logout':
                  await authProvider.signOut();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: firebaseUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppColors.primaryGreen.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Not authenticated. Please log in.',
                    style: TextStyle(
                      color: AppColors.primaryGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : FutureBuilder<UserModel?>(
              future: databaseService.getUserById(firebaseUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }
                final user = snapshot.data;
                if (user == null) {
                  return const Center(
                    child: Text(
                      'User data not found. Please sign out and back in.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(24),
                        color: AppColors.primaryGreen,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${user.firstName} ${user.surname}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 1,
                              color: AppColors.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Staff Information',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _row('County', user.county),
                                    _row('Sub-County', user.subCounty),
                                    _row('Ward', user.ward),
                                    _row('Department', user.department),
                                    if ((user.subDepartment ?? '').isNotEmpty)
                                      _row(
                                        'Sub-Department',
                                        user.subDepartment!,
                                      ),
                                    _row('Workstation', user.workstation),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Recent Reports',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            StreamBuilder<List<WorkReportModel>>(
                              stream:
                                  databaseService.getUserWorkReports(user.id),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snap.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snap.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                final reports = snap.data ?? [];
                                if (reports.isEmpty) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 48,
                                          color: AppColors.primaryGreen
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'No reports submitted yet.',
                                          style: TextStyle(
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: reports.length,
                                  itemBuilder: (context, i) {
                                    final report = reports[i];
                                    return Card(
                                      elevation: 1,
                                      margin:
                                          const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        title: Text(
                                          report.task,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color:
                                                      AppColors.secondaryGreen,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    report.location,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color:
                                                      AppColors.secondaryGreen,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat(
                                                    'yyyy-MM-dd HH:mm',
                                                  ).format(report.date),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.check_circle,
                                          color: AppColors.secondaryGreen,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportRouter()),
          );
        },
        tooltip: 'Submit Work Report',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

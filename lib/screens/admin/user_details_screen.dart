import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../models/work_report_model.dart';
import '../../services/database_service.dart';
import 'map_view_screen.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId;
  final DatabaseService _databaseService;

  UserDetailsScreen({
    super.key,
    required this.userId,
    DatabaseService? databaseService,
  }) : _databaseService = databaseService ?? DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: FutureBuilder<UserModel?>(
        future: _databaseService.getUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.surname}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('ID Number: ${user.idNumber}'),
                Text('Phone: ${user.phoneNumber}'),
                Text('Email: ${user.email}'),
                Text('Designation: ${user.designation}'),
                Text('Department: ${user.department}'),
                if ((user.subDepartment ?? '').isNotEmpty)
                  Text('Sub-Department: ${user.subDepartment!}'),
                Text('County: ${user.county}'),
                Text('Sub-County: ${user.subCounty}'),
                Text('Ward: ${user.ward}'),
                Text('Workstation: ${user.workstation}'),
                const SizedBox(height: 24),
                Text(
                  'Work Reports',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: StreamBuilder<List<WorkReportModel>>(
                    stream: _databaseService.getUserWorkReports(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      final reports = snapshot.data ?? const [];
                      if (reports.isEmpty) {
                        return const Center(
                          child: Text('No reports yet.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, i) {
                          final report = reports[i];
                          return ListTile(
                            title: Text(report.task),
                            subtitle: Text(
                              '${report.location} • '
                              '${DateFormat('yyyy-MM-dd HH:mm').format(report.date)}',
                            ),
                            trailing: const Icon(Icons.map),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MapViewScreen(report: report),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'agriculture_report_screen.dart';
import 'devolution_report_screen.dart';
import 'generic_report_screen.dart';
import 'health_report_screen.dart';
import 'water_report_screen.dart';

class ReportRouter extends StatelessWidget {
  const ReportRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return FutureBuilder<UserModel?>(
      future: authProvider.getCurrentUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text(
                'Could not load your profile. Please sign out and back in.',
              ),
            ),
          );
        }

        final user = snapshot.data!;
        final subDept = user.subDepartment ?? '';

        switch (user.department) {
          case 'Agriculture, Livestock, and Fisheries Development':
            return AgricultureReportScreen(
              userId: user.id,
              subDepartment: subDept,
            );
          case 'Water, Environment, Natural Resources, and Climate Change':
          // Match older department names too in case existing accounts have not
          // been migrated yet.
          case 'Water, Irrigation, Environment, Natural Resources, and Mining':
            return WaterReportScreen(
              userId: user.id,
              subDepartment: subDept,
            );
          case 'Health Services':
            return HealthReportScreen(
              userId: user.id,
              subDepartment: subDept,
            );
          case 'Devolution, Public Service, and Administration':
            return DevolutionReportScreen(
              userId: user.id,
              subDepartment: subDept,
            );
          default:
            return GenericReportScreen(
              userId: user.id,
              department: user.department,
            );
        }
      },
    );
  }
}

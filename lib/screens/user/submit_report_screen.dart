// Legacy stub kept only for source compatibility. New code should route
// through `ReportRouter` which dispatches to the right department-specific
// screen.
import 'package:flutter/material.dart';

import 'report_router.dart';

class SubmitReportScreen extends StatelessWidget {
  const SubmitReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const ReportRouter();
}

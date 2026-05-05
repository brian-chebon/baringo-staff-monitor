import 'package:flutter/material.dart';

import 'report_form_scaffold.dart';

class DevolutionReportScreen extends StatefulWidget {
  final String userId;
  final String subDepartment;

  const DevolutionReportScreen({
    super.key,
    required this.userId,
    required this.subDepartment,
  });

  @override
  State<DevolutionReportScreen> createState() => _DevolutionReportScreenState();
}

class _DevolutionReportScreenState extends State<DevolutionReportScreen> {
  String _task = '';
  String _projectName = '';
  String _stakeholders = '';

  @override
  Widget build(BuildContext context) {
    return ReportFormScaffold(
      userId: widget.userId,
      title: 'Devolution Report - ${widget.subDepartment}',
      departmentName: 'Devolution, Public Service, and Administration',
      subDepartment: widget.subDepartment,
      taskHint: 'e.g. Public participation forum, Kabarnet',
      taskBuilder: () => _task,
      collectExtraData: () => {
        'projectName': _projectName,
        'stakeholders': _stakeholders,
      },
      extraFields: (context) => [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Task Description*',
            prefixIcon: Icon(Icons.assignment),
          ),
          maxLines: 3,
          validator: ReportValidators.requiredText,
          onSaved: (v) => _task = v ?? '',
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Project Name*',
            prefixIcon: Icon(Icons.work),
          ),
          validator: ReportValidators.requiredText,
          onSaved: (v) => _projectName = v ?? '',
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Stakeholders Involved*',
            prefixIcon: Icon(Icons.group),
          ),
          validator: ReportValidators.requiredText,
          onSaved: (v) => _stakeholders = v ?? '',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'report_form_scaffold.dart';

class HealthReportScreen extends StatefulWidget {
  final String userId;
  final String subDepartment;

  const HealthReportScreen({
    super.key,
    required this.userId,
    required this.subDepartment,
  });

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  String _task = '';
  int _patientCount = 0;
  String _treatmentType = '';

  @override
  Widget build(BuildContext context) {
    return ReportFormScaffold(
      userId: widget.userId,
      title: 'Health Report - ${widget.subDepartment}',
      departmentName: 'Health Services',
      subDepartment: widget.subDepartment,
      taskHint: 'e.g. Outreach clinic, Mukutani',
      taskBuilder: () => _task,
      collectExtraData: () => {
        'patientCount': _patientCount,
        'treatmentType': _treatmentType,
      },
      extraFields: (context) => [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Task Description*',
            prefixIcon: Icon(Icons.medical_services),
          ),
          maxLines: 3,
          validator: ReportValidators.requiredText,
          onSaved: (v) => _task = v ?? '',
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Number of Patients*',
            prefixIcon: Icon(Icons.people),
          ),
          keyboardType: TextInputType.number,
          validator: ReportValidators.nonNegativeInt,
          onSaved: (v) => _patientCount = int.parse(v!.trim()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Treatment Type*',
            prefixIcon: Icon(Icons.healing),
          ),
          validator: ReportValidators.requiredText,
          onSaved: (v) => _treatmentType = v ?? '',
        ),
      ],
    );
  }
}

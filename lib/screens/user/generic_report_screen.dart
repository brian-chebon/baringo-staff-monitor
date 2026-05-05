import 'package:flutter/material.dart';

import 'report_form_scaffold.dart';

class GenericReportScreen extends StatefulWidget {
  final String userId;
  final String department;

  const GenericReportScreen({
    super.key,
    required this.userId,
    required this.department,
  });

  @override
  State<GenericReportScreen> createState() => _GenericReportScreenState();
}

class _GenericReportScreenState extends State<GenericReportScreen> {
  String _task = '';
  String _additionalNotes = '';

  @override
  Widget build(BuildContext context) {
    return ReportFormScaffold(
      userId: widget.userId,
      title: '${widget.department} Report',
      departmentName: widget.department,
      subDepartment: '',
      taskHint: 'e.g. Site visit, Kabarnet',
      taskBuilder: () => _task,
      collectExtraData: () => {'additionalNotes': _additionalNotes},
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
            labelText: 'Additional Notes',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 3,
          onSaved: (v) => _additionalNotes = v ?? '',
        ),
      ],
    );
  }
}

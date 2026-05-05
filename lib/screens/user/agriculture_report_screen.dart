import 'package:flutter/material.dart';

import '../../constants/baringo_data.dart';
import 'report_form_scaffold.dart';

class AgricultureReportScreen extends StatefulWidget {
  final String userId;
  final String subDepartment;

  const AgricultureReportScreen({
    super.key,
    required this.userId,
    required this.subDepartment,
  });

  @override
  State<AgricultureReportScreen> createState() =>
      _AgricultureReportScreenState();
}

class _AgricultureReportScreenState extends State<AgricultureReportScreen> {
  String? _activityType;
  String _description = '';
  int _maleAttendance = 0;
  int _femaleAttendance = 0;
  int _youthAttendance = 0;
  String _remarks = '';

  @override
  Widget build(BuildContext context) {
    return ReportFormScaffold(
      userId: widget.userId,
      title: 'Agriculture Activity Report',
      departmentName: 'Agriculture, Livestock, and Fisheries Development',
      subDepartment: widget.subDepartment,
      taskHint: 'e.g. Kabarnet farm visit',
      taskBuilder: () => _activityType ?? 'Field activity',
      beforeSubmit: () {
        if (_activityType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choose an activity type.')),
          );
          return false;
        }
        return true;
      },
      collectExtraData: () => {
        'description': _description,
        'maleAttendance': _maleAttendance,
        'femaleAttendance': _femaleAttendance,
        'youthAttendance': _youthAttendance,
        'totalAttendance':
            _maleAttendance + _femaleAttendance + _youthAttendance,
        'remarks': _remarks,
      },
      extraFields: (context) => [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Activity Type*',
            prefixIcon: Icon(Icons.category),
          ),
          isExpanded: true,
          initialValue: _activityType,
          items: BaringoData.agricultureActivityTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _activityType = v),
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Activity Description*',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: ReportValidators.requiredText,
          onSaved: (v) => _description = v ?? '',
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Male Attendance*',
            prefixIcon: Icon(Icons.male),
          ),
          keyboardType: TextInputType.number,
          validator: ReportValidators.nonNegativeInt,
          onSaved: (v) => _maleAttendance = int.parse(v!.trim()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Female Attendance*',
            prefixIcon: Icon(Icons.female),
          ),
          keyboardType: TextInputType.number,
          validator: ReportValidators.nonNegativeInt,
          onSaved: (v) => _femaleAttendance = int.parse(v!.trim()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Youth Attendance*',
            prefixIcon: Icon(Icons.groups),
          ),
          keyboardType: TextInputType.number,
          validator: ReportValidators.nonNegativeInt,
          onSaved: (v) => _youthAttendance = int.parse(v!.trim()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Remarks / Outcomes',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 2,
          onSaved: (v) => _remarks = v ?? '',
        ),
      ],
    );
  }
}

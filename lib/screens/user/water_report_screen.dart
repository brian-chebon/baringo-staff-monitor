import 'package:flutter/material.dart';

import 'report_form_scaffold.dart';

class WaterReportScreen extends StatefulWidget {
  final String userId;
  final String subDepartment;

  const WaterReportScreen({
    super.key,
    required this.userId,
    required this.subDepartment,
  });

  @override
  State<WaterReportScreen> createState() => _WaterReportScreenState();
}

class _WaterReportScreenState extends State<WaterReportScreen> {
  String _task = '';
  String _waterSource = '';
  double _waterQuality = 0;

  @override
  Widget build(BuildContext context) {
    return ReportFormScaffold(
      userId: widget.userId,
      title: 'Water Report - ${widget.subDepartment}',
      departmentName: 'Water, Environment, Natural Resources, and Climate Change',
      subDepartment: widget.subDepartment,
      taskHint: 'e.g. Marigat borehole inspection',
      taskBuilder: () => _task,
      collectExtraData: () => {
        'waterSource': _waterSource,
        'waterQuality': _waterQuality,
      },
      extraFields: (context) => [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Task Description*',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: ReportValidators.requiredText,
          onSaved: (v) => _task = v ?? '',
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Water Source*',
            prefixIcon: Icon(Icons.water_drop),
          ),
          validator: ReportValidators.requiredText,
          onSaved: (v) => _waterSource = v ?? '',
        ),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (ctx, setStateInner) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Water quality: ${_waterQuality.round()}%'),
              Slider(
                value: _waterQuality,
                min: 0,
                max: 100,
                divisions: 10,
                label: _waterQuality.round().toString(),
                onChanged: (v) => setStateInner(() => _waterQuality = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

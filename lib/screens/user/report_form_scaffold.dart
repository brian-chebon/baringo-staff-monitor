import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_theme.dart';
import '../../models/work_report_model.dart';
import '../../services/database_service.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';

/// Common scaffolding shared by every department-specific report screen.
///
/// Handles location capture, image upload (Firebase Storage), submission, and
/// loading/error states. Each department supplies its own [departmentName],
/// [subDepartment], and form fields via [extraFields] / [collectExtraData].
class ReportFormScaffold extends StatefulWidget {
  final String userId;
  final String title;
  final String departmentName;
  final String subDepartment;
  final String taskHint;

  /// Builds the department-specific input widgets. They must read/write from
  /// the supplied [GlobalKey<FormState>] like the other fields.
  final List<Widget> Function(BuildContext context) extraFields;

  /// Returns the additionalData map (description, attendance, etc.).
  final Map<String, dynamic> Function() collectExtraData;

  /// Optional pre-submit validation hook. Throw / return false to abort.
  final bool Function()? beforeSubmit;

  /// The "task" string saved with the report. May be a free-form task
  /// description or a selected activity type.
  final String Function() taskBuilder;

  const ReportFormScaffold({
    super.key,
    required this.userId,
    required this.title,
    required this.departmentName,
    required this.subDepartment,
    required this.taskHint,
    required this.extraFields,
    required this.collectExtraData,
    required this.taskBuilder,
    this.beforeSubmit,
  });

  @override
  State<ReportFormScaffold> createState() => ReportFormScaffoldState();
}

class ReportFormScaffoldState extends State<ReportFormScaffold> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final DatabaseService _db = DatabaseService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  String _venue = '';
  Position? _currentPosition;
  String? _localImagePath;
  bool _isSubmitting = false;
  bool _isCapturingLocation = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() => _isCapturingLocation = true);
    try {
      final pos = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _currentPosition = pos);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not capture location: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isCapturingLocation = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (image != null && mounted) {
      setState(() => _localImagePath = image.path);
    }
  }

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    if (widget.beforeSubmit != null && !widget.beforeSubmit!()) return;
    form.save();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_currentPosition == null) {
      await _captureLocation();
      if (_currentPosition == null) {
        messenger.showSnackBar(const SnackBar(
          content: Text('Location is required to submit a report.'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      String? uploadedImageUrl;
      if (_localImagePath != null) {
        uploadedImageUrl = await _storageService.uploadReportImage(
          userId: widget.userId,
          localPath: _localImagePath!,
        );
      }

      final locationInfo = await _locationService.getLocationInfo();
      final report = WorkReportModel(
        id: '',
        userId: widget.userId,
        task: widget.taskBuilder(),
        location: _venue,
        geoLocation: GeoPoint(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        date: DateTime.now(),
        ip: locationInfo.ip,
        country: locationInfo.country,
        city: locationInfo.city,
        department: widget.departmentName,
        subDepartment: widget.subDepartment,
        imageUrl: uploadedImageUrl,
        additionalData: widget.collectExtraData(),
      );

      await _db.submitWorkReport(report);

      messenger.showSnackBar(const SnackBar(
        content: Text('Report submitted successfully'),
        backgroundColor: AppColors.primaryGreen,
      ));
      if (mounted) navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Failed to submit report: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LocationStatus(
                  position: _currentPosition,
                  isCapturing: _isCapturingLocation,
                  onRetry: _captureLocation,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Venue / Location*',
                    hintText: widget.taskHint,
                    prefixIcon: const Icon(Icons.place),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Venue is required' : null,
                  onSaved: (v) => _venue = v ?? '',
                ),
                const SizedBox(height: 12),
                ...widget.extraFields(context),
                const SizedBox(height: 12),
                _ImagePickerTile(
                  imagePath: _localImagePath,
                  onPick: _pickImage,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Report',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationStatus extends StatelessWidget {
  final Position? position;
  final bool isCapturing;
  final VoidCallback onRetry;

  const _LocationStatus({
    required this.position,
    required this.isCapturing,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasFix = position != null;
    final color = hasFix
        ? AppColors.primaryGreen
        : (isCapturing ? Colors.orange : Colors.red);
    final text = isCapturing
        ? 'Capturing GPS...'
        : hasFix
            ? 'Location: ${position!.latitude.toStringAsFixed(5)}, '
                '${position!.longitude.toStringAsFixed(5)}'
            : 'No location yet';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(hasFix ? Icons.location_on : Icons.location_off, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
          if (!isCapturing)
            IconButton(
              icon: Icon(Icons.refresh, color: color),
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
        ],
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;

  const _ImagePickerTile({
    required this.imagePath,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.camera_alt),
          label: Text(imagePath == null ? 'Take Photo' : 'Retake Photo'),
        ),
        if (imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Photo ready: ${imagePath!.split('/').last}',
              style: const TextStyle(color: AppColors.primaryGreen),
            ),
          ),
      ],
    );
  }
}

/// Handy validators for numeric fields used by the department forms.
class ReportValidators {
  ReportValidators._();

  static String? requiredText(String? v) =>
      (v == null || v.isEmpty) ? 'Required' : null;

  static String? nonNegativeInt(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final parsed = int.tryParse(v.trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number';
    return null;
  }
}

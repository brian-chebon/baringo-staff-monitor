import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/baringo_data.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../user/user_home_screen.dart';

class DepartmentSelectionScreen extends StatefulWidget {
  final UserModel user;

  const DepartmentSelectionScreen({super.key, required this.user});

  @override
  State<DepartmentSelectionScreen> createState() =>
      _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  String? _selectedDepartment;
  String? _selectedSubDepartment;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final subDepartments = _selectedDepartment == null
        ? const <String>[]
        : (BaringoData.subDepartments[_selectedDepartment] ??
            const <String>[]);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Department')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Department'),
              isExpanded: true,
              initialValue: _selectedDepartment,
              items: BaringoData.departments
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedDepartment = v;
                _selectedSubDepartment = null;
              }),
              validator: (v) => v == null ? 'Select a department' : null,
            ),
            const SizedBox(height: 16),
            if (subDepartments.isNotEmpty)
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Sub-Department'),
                isExpanded: true,
                initialValue: _selectedSubDepartment,
                items: subDepartments
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedSubDepartment = v),
                validator: (v) => v == null ? 'Select a sub-department' : null,
              ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save and Continue',
              onPressed: () async {
                if (_selectedDepartment == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a department'),
                    ),
                  );
                  return;
                }
                final navigator = Navigator.of(context);
                await authProvider.updateUserProfile(
                  widget.user.copyWith(
                    department: _selectedDepartment,
                    subDepartment: _selectedSubDepartment,
                  ),
                );
                if (!mounted) return;
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const UserHomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

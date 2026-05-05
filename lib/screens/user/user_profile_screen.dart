import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  UserModel? _user;
  bool _isSaving = false;

  Future<void> _save() async {
    if (_user == null) return;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthProvider>().updateUserProfile(_user!);
      messenger.showSnackBar(const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.primaryGreen,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Failed to update: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: FutureBuilder<UserModel?>(
        future: authProvider.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text('Error: ${snapshot.error ?? 'profile not found'}'),
            );
          }
          _user ??= snapshot.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    initialValue: _user!.firstName,
                    labelText: 'First Name',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user!.copyWith(firstName: v),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    initialValue: _user!.middleName,
                    labelText: 'Middle Name',
                    onSaved: (v) =>
                        _user = _user!.copyWith(middleName: v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    initialValue: _user!.surname,
                    labelText: 'Surname',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user!.copyWith(surname: v),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    initialValue: _user!.phoneNumber,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => _user = _user!.copyWith(phoneNumber: v),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: CustomButton(
                      text: _isSaving ? 'Saving...' : 'Update Profile',
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

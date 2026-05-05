import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../constants/baringo_data.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  UserModel _user = UserModel(
    id: '',
    firstName: '',
    middleName: '',
    surname: '',
    idNumber: '',
    phoneNumber: '',
    email: '',
    department: '',
    designation: '',
    county: BaringoData.county,
    subCounty: '',
    ward: '',
    workstation: '',
  );

  String _password = '';
  String? _selectedDepartment;
  String? _selectedSubDepartment;
  String? _selectedSubCounty;
  String? _selectedWard;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all required fields.', isError: true);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    _user = _user.copyWith(
      department: _selectedDepartment,
      subDepartment: _selectedSubDepartment,
      subCounty: _selectedSubCounty,
      ward: _selectedWard,
    );

    try {
      await authProvider.signUp(_user, _password);
      _showSnackBar('Registration successful!');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) navigator.pop();
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('Registration error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wards = _selectedSubCounty == null
        ? <String>[]
        : (BaringoData.subCountyWards[_selectedSubCounty] ?? const <String>[]);
    final subDepartments = _selectedDepartment == null
        ? <String>[]
        : (BaringoData.subDepartments[_selectedDepartment] ?? const <String>[]);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Registration')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionHeader('Personal Information'),
                  TextFormField(
                    decoration: _decoration('First Name*', Icons.person),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user.copyWith(firstName: v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration:
                        _decoration('Middle Name', Icons.person_outline),
                    onSaved: (v) => _user = _user.copyWith(middleName: v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _decoration('Surname*', Icons.person),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user.copyWith(surname: v),
                  ),
                  _sectionHeader('Contact Information'),
                  TextFormField(
                    decoration: _decoration('ID Number*', Icons.badge),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user.copyWith(idNumber: v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _decoration('Phone Number*', Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user.copyWith(phoneNumber: v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _decoration('Email*', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                    onSaved: (v) => _user = _user.copyWith(email: v?.trim()),
                  ),
                  _sectionHeader('Location Details'),
                  DropdownButtonFormField<String>(
                    decoration:
                        _decoration('Sub-County*', Icons.location_city),
                    initialValue: _selectedSubCounty,
                    items: BaringoData.subCounties
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedSubCounty = v;
                      _selectedWard = null;
                    }),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  if (wards.isNotEmpty)
                    DropdownButtonFormField<String>(
                      decoration: _decoration('Ward*', Icons.map),
                      initialValue: _selectedWard,
                      items: wards
                          .map((w) =>
                              DropdownMenuItem(value: w, child: Text(w)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedWard = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  _sectionHeader('Department Information'),
                  DropdownButtonFormField<String>(
                    decoration: _decoration('Department*', Icons.business),
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
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  if (subDepartments.isNotEmpty)
                    DropdownButtonFormField<String>(
                      decoration:
                          _decoration('Directorate*', Icons.account_tree),
                      isExpanded: true,
                      initialValue: _selectedSubDepartment,
                      items: subDepartments
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child:
                                    Text(d, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSubDepartment = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  if (subDepartments.isNotEmpty) const SizedBox(height: 12),
                  TextFormField(
                    decoration: _decoration(
                      'Designation*',
                      Icons.assignment_ind,
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user.copyWith(designation: v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _decoration('Workstation*', Icons.work),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _user = _user.copyWith(workstation: v),
                  ),
                  _sectionHeader('Security'),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password*',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.primaryGreen,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.primaryGreen,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    onSaved: (v) => _password = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegistration,
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Registering...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '* Required fields',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

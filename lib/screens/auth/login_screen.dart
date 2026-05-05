import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSigningIn = true);

    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('$e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    final email = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.resetPassword),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l.email,
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return l.enterAnEmail;
                if (!value.contains('@')) return l.invalidEmail;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, controller.text.trim());
                }
              },
              child: Text(l.sendLink),
            ),
          ],
        );
      },
    );

    if (email == null) return;

    try {
      await authProvider.resetPassword(email);
      messenger.showSnackBar(SnackBar(
        content: Text(l.passwordResetSent),
        backgroundColor: AppColors.primaryGreen,
      ));
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(l),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.welcomeBack,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.pleaseSignInToContinue,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l.email,
                          prefixIcon: const Icon(
                            Icons.email,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return l.enterAnEmail;
                          if (!value.contains('@')) return l.invalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: l.password,
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return l.required;
                          if (v.length < 8) return l.passwordMin8;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v),
                                activeThumbColor: AppColors.primaryGreen,
                              ),
                              Text(
                                l.rememberMe,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(
                              l.forgotPassword,
                              style: const TextStyle(
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSigningIn ? null : _signIn,
                          child: _isSigningIn
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      l.signingIn,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  l.signIn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: '${l.dontHaveAnAccount} ',
                              style: const TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: l.signUp,
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(child: _LanguageQuickToggle()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              'assets/images/baringo_flag.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.countyGovernmentOfBaringo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.staffPerformanceMonitoringSystem,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.flagGold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l.deliverAsOne,
              style: const TextStyle(
                color: AppColors.flagBrown,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageQuickToggle extends StatelessWidget {
  const _LanguageQuickToggle();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () =>
              context.read<LocaleProvider>().setLocale(const Locale('en')),
          style: TextButton.styleFrom(
            foregroundColor: localeProvider.locale.languageCode == 'en'
                ? AppColors.primaryGreen
                : Colors.grey,
          ),
          child: Text(l.english),
        ),
        const Text('|', style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () =>
              context.read<LocaleProvider>().setLocale(const Locale('sw')),
          style: TextButton.styleFrom(
            foregroundColor: localeProvider.locale.languageCode == 'sw'
                ? AppColors.primaryGreen
                : Colors.grey,
          ),
          child: Text(l.swahili),
        ),
      ],
    );
  }
}

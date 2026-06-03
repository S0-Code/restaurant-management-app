import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/tools/validating_text_editing_controller.dart';
import '../../models/user.dart';
import '../../providers/security_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  late ValidatingTextEditingController _fullNameController;
  late ValidatingTextEditingController _emailController;
  late ValidatingTextEditingController _passwordController;
  late ValidatingTextEditingController _confirmPasswordController;
  late ValidatingTextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _fullNameController = ValidatingTextEditingController(
      validator: User.validateFullName,
      asyncValidator: User.validateFullNameUnicity,
    );
    _fullNameController.onAfterValidated = () => setState(() {});

    _emailController = ValidatingTextEditingController(
      validator: User.validateEmail,
      asyncValidator: User.validateEmailUnicity,
    );
    _emailController.onAfterValidated = () => setState(() {});

    _passwordController = ValidatingTextEditingController(
      validator: User.validatePassword,
    );
    _passwordController.onAfterValidated = () => setState(() {});

    _confirmPasswordController = ValidatingTextEditingController(
      validator: (value) => User.validateConfirmPassword(value, _passwordController.text),
    );
    _confirmPasswordController.onAfterValidated = () => setState(() {});

    _phoneController = ValidatingTextEditingController(
      validator: User.validatePhone,
      initialValue: '',
    );
    _phoneController.onAfterValidated = () => setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final isLoading = ref.watch(securityProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text('Inscription'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: min(MediaQuery.of(context).size.width * 0.9, 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Icon(Icons.person_add, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  const Text(
                    'Créez votre compte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  _fullNameFormField(context, (_) => _submitForm(context)),
                  const SizedBox(height: 16),

                  _emailFormField(context, (_) => _submitForm(context)),
                  const SizedBox(height: 16),

                  _passwordFormField(context, (_) => _submitForm(context)),
                  const SizedBox(height: 16),

                  _confirmPasswordFormField(context, (_) => _submitForm(context)),
                  const SizedBox(height: 16),

                  _phoneFormField(context, (_) => _submitForm(context)),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: isLoading ? null : () async => await _submitForm(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)
                    )
                        : const Text('S\'inscrire'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _fullNameFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _fullNameController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.name,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: 'Nom complet (*)',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
        errorText: _fullNameController.errorText,
      ),
    );
  }

  Widget _emailFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _emailController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.emailAddress,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: 'Email (*)',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.email),
        errorText: _emailController.errorText,
      ),
    );
  }

  Widget _passwordFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _passwordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: 'Mot de passe (*)',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        errorText: _passwordController.errorText,
      ),
    );
  }

  Widget _confirmPasswordFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _confirmPasswordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe (*)',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _confirmPasswordController.errorText,
      ),
    );
  }

  Widget _phoneFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _phoneController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.phone,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: 'Téléphone (optionnel)',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.phone),
        errorText: _phoneController.errorText,
      ),
    );
  }

  // --- LOGIQUE ---

  Future<void> _submitForm(BuildContext context) async {
    if (!await _validateForm()) return;

    await ref.read(securityProvider.notifier).signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    if (context.mounted) {
      final securityState = ref.read(securityProvider);
      securityState.when(
        data: (_) => Navigator.pushReplacementNamed(context, '/clientHome'),
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de créer le compte.'),
            backgroundColor: Colors.red,
          ),
        ),
        loading: () {},
      );
    }
  }

  Future<bool> _validateForm() async {
    await _fullNameController.validateAndWait();
    await _emailController.validateAndWait();
    await _passwordController.validateAndWait();
    await _confirmPasswordController.validateAndWait();
    await _phoneController.validateAndWait();
    return _isFormValid;
  }

  bool get _isFormValid =>
      _fullNameController.isValid == true &&
          _emailController.isValid == true &&
          _passwordController.isValid == true &&
          _confirmPasswordController.isValid == true &&
          _phoneController.isValid == true;
}
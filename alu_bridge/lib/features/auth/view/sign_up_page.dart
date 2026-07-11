import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../models/app_user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({required this.role, super.key});

  final UserRole role;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _fullNameError =
          _fullNameController.text.trim().isEmpty ? 'Enter your full name' : null;
      _emailError = _isValidEmail(_emailController.text.trim())
          ? null
          : 'Enter a valid email address';
      _passwordError = _passwordController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
    });
    return _fullNameError == null && _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.failure != current.failure && current.failure != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.failure!)));
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.role == UserRole.student ? 'Student account' : 'Founder account',
              style: AppTextStyles.sub,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Full name',
              controller: _fullNameController,
              errorText: _fullNameError,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              hintText: 'you@alustudent.com',
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              hintText: 'Minimum 6 characters',
              obscureText: true,
              errorText: _passwordError,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return PrimaryButton(
                  label: 'Create account',
                  loading: state.isSubmitting,
                  onPressed: () {
                    if (!_validate()) return;
                    context.read<AuthBloc>().add(
                          AuthSignUpSubmitted(
                            fullName: _fullNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            role: widget.role,
                          ),
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

bool _isValidEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

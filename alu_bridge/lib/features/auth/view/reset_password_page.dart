import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = _isValidEmail(_emailController.text.trim())
          ? null
          : 'Enter a valid email address';
    });
    return _emailError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.failure != current.failure && current.failure != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.failure!)));
        },
        builder: (context, state) {
          if (state.resetEmailSent) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: AppColors.navy,
                  ),
                  const SizedBox(height: 16),
                  Text('Check your email', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a password reset link to ${_emailController.text.trim()}.',
                    style: AppTextStyles.sub,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                "Enter the email you signed up with and we'll send you a reset link.",
                style: AppTextStyles.sub,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'you@alustudent.com',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Send reset link',
                loading: state.isSubmitting,
                onPressed: () {
                  if (!_validate()) return;
                  context.read<AuthBloc>().add(
                        AuthPasswordResetSubmitted(_emailController.text.trim()),
                      );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

bool _isValidEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

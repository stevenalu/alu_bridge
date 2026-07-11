import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../cubit/verification_cubit.dart';
import '../data/venture_repository.dart';
import '../models/venture.dart';
import 'verification_pending_page.dart';

class VerifyVenturePage extends StatefulWidget {
  const VerifyVenturePage({this.existing, super.key});

  final Venture? existing;

  @override
  State<VerifyVenturePage> createState() => _VerifyVenturePageState();
}

class _VerifyVenturePageState extends State<VerifyVenturePage> {
  late final _nameController = TextEditingController(text: widget.existing?.name);
  late final _taglineController = TextEditingController(text: widget.existing?.tagline);
  late final _aboutController = TextEditingController(text: widget.existing?.about);
  late final _sectorController = TextEditingController(text: widget.existing?.sector);
  late final _proofController =
      TextEditingController(text: widget.existing?.verification.proofUrl);

  String? _nameError;
  String? _proofError;

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _aboutController.dispose();
    _sectorController.dispose();
    _proofController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError =
          _nameController.text.trim().isEmpty ? 'Enter your venture name' : null;
      _proofError = _proofController.text.trim().isEmpty
          ? 'Add a link that proves this is a recognised ALU venture'
          : null;
    });
    return _nameError == null && _proofError == null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(ventureRepository: sl<VentureRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Get verified')),
        body: BlocConsumer<VerificationCubit, VerificationState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == VerificationSubmitStatus.failure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error!)));
            }
            if (state.status == VerificationSubmitStatus.success) {
              final uid = context.read<AuthBloc>().state.user!.uid;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => VerificationPendingPage(founderUid: uid),
                ),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Only ventures recognised at ALU can post roles. Tell us about yours.',
                  style: AppTextStyles.sub,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Venture name',
                  controller: _nameController,
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'Tagline', controller: _taglineController),
                const SizedBox(height: 16),
                AppTextField(label: 'Sector', controller: _sectorController),
                const SizedBox(height: 16),
                AppTextField(label: 'About', controller: _aboutController),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Proof of recognition',
                  hintText: 'Link to your ALU club page, Slack channel, or similar',
                  controller: _proofController,
                  errorText: _proofError,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label:
                      widget.existing == null ? 'Submit for review' : 'Resubmit for review',
                  loading: state.status == VerificationSubmitStatus.submitting,
                  onPressed: () {
                    if (!_validate()) return;
                    final uid = context.read<AuthBloc>().state.user!.uid;
                    context.read<VerificationCubit>().submit(
                          ventureId: widget.existing?.id,
                          founderUid: uid,
                          name: _nameController.text.trim(),
                          tagline: _taglineController.text.trim(),
                          about: _aboutController.text.trim(),
                          sector: _sectorController.text.trim(),
                          proofUrl: _proofController.text.trim(),
                        );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

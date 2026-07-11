import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../opportunities/models/opportunity.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/models/student_profile.dart';
import '../data/application_repository.dart';
import '../data/match_score.dart';
import 'application_sent_page.dart';

class ApplyPage extends StatefulWidget {
  const ApplyPage({required this.opportunity, super.key});

  final Opportunity opportunity;

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final _coverNoteController = TextEditingController();
  String? _coverNoteError;
  bool _submitting = false;
  String? _submitError;

  late final String _studentUid;
  late final String _studentName;
  late final Future<_ApplyContext> _future;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user!;
    _studentUid = user.uid;
    _studentName = user.fullName;
    _future = _load();
  }

  Future<_ApplyContext> _load() async {
    final profile = await sl<ProfileRepository>().fetch(_studentUid);
    final alreadyApplied = await sl<ApplicationRepository>().hasApplied(
      oppId: widget.opportunity.id,
      studentUid: _studentUid,
    );
    return _ApplyContext(profile: profile, alreadyApplied: alreadyApplied);
  }

  @override
  void dispose() {
    _coverNoteController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _coverNoteError = _coverNoteController.text.trim().length < 20
          ? 'Tell them why you are a good fit (at least 20 characters)'
          : null;
    });
    return _coverNoteError == null;
  }

  Future<void> _submit(StudentProfile? profile) async {
    if (!_validate()) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final application = await sl<ApplicationRepository>().submit(
        opportunity: widget.opportunity,
        profile: profile,
        studentUid: _studentUid,
        studentName: _studentName,
        coverNote: _coverNoteController.text.trim(),
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ApplicationSentPage(application: application),
        ),
      );
    } catch (_) {
      setState(() {
        _submitting = false;
        _submitError = 'Could not submit your application. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply to ${widget.opportunity.title}')),
      body: FutureBuilder<_ApplyContext>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final applyContext = snapshot.data!;
          if (applyContext.alreadyApplied) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'You have already applied to this role.',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final matchScore = calculateMatchScore(
            widget.opportunity.requiredSkills,
            applyContext.profile?.skills ?? [],
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text('Your match', style: AppTextStyles.label),
                  const SizedBox(width: 8),
                  MatchChip(percent: matchScore),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Cover note',
                hintText: 'Tell them why you are a great fit for this role',
                controller: _coverNoteController,
                maxLines: 6,
                errorText: _coverNoteError,
              ),
              const SizedBox(height: 20),
              if (_submitError != null) ...[
                Text(
                  _submitError!,
                  style: AppTextStyles.sub.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                label: 'Submit application',
                loading: _submitting,
                onPressed: () => _submit(applyContext.profile),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplyContext {
  const _ApplyContext({required this.profile, required this.alreadyApplied});

  final StudentProfile? profile;
  final bool alreadyApplied;
}

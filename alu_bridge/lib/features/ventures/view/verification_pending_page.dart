import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../core/widgets/verified_badge.dart';
import '../cubit/venture_cubit.dart';
import '../data/venture_repository.dart';
import '../models/venture.dart';
import 'verify_venture_page.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({required this.founderUid, super.key});

  final String founderUid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VentureCubit(
        ventureRepository: sl<VentureRepository>(),
        founderUid: founderUid,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Verification status')),
        body: BlocBuilder<VentureCubit, VentureState>(
          builder: (context, state) {
            if (state.status == VentureStatus.loading || state.venture == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final venture = state.venture!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (venture.isVerified) ...[
                    const VerifiedBadge(size: 32),
                    const SizedBox(height: 16),
                    Text('You are verified!', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      '${venture.name} can now post roles for ALU students.',
                      style: AppTextStyles.sub,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: () =>
                          Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                  ] else if (venture.verification.status ==
                      VerificationStatus.rejected) ...[
                    const StatusPill(label: 'Verification rejected', tone: PillTone.red),
                    const SizedBox(height: 16),
                    Text(
                      'Your submission was not approved. Update your details and resubmit.',
                      style: AppTextStyles.sub,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Edit and resubmit',
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => VerifyVenturePage(existing: venture),
                        ),
                      ),
                    ),
                  ] else ...[
                    const StatusPill(label: 'Pending review', tone: PillTone.warn),
                    const SizedBox(height: 16),
                    Text(
                      'We are reviewing your venture. This usually takes a couple of days.',
                      style: AppTextStyles.sub,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

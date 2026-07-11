import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/venture_repository.dart';

enum VerificationSubmitStatus { idle, submitting, success, failure }

class VerificationState extends Equatable {
  const VerificationState({this.status = VerificationSubmitStatus.idle, this.error});

  final VerificationSubmitStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit({required VentureRepository ventureRepository})
      : _ventureRepository = ventureRepository,
        super(const VerificationState());

  final VentureRepository _ventureRepository;

  Future<void> submit({
    String? ventureId,
    required String founderUid,
    required String name,
    required String tagline,
    required String about,
    required String sector,
    required String proofUrl,
  }) async {
    emit(const VerificationState(status: VerificationSubmitStatus.submitting));
    try {
      await _ventureRepository.submitForVerification(
        ventureId: ventureId,
        founderUid: founderUid,
        name: name,
        tagline: tagline,
        about: about,
        sector: sector,
        proofUrl: proofUrl,
      );
      emit(const VerificationState(status: VerificationSubmitStatus.success));
    } catch (_) {
      emit(
        const VerificationState(
          status: VerificationSubmitStatus.failure,
          error: 'Could not submit for verification. Please try again.',
        ),
      );
    }
  }
}

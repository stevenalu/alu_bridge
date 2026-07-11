import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/venture_repository.dart';
import '../models/venture.dart';

enum VentureStatus { loading, loaded }

class VentureState extends Equatable {
  const VentureState({this.status = VentureStatus.loading, this.venture});

  final VentureStatus status;
  final Venture? venture;

  @override
  List<Object?> get props => [status, venture];
}

class VentureCubit extends Cubit<VentureState> {
  VentureCubit({required VentureRepository ventureRepository, required String founderUid})
      : super(const VentureState()) {
    _subscription = ventureRepository.watchByFounder(founderUid).listen(
          (venture) => emit(VentureState(status: VentureStatus.loaded, venture: venture)),
        );
  }

  late final StreamSubscription<Venture?> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

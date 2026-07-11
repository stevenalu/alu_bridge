import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/application_repository.dart';
import '../models/application.dart';
import '../models/application_status.dart';

enum ApplicantsStatus { loading, loaded }

sealed class ApplicantsEvent extends Equatable {
  const ApplicantsEvent();

  @override
  List<Object?> get props => [];
}

class ApplicantsSubscriptionRequested extends ApplicantsEvent {
  const ApplicantsSubscriptionRequested();
}

class ApplicantsUpdated extends ApplicantsEvent {
  const ApplicantsUpdated(this.applications);

  final List<Application> applications;

  @override
  List<Object?> get props => [applications];
}

class ApplicantStatusChanged extends ApplicantsEvent {
  const ApplicantStatusChanged({required this.appId, required this.status, this.note});

  final String appId;
  final ApplicationStatus status;
  final String? note;

  @override
  List<Object?> get props => [appId, status, note];
}

class ApplicantsState extends Equatable {
  const ApplicantsState({
    this.status = ApplicantsStatus.loading,
    this.applications = const [],
  });

  final ApplicantsStatus status;
  final List<Application> applications;

  @override
  List<Object?> get props => [status, applications];
}

class ApplicantsBloc extends Bloc<ApplicantsEvent, ApplicantsState> {
  ApplicantsBloc({
    required ApplicationRepository applicationRepository,
    required String ventureId,
  })  : _applicationRepository = applicationRepository,
        _ventureId = ventureId,
        super(const ApplicantsState()) {
    on<ApplicantsSubscriptionRequested>(_onSubscriptionRequested);
    on<ApplicantsUpdated>(_onUpdated);
    on<ApplicantStatusChanged>(_onStatusChanged);
  }

  final ApplicationRepository _applicationRepository;
  final String _ventureId;
  StreamSubscription<List<Application>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ApplicantsSubscriptionRequested event,
    Emitter<ApplicantsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _applicationRepository.watchByVenture(_ventureId).listen(
          (applications) => add(ApplicantsUpdated(applications)),
          onError: (_) => add(const ApplicantsUpdated([])),
        );
  }

  void _onUpdated(ApplicantsUpdated event, Emitter<ApplicantsState> emit) {
    emit(ApplicantsState(status: ApplicantsStatus.loaded, applications: event.applications));
  }

  Future<void> _onStatusChanged(
    ApplicantStatusChanged event,
    Emitter<ApplicantsState> emit,
  ) {
    return _applicationRepository.updateStatus(event.appId, event.status, note: event.note);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

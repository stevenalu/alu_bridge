import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/application_repository.dart';
import '../models/application.dart';

enum ApplicationsStatus { loading, loaded }

sealed class ApplicationsEvent extends Equatable {
  const ApplicationsEvent();

  @override
  List<Object?> get props => [];
}

class ApplicationsSubscriptionRequested extends ApplicationsEvent {
  const ApplicationsSubscriptionRequested();
}

class ApplicationsUpdated extends ApplicationsEvent {
  const ApplicationsUpdated(this.applications);

  final List<Application> applications;

  @override
  List<Object?> get props => [applications];
}

class ApplicationsState extends Equatable {
  const ApplicationsState({
    this.status = ApplicationsStatus.loading,
    this.applications = const [],
  });

  final ApplicationsStatus status;
  final List<Application> applications;

  @override
  List<Object?> get props => [status, applications];
}

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  ApplicationsBloc({
    required ApplicationRepository applicationRepository,
    required String studentUid,
  })  : _applicationRepository = applicationRepository,
        _studentUid = studentUid,
        super(const ApplicationsState()) {
    on<ApplicationsSubscriptionRequested>(_onSubscriptionRequested);
    on<ApplicationsUpdated>(_onUpdated);
  }

  final ApplicationRepository _applicationRepository;
  final String _studentUid;
  StreamSubscription<List<Application>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ApplicationsSubscriptionRequested event,
    Emitter<ApplicationsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _applicationRepository.watchByStudent(_studentUid).listen(
          (applications) => add(ApplicationsUpdated(applications)),
          onError: (_) => add(const ApplicationsUpdated([])),
        );
  }

  void _onUpdated(ApplicationsUpdated event, Emitter<ApplicationsState> emit) {
    emit(ApplicationsState(status: ApplicationsStatus.loaded, applications: event.applications));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

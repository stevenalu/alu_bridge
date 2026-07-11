import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../profile/data/profile_repository.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import '../models/opportunity_filters.dart';

enum DiscoveryStatus { loading, loaded }

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class DiscoverySubscriptionRequested extends DiscoveryEvent {
  const DiscoverySubscriptionRequested();
}

class DiscoveryOpportunitiesUpdated extends DiscoveryEvent {
  const DiscoveryOpportunitiesUpdated(this.opportunities);

  final List<Opportunity> opportunities;

  @override
  List<Object?> get props => [opportunities];
}

class DiscoverySearchChanged extends DiscoveryEvent {
  const DiscoverySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class DiscoveryFunctionToggled extends DiscoveryEvent {
  const DiscoveryFunctionToggled(this.function);

  final String function;

  @override
  List<Object?> get props => [function];
}

class DiscoveryTypeToggled extends DiscoveryEvent {
  const DiscoveryTypeToggled(this.type);

  final String type;

  @override
  List<Object?> get props => [type];
}

class DiscoverySaveToggled extends DiscoveryEvent {
  const DiscoverySaveToggled(this.oppId);

  final String oppId;

  @override
  List<Object?> get props => [oppId];
}

class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.status = DiscoveryStatus.loading,
    this.opportunities = const [],
    this.filters = const OpportunityFilters(),
    this.savedRoleIds = const {},
  });

  final DiscoveryStatus status;
  final List<Opportunity> opportunities;
  final OpportunityFilters filters;
  final Set<String> savedRoleIds;

  List<Opportunity> get visible => opportunities.where(filters.matches).toList();

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<Opportunity>? opportunities,
    OpportunityFilters? filters,
    Set<String>? savedRoleIds,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      opportunities: opportunities ?? this.opportunities,
      filters: filters ?? this.filters,
      savedRoleIds: savedRoleIds ?? this.savedRoleIds,
    );
  }

  @override
  List<Object?> get props => [status, opportunities, filters, savedRoleIds];
}

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc({
    required OpportunityRepository opportunityRepository,
    required ProfileRepository profileRepository,
    required String studentUid,
  })  : _opportunityRepository = opportunityRepository,
        _profileRepository = profileRepository,
        _studentUid = studentUid,
        super(const DiscoveryState()) {
    on<DiscoverySubscriptionRequested>(_onSubscriptionRequested);
    on<DiscoveryOpportunitiesUpdated>(_onOpportunitiesUpdated);
    on<DiscoverySearchChanged>(_onSearchChanged);
    on<DiscoveryFunctionToggled>(_onFunctionToggled);
    on<DiscoveryTypeToggled>(_onTypeToggled);
    on<DiscoverySaveToggled>(_onSaveToggled);
  }

  final OpportunityRepository _opportunityRepository;
  final ProfileRepository _profileRepository;
  final String _studentUid;
  StreamSubscription<List<Opportunity>>? _subscription;

  Future<void> _onSubscriptionRequested(
    DiscoverySubscriptionRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    final profile = await _profileRepository.fetch(_studentUid);
    emit(state.copyWith(savedRoleIds: {...?profile?.savedRoles}));

    await _subscription?.cancel();
    _subscription = _opportunityRepository.watchLive().listen(
          (opportunities) => add(DiscoveryOpportunitiesUpdated(opportunities)),
        );
  }

  void _onOpportunitiesUpdated(
    DiscoveryOpportunitiesUpdated event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(status: DiscoveryStatus.loaded, opportunities: event.opportunities));
  }

  void _onSearchChanged(DiscoverySearchChanged event, Emitter<DiscoveryState> emit) {
    emit(state.copyWith(filters: state.filters.copyWith(query: event.query)));
  }

  void _onFunctionToggled(
    DiscoveryFunctionToggled event,
    Emitter<DiscoveryState> emit,
  ) {
    final functions = Set<String>.from(state.filters.functions);
    functions.contains(event.function)
        ? functions.remove(event.function)
        : functions.add(event.function);
    emit(state.copyWith(filters: state.filters.copyWith(functions: functions)));
  }

  void _onTypeToggled(DiscoveryTypeToggled event, Emitter<DiscoveryState> emit) {
    final types = Set<String>.from(state.filters.types);
    types.contains(event.type) ? types.remove(event.type) : types.add(event.type);
    emit(state.copyWith(filters: state.filters.copyWith(types: types)));
  }

  Future<void> _onSaveToggled(
    DiscoverySaveToggled event,
    Emitter<DiscoveryState> emit,
  ) async {
    final saved = Set<String>.from(state.savedRoleIds);
    final wasSaved = saved.contains(event.oppId);
    wasSaved ? saved.remove(event.oppId) : saved.add(event.oppId);
    emit(state.copyWith(savedRoleIds: saved));
    await _profileRepository.setRoleSaved(_studentUid, event.oppId, !wasSaved);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

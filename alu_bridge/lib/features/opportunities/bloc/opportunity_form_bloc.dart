import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';

enum OpportunityFormField {
  title,
  function,
  type,
  location,
  commitment,
  duration,
  stipend,
  description,
}

enum OpportunityFormSubmitStatus { idle, submitting, success, failure }

sealed class OpportunityFormEvent extends Equatable {
  const OpportunityFormEvent();

  @override
  List<Object?> get props => [];
}

class OpportunityFormFieldChanged extends OpportunityFormEvent {
  const OpportunityFormFieldChanged(this.field, this.value);

  final OpportunityFormField field;
  final String value;

  @override
  List<Object?> get props => [field, value];
}

class OpportunityFormResponsibilityAdded extends OpportunityFormEvent {
  const OpportunityFormResponsibilityAdded(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class OpportunityFormResponsibilityRemoved extends OpportunityFormEvent {
  const OpportunityFormResponsibilityRemoved(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class OpportunityFormSkillToggled extends OpportunityFormEvent {
  const OpportunityFormSkillToggled(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class OpportunityFormSubmitted extends OpportunityFormEvent {
  const OpportunityFormSubmitted({required this.asDraft});

  final bool asDraft;

  @override
  List<Object?> get props => [asDraft];
}

class OpportunityFormState extends Equatable {
  const OpportunityFormState({
    this.title = '',
    this.function = '',
    this.type = '',
    this.location = '',
    this.commitment = '',
    this.duration = '',
    this.stipend = '',
    this.description = '',
    this.responsibilities = const [],
    this.requiredSkills = const [],
    this.submitStatus = OpportunityFormSubmitStatus.idle,
    this.error,
  });

  final String title;
  final String function;
  final String type;
  final String location;
  final String commitment;
  final String duration;
  final String stipend;
  final String description;
  final List<String> responsibilities;
  final List<String> requiredSkills;
  final OpportunityFormSubmitStatus submitStatus;
  final String? error;

  OpportunityFormState copyWith({
    String? title,
    String? function,
    String? type,
    String? location,
    String? commitment,
    String? duration,
    String? stipend,
    String? description,
    List<String>? responsibilities,
    List<String>? requiredSkills,
    OpportunityFormSubmitStatus? submitStatus,
    String? error,
  }) {
    return OpportunityFormState(
      title: title ?? this.title,
      function: function ?? this.function,
      type: type ?? this.type,
      location: location ?? this.location,
      commitment: commitment ?? this.commitment,
      duration: duration ?? this.duration,
      stipend: stipend ?? this.stipend,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      submitStatus: submitStatus ?? this.submitStatus,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        title,
        function,
        type,
        location,
        commitment,
        duration,
        stipend,
        description,
        responsibilities,
        requiredSkills,
        submitStatus,
        error,
      ];
}

class OpportunityFormBloc extends Bloc<OpportunityFormEvent, OpportunityFormState> {
  OpportunityFormBloc({
    required OpportunityRepository opportunityRepository,
    required String ventureId,
    required String ventureName,
    required bool verified,
    this.ventureLogoUrl,
    Opportunity? existing,
  })  : _opportunityRepository = opportunityRepository,
        _ventureId = ventureId,
        _ventureName = ventureName,
        _verified = verified,
        _existing = existing,
        super(
          existing == null
              ? const OpportunityFormState()
              : OpportunityFormState(
                  title: existing.title,
                  function: existing.function,
                  type: existing.type,
                  location: existing.location,
                  commitment: existing.commitment,
                  duration: existing.duration,
                  stipend: existing.stipend,
                  description: existing.description,
                  responsibilities: existing.responsibilities,
                  requiredSkills: existing.requiredSkills,
                ),
        ) {
    on<OpportunityFormFieldChanged>(_onFieldChanged);
    on<OpportunityFormResponsibilityAdded>(_onResponsibilityAdded);
    on<OpportunityFormResponsibilityRemoved>(_onResponsibilityRemoved);
    on<OpportunityFormSkillToggled>(_onSkillToggled);
    on<OpportunityFormSubmitted>(_onSubmitted);
  }

  final OpportunityRepository _opportunityRepository;
  final String _ventureId;
  final String _ventureName;
  final String? ventureLogoUrl;
  final bool _verified;
  final Opportunity? _existing;

  void _onFieldChanged(
    OpportunityFormFieldChanged event,
    Emitter<OpportunityFormState> emit,
  ) {
    emit(
      switch (event.field) {
        OpportunityFormField.title => state.copyWith(title: event.value),
        OpportunityFormField.function => state.copyWith(function: event.value),
        OpportunityFormField.type => state.copyWith(type: event.value),
        OpportunityFormField.location => state.copyWith(location: event.value),
        OpportunityFormField.commitment => state.copyWith(commitment: event.value),
        OpportunityFormField.duration => state.copyWith(duration: event.value),
        OpportunityFormField.stipend => state.copyWith(stipend: event.value),
        OpportunityFormField.description => state.copyWith(description: event.value),
      },
    );
  }

  void _onResponsibilityAdded(
    OpportunityFormResponsibilityAdded event,
    Emitter<OpportunityFormState> emit,
  ) {
    emit(state.copyWith(responsibilities: [...state.responsibilities, event.value]));
  }

  void _onResponsibilityRemoved(
    OpportunityFormResponsibilityRemoved event,
    Emitter<OpportunityFormState> emit,
  ) {
    emit(
      state.copyWith(
        responsibilities:
            state.responsibilities.where((r) => r != event.value).toList(),
      ),
    );
  }

  void _onSkillToggled(
    OpportunityFormSkillToggled event,
    Emitter<OpportunityFormState> emit,
  ) {
    final skills = List<String>.from(state.requiredSkills);
    skills.contains(event.value) ? skills.remove(event.value) : skills.add(event.value);
    emit(state.copyWith(requiredSkills: skills));
  }

  Future<void> _onSubmitted(
    OpportunityFormSubmitted event,
    Emitter<OpportunityFormState> emit,
  ) async {
    emit(state.copyWith(submitStatus: OpportunityFormSubmitStatus.submitting));
    try {
      final opportunity = Opportunity(
        id: _existing?.id ?? '',
        ventureId: _ventureId,
        ventureName: _ventureName,
        ventureLogoUrl: ventureLogoUrl,
        verified: _verified,
        title: state.title,
        function: state.function,
        type: state.type,
        location: state.location,
        commitment: state.commitment,
        duration: state.duration,
        stipend: state.stipend,
        description: state.description,
        responsibilities: state.responsibilities,
        requiredSkills: state.requiredSkills,
        status: event.asDraft ? OpportunityStatus.draft : OpportunityStatus.live,
        applicantCount: _existing?.applicantCount ?? 0,
        createdAt: _existing?.createdAt ?? DateTime.now(),
      );
      await _opportunityRepository.save(opportunity);
      emit(state.copyWith(submitStatus: OpportunityFormSubmitStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          submitStatus: OpportunityFormSubmitStatus.failure,
          error: 'Could not save this role. Please try again.',
        ),
      );
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/profile_repository.dart';
import '../models/student_profile.dart';

enum ProfileSaveStatus { idle, saving, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.headline = '',
    this.programme = '',
    this.yearOfStudy = 1,
    this.bio = '',
    this.skills = const [],
    this.saveStatus = ProfileSaveStatus.idle,
    this.error,
  });

  final String headline;
  final String programme;
  final int yearOfStudy;
  final String bio;
  final List<String> skills;
  final ProfileSaveStatus saveStatus;
  final String? error;

  ProfileState copyWith({
    String? headline,
    String? programme,
    int? yearOfStudy,
    String? bio,
    List<String>? skills,
    ProfileSaveStatus? saveStatus,
    String? error,
  }) {
    return ProfileState(
      headline: headline ?? this.headline,
      programme: programme ?? this.programme,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      saveStatus: saveStatus ?? this.saveStatus,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [headline, programme, yearOfStudy, bio, skills, saveStatus, error];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository profileRepository, required String uid})
      : _profileRepository = profileRepository,
        _uid = uid,
        super(const ProfileState());

  final ProfileRepository _profileRepository;
  final String _uid;

  void headlineChanged(String value) => emit(state.copyWith(headline: value));

  void programmeChanged(String value) => emit(state.copyWith(programme: value));

  void yearOfStudyChanged(int value) => emit(state.copyWith(yearOfStudy: value));

  void bioChanged(String value) => emit(state.copyWith(bio: value));

  void toggleSkill(String skill) {
    final skills = List<String>.from(state.skills);
    skills.contains(skill) ? skills.remove(skill) : skills.add(skill);
    emit(state.copyWith(skills: skills));
  }

  Future<void> save() async {
    emit(state.copyWith(saveStatus: ProfileSaveStatus.saving));
    try {
      final profile = StudentProfile(
        uid: _uid,
        headline: state.headline,
        programme: state.programme,
        yearOfStudy: state.yearOfStudy,
        bio: state.bio,
        skills: state.skills,
        savedRoles: const [],
      );
      await _profileRepository.save(profile);
      emit(state.copyWith(saveStatus: ProfileSaveStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.failure,
          error: 'Could not save your profile. Please try again.',
        ),
      );
    }
  }
}

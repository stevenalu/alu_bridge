import 'package:equatable/equatable.dart';

import 'opportunity.dart';

abstract class OpportunityFunction {
  static const options = [
    'Software Development',
    'UI/UX Design',
    'Marketing',
    'Operations',
    'Research',
    'Business Analysis',
    'Content Creation',
    'Community Management',
  ];
}

abstract class OpportunityType {
  static const options = ['Internship', 'Part-time', 'Volunteer', 'Contract'];
}

class OpportunityFilters extends Equatable {
  const OpportunityFilters({
    this.query = '',
    this.functions = const {},
    this.types = const {},
  });

  final String query;
  final Set<String> functions;
  final Set<String> types;

  OpportunityFilters copyWith({
    String? query,
    Set<String>? functions,
    Set<String>? types,
  }) {
    return OpportunityFilters(
      query: query ?? this.query,
      functions: functions ?? this.functions,
      types: types ?? this.types,
    );
  }

  bool matches(Opportunity opportunity) {
    if (functions.isNotEmpty && !functions.contains(opportunity.function)) return false;
    if (types.isNotEmpty && !types.contains(opportunity.type)) return false;
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    return opportunity.title.toLowerCase().contains(q) ||
        opportunity.ventureName.toLowerCase().contains(q) ||
        opportunity.requiredSkills.any((skill) => skill.toLowerCase().contains(q));
  }

  @override
  List<Object?> get props => [query, functions, types];
}

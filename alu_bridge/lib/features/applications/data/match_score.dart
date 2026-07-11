/// Percentage overlap between a role's required skills and a student's
/// skills. Case-insensitive and whitespace-trimmed so minor formatting
/// differences between the two lists don't undercount a real match.
int calculateMatchScore(List<String> requiredSkills, List<String> studentSkills) {
  if (requiredSkills.isEmpty) return 0;

  final required = requiredSkills.map((skill) => skill.trim().toLowerCase()).toSet();
  final owned = studentSkills.map((skill) => skill.trim().toLowerCase()).toSet();
  final overlap = required.intersection(owned).length;

  return ((overlap / required.length) * 100).round();
}

enum ApplicationStatus { submitted, underReview, shortlisted, interview, offer, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get value => switch (this) {
        ApplicationStatus.submitted => 'submitted',
        ApplicationStatus.underReview => 'under_review',
        ApplicationStatus.shortlisted => 'shortlisted',
        ApplicationStatus.interview => 'interview',
        ApplicationStatus.offer => 'offer',
        ApplicationStatus.rejected => 'rejected',
      };

  String get label => switch (this) {
        ApplicationStatus.submitted => 'Submitted',
        ApplicationStatus.underReview => 'Under review',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.interview => 'Interview',
        ApplicationStatus.offer => 'Offer',
        ApplicationStatus.rejected => 'Rejected',
      };

  static ApplicationStatus fromValue(String value) =>
      ApplicationStatus.values.firstWhere((status) => status.value == value);
}

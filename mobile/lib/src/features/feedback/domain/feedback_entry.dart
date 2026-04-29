enum FeedbackType {
  bug,
  idea,
  feedback,
}

class FeedbackSubmission {
  const FeedbackSubmission({
    required this.type,
    required this.text,
  });

  final FeedbackType type;
  final String text;
}

extension FeedbackTypeApiValue on FeedbackType {
  String get apiValue {
    switch (this) {
      case FeedbackType.bug:
        return 'bug';
      case FeedbackType.idea:
        return 'idea';
      case FeedbackType.feedback:
        return 'feedback';
    }
  }
}

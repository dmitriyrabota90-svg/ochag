import '../domain/feedback_entry.dart';

class FeedbackRequestDto {
  const FeedbackRequestDto({
    required this.type,
    required this.text,
  });

  factory FeedbackRequestDto.fromDomain(FeedbackSubmission submission) {
    return FeedbackRequestDto(
      type: submission.type.apiValue,
      text: submission.text,
    );
  }

  final String type;
  final String text;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
    };
  }
}

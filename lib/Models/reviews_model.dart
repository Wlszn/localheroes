class ReviewsModel {
  final int reviewId;
  final int reviewerId;
  final int taskId;
  final int reviewedId;
  final num rating;
  final String comment;
  final DateTime createdAt;

  ReviewsModel({
    required this.reviewId,
    required this.reviewerId,
    required this.taskId,
    required this.reviewedId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'ReviewsModel{reviewId: $reviewId, reviewerId: $reviewerId, taskId: $taskId, reviewedId: $reviewedId, rating: $rating, comment: $comment, createdAt: $createdAt}';
  }
}

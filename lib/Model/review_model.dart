class ReviewModel {
  final int reviewId;
  final int userId;
  final int taskId;
  final num rating;
  final String comment;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.taskId,
    required this.rating,
    required this.comment,
  });

  @override
  String toString() {
    return 'ReviewModel{reviewId: $reviewId, userId: $userId, taskId: $taskId, rating: $rating, comment: $comment}';
  }
}

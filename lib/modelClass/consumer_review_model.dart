class ConsumerReviewModel {
  String comment;
  String consumerId, dateTime, profileImageId;
  String firstName, lastName;
  int rating;
  ConsumerReviewModel(
      {this.firstName,
      this.lastName,
      this.rating,
      this.comment,
      this.consumerId,
      this.profileImageId,
      this.dateTime});
}

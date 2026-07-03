class LoanModel {
  String id;
  String bookId;
  String userId;
  String date;
  String status;

  LoanModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'date': date,
      'status': status,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'],
      bookId: map['bookId'],
      userId: map['userId'],
      date: map['date'],
      status: map['status'],
    );
  }
}

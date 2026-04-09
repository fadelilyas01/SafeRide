class ChatMessageModel {
  final String? id;
  final String rideId;
  final String senderId;
  final String message;
  final DateTime? createdAt;

  ChatMessageModel({
    this.id,
    required this.rideId,
    required this.senderId,
    required this.message,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      rideId: json['ride_id'],
      senderId: json['sender_id'],
      message: json['message'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ride_id': rideId,
      'sender_id': senderId,
      'message': message,
    };
  }
}

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage(MessageEntity message);
  Stream<List<MessageEntity>> getMessages(String rideId);
}

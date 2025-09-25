import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/room.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<Room>>> getRooms();

  Future<Either<Failure, Room>> getRoomById(String roomId);

  Future<Either<Failure, List<Room>>> getAvailableRooms({
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<Either<Failure, bool>> isRoomAvailable({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
  });

  Stream<List<Room>> watchRooms();
}

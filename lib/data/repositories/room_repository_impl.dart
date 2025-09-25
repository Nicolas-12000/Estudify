import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/supabase_room_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;

  RoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      final rooms = await remoteDataSource.getRooms();
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Room>> getRoomById(String roomId) async {
    try {
      final room = await remoteDataSource.getRoomById(roomId);
      return Right(room);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Room>>> getAvailableRooms({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final rooms = await remoteDataSource.getAvailableRooms(
        startTime: startTime,
        endTime: endTime,
      );
      return Right(rooms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isRoomAvailable({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final isAvailable = await remoteDataSource.isRoomAvailable(
        roomId: roomId,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(isAvailable);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Room>> watchRooms() => remoteDataSource.watchRooms();
}

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/room.dart';
import '../../repositories/room_repository.dart';

class GetAvailableRoomsParams {
  final DateTime startTime;
  final DateTime endTime;

  const GetAvailableRoomsParams({
    required this.startTime,
    required this.endTime,
  });
}

class GetAvailableRooms
    implements UseCase<List<Room>, GetAvailableRoomsParams> {
  final RoomRepository repository;

  const GetAvailableRooms(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call(
      GetAvailableRoomsParams params) async {
    return await repository.getAvailableRooms(
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}

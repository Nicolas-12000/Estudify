import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/reservation.dart';
import '../../repositories/reservation_repository.dart';

class CreateReservationParams {
  final String roomId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const CreateReservationParams({
    required this.roomId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });
}

class CreateReservation
    implements UseCase<Reservation, CreateReservationParams> {
  final ReservationRepository repository;

  const CreateReservation(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(
      CreateReservationParams params) async {
    // Validación básica
    if (params.startTime.isAfter(params.endTime)) {
      return const Left(ValidationFailure(
          'La hora de inicio debe ser anterior a la hora de fin'));
    }

    if (params.startTime.isBefore(DateTime.now())) {
      return const Left(ValidationFailure('No se puede reservar en el pasado'));
    }

    return await repository.createReservation(
      roomId: params.roomId,
      startTime: params.startTime,
      endTime: params.endTime,
      notes: params.notes,
    );
  }
}

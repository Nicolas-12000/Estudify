import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<Either<Failure, Reservation>> createReservation({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  Future<Either<Failure, List<Reservation>>> getUserReservations();

  Future<Either<Failure, Reservation>> updateReservation({
    required String reservationId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  });

  Future<Either<Failure, void>> cancelReservation(String reservationId);

  Future<Either<Failure, List<Reservation>>> getRoomReservations({
    required String roomId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Stream<List<Reservation>> watchUserReservations();
}

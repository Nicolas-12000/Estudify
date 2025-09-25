import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/supabase_reservation_datasource.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Reservation>> createReservation({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final reservation = await remoteDataSource.createReservation(
        roomId: roomId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      return Right(reservation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reservation>>> getUserReservations() async {
    try {
      final reservations = await remoteDataSource.getUserReservations();
      return Right(reservations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> updateReservation({
    required String reservationId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  }) async {
    try {
      final reservation = await remoteDataSource.updateReservation(
        reservationId: reservationId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      return Right(reservation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String reservationId) async {
    try {
      await remoteDataSource.cancelReservation(reservationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reservation>>> getRoomReservations({
    required String roomId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final reservations = await remoteDataSource.getRoomReservations(
        roomId: roomId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(reservations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Reservation>> watchUserReservations() =>
      remoteDataSource.watchUserReservations();
}

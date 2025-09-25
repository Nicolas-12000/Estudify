import 'package:equatable/equatable.dart';
import '../../../domain/entities/reservation.dart';

enum ReservationsStatus { initial, loading, loaded, error, creating, created }

class ReservationsState extends Equatable {
  final ReservationsStatus status;
  final List<Reservation> reservations;
  final String? errorMessage;
  final String? successMessage;

  const ReservationsState({
    this.status = ReservationsStatus.initial,
    this.reservations = const [],
    this.errorMessage,
    this.successMessage,
  });

  ReservationsState copyWith({
    ReservationsStatus? status,
    List<Reservation>? reservations,
    String? errorMessage,
    String? successMessage,
  }) {
    return ReservationsState(
      status: status ?? this.status,
      reservations: reservations ?? this.reservations,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, reservations, errorMessage, successMessage];
}

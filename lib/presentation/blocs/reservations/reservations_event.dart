import 'package:equatable/equatable.dart';

abstract class ReservationsEvent extends Equatable {
  const ReservationsEvent();

  @override
  List<Object?> get props => [];
}

class ReservationsLoadRequested extends ReservationsEvent {}

class ReservationCreateRequested extends ReservationsEvent {
  final String roomId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const ReservationCreateRequested({
    required this.roomId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  @override
  List<Object?> get props => [roomId, startTime, endTime, notes];
}

class ReservationCancelRequested extends ReservationsEvent {
  final String reservationId;

  const ReservationCancelRequested(this.reservationId);

  @override
  List<Object> get props => [reservationId];
}

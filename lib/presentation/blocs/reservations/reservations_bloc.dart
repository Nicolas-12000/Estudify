import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/reservations/create_reservation.dart';
import 'reservations_event.dart';
import 'reservations_state.dart';

class ReservationsBloc extends Bloc<ReservationsEvent, ReservationsState> {
  final CreateReservation createReservation;

  ReservationsBloc({
    required this.createReservation,
  }) : super(const ReservationsState()) {
    on<ReservationsLoadRequested>(_onLoadRequested);
    on<ReservationCreateRequested>(_onCreateRequested);
    on<ReservationCancelRequested>(_onCancelRequested);
  }

  Future<void> _onLoadRequested(
    ReservationsLoadRequested event,
    Emitter<ReservationsState> emit,
  ) async {
    emit(state.copyWith(status: ReservationsStatus.loading));

    // TODO: Load user reservations
    emit(state.copyWith(
      status: ReservationsStatus.loaded,
      reservations: [],
    ));
  }

  Future<void> _onCreateRequested(
    ReservationCreateRequested event,
    Emitter<ReservationsState> emit,
  ) async {
    emit(state.copyWith(status: ReservationsStatus.creating));

    final result = await createReservation(CreateReservationParams(
      roomId: event.roomId,
      startTime: event.startTime,
      endTime: event.endTime,
      notes: event.notes,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ReservationsStatus.error,
        errorMessage: failure.toString(),
      )),
      (reservation) => emit(state.copyWith(
        status: ReservationsStatus.created,
        successMessage: 'Reserva creada con éxito',
      )),
    );
  }

  Future<void> _onCancelRequested(
    ReservationCancelRequested event,
    Emitter<ReservationsState> emit,
  ) async {
    emit(state.copyWith(status: ReservationsStatus.loading));

    // TODO: call cancelReservation usecase
    emit(state.copyWith(status: ReservationsStatus.loaded));
  }
}

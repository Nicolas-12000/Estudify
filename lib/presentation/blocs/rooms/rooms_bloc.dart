import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/rooms/get_available_rooms.dart';
import '../../../domain/entities/room.dart';
import 'rooms_event.dart';
import 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final GetAvailableRooms getAvailableRooms;

  RoomsBloc({
    required this.getAvailableRooms,
  }) : super(const RoomsState()) {
    on<RoomsLoadRequested>(_onLoadRequested);
    on<RoomsAvailabilityRequested>(_onAvailabilityRequested);
    on<RoomsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    RoomsLoadRequested event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(status: RoomsStatus.loading));

    // TODO: Load all rooms
    emit(state.copyWith(
      status: RoomsStatus.loaded,
      rooms: [],
      filteredRooms: [],
    ));
  }

  Future<void> _onAvailabilityRequested(
    RoomsAvailabilityRequested event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(status: RoomsStatus.loading));

    final result = await getAvailableRooms(GetAvailableRoomsParams(
      startTime: event.startTime,
      endTime: event.endTime,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: RoomsStatus.error,
        errorMessage: failure.toString(),
      )),
      (rooms) => emit(state.copyWith(
        status: RoomsStatus.loaded,
        rooms: rooms,
        filteredRooms: rooms,
      )),
    );
  }

  Future<void> _onFilterChanged(
    RoomsFilterChanged event,
    Emitter<RoomsState> emit,
  ) async {
    var filteredRooms = List<Room>.from(state.rooms);

    // Filter by search query
    if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
      filteredRooms = filteredRooms
          .where((room) =>
              room.name
                  .toLowerCase()
                  .contains(event.searchQuery!.toLowerCase()) ||
              (room.description
                      ?.toLowerCase()
                      .contains(event.searchQuery!.toLowerCase()) ??
                  false))
          .toList();
    }

    // Filter by capacity
    if (event.minCapacity != null) {
      filteredRooms = filteredRooms
          .where((room) => room.capacity >= event.minCapacity!)
          .toList();
    }

    // Filter by amenities
    if (event.amenities != null && event.amenities!.isNotEmpty) {
      filteredRooms = filteredRooms
          .where((room) => event.amenities!
              .every((amenity) => room.amenities.contains(amenity)))
          .toList();
    }

    emit(state.copyWith(
      filteredRooms: filteredRooms,
      searchQuery: event.searchQuery,
      minCapacity: event.minCapacity,
      amenitiesFilter: event.amenities,
    ));
  }
}

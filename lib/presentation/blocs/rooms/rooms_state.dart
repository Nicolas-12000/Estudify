import 'package:equatable/equatable.dart';
import '../../../domain/entities/room.dart';

enum RoomsStatus { initial, loading, loaded, error }

class RoomsState extends Equatable {
  final RoomsStatus status;
  final List<Room> rooms;
  final List<Room> filteredRooms;
  final String? errorMessage;
  final String? searchQuery;
  final int? minCapacity;
  final List<String>? amenitiesFilter;

  const RoomsState({
    this.status = RoomsStatus.initial,
    this.rooms = const [],
    this.filteredRooms = const [],
    this.errorMessage,
    this.searchQuery,
    this.minCapacity,
    this.amenitiesFilter,
  });

  RoomsState copyWith({
    RoomsStatus? status,
    List<Room>? rooms,
    List<Room>? filteredRooms,
    String? errorMessage,
    String? searchQuery,
    int? minCapacity,
    List<String>? amenitiesFilter,
  }) {
    return RoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      filteredRooms: filteredRooms ?? this.filteredRooms,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      minCapacity: minCapacity ?? this.minCapacity,
      amenitiesFilter: amenitiesFilter ?? this.amenitiesFilter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rooms,
        filteredRooms,
        errorMessage,
        searchQuery,
        minCapacity,
        amenitiesFilter,
      ];
}

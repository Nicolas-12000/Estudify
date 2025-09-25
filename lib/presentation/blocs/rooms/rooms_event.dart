import 'package:equatable/equatable.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object?> get props => [];
}

class RoomsLoadRequested extends RoomsEvent {}

class RoomsAvailabilityRequested extends RoomsEvent {
  final DateTime startTime;
  final DateTime endTime;

  const RoomsAvailabilityRequested({
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [startTime, endTime];
}

class RoomsFilterChanged extends RoomsEvent {
  final String? searchQuery;
  final int? minCapacity;
  final List<String>? amenities;

  const RoomsFilterChanged({
    this.searchQuery,
    this.minCapacity,
    this.amenities,
  });

  @override
  List<Object?> get props => [searchQuery, minCapacity, amenities];
}

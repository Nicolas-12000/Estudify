import 'package:equatable/equatable.dart';

enum RoomStatus { available, occupied, maintenance }

class Room extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int capacity;
  final RoomStatus status;
  final List<String> amenities;
  final String? imageUrl;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Room({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    required this.status,
    required this.amenities,
    this.imageUrl,
    required this.location,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        capacity,
        status,
        amenities,
        imageUrl,
        location,
        createdAt,
        updatedAt
      ];

  Room copyWith({
    String? id,
    String? name,
    String? description,
    int? capacity,
    RoomStatus? status,
    List<String>? amenities,
    String? imageUrl,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => status == RoomStatus.available;
}

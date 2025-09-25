import '../../domain/entities/room.dart';

class RoomModel extends Room {
  const RoomModel({
    required super.id,
    required super.name,
    super.description,
    required super.capacity,
    required super.status,
    required super.amenities,
    super.imageUrl,
    required super.location,
    required super.createdAt,
    super.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int,
      status: RoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoomStatus.available,
      ),
      amenities: List<String>.from(json['amenities'] ?? []),
      imageUrl: json['image_url'] as String?,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'status': status.name,
      'amenities': amenities,
      'image_url': imageUrl,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

import '../../domain/entities/reservation.dart';
import 'user_model.dart';
import 'room_model.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.userId,
    required super.roomId,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.user,
    super.room,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roomId: json['room_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReservationStatus.active,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
      room: json['rooms'] != null ? RoomModel.fromJson(json['rooms']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

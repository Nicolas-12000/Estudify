import 'package:equatable/equatable.dart';
import 'user.dart';
import 'room.dart';

enum ReservationStatus { active, cancelled, completed, expired }

class Reservation extends Equatable {
  final String id;
  final String userId;
  final String roomId;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;
  final Room? room;

  const Reservation({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.room,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        roomId,
        startTime,
        endTime,
        status,
        notes,
        createdAt,
        updatedAt,
        user,
        room
      ];

  Duration get duration => endTime.difference(startTime);
  bool get isActive => status == ReservationStatus.active;
  bool get canBeCancelled =>
      status == ReservationStatus.active &&
      startTime.isAfter(DateTime.now().add(const Duration(hours: 1)));

  Reservation copyWith({
    String? id,
    String? userId,
    String? roomId,
    DateTime? startTime,
    DateTime? endTime,
    ReservationStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    Room? room,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      room: room ?? this.room,
    );
  }
}

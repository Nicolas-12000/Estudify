import 'package:flutter/material.dart';
import '../../domain/entities/room.dart';
import 'custom_button.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final DateTime? startTime;
  final DateTime? endTime;
  final VoidCallback? onReserve;

  const RoomCard({
    super.key,
    required this.room,
    this.startTime,
    this.endTime,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            room.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(room.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(room.status),
                    style: TextStyle(
                      color: _getStatusColor(room.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (room.description != null) ...[
              const SizedBox(height: 12),
              Text(
                room.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Capacidad: ${room.capacity} personas',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (room.amenities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: room.amenities.take(3).map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      amenity,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (startTime != null && endTime != null && onReserve != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: room.isAvailable ? onReserve : null,
                  text: room.isAvailable ? 'Reservar' : 'No disponible',
                  backgroundColor: room.isAvailable ? null : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green;
      case RoomStatus.occupied:
        return Colors.orange;
      case RoomStatus.maintenance:
        return Colors.red;
    }
  }

  String _getStatusText(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return 'Disponible';
      case RoomStatus.occupied:
        return 'Ocupada';
      case RoomStatus.maintenance:
        return 'Mantenimiento';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reservation.dart';
import 'custom_button.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onCancel,
    this.onEdit,
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
                        reservation.room?.name ?? 'Sala ${reservation.roomId}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (reservation.room?.location != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reservation.room!.location,
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
                    color: _getStatusColor(reservation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(reservation.status),
                    style: TextStyle(
                      color: _getStatusColor(reservation.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(reservation.startTime)} - ${DateFormat('HH:mm').format(reservation.endTime)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Duración: ${_formatDuration(reservation.duration)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notas: ${reservation.notes}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (reservation.canBeCancelled && (onCancel != null || onEdit != null)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: CustomButton(
                        onPressed: onEdit,
                        text: 'Editar',
                        isOutlined: true,
                      ),
                    ),
                  if (onEdit != null && onCancel != null)
                    const SizedBox(width: 12),
                  if (onCancel != null)
                    Expanded(
                      child: CustomButton(
                        onPressed: onCancel,
                        text: 'Cancelar',
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.active:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
      case ReservationStatus.expired:
        return Colors.grey;
    }
  }

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.active:
        return 'Activa';
      case ReservationStatus.cancelled:
        return 'Cancelada';
      case ReservationStatus.completed:
        return 'Completada';
      case ReservationStatus.expired:
        return 'Expirada';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

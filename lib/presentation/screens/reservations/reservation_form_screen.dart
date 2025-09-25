import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/room.dart';
import '../../blocs/reservations/reservations_bloc.dart';
import '../../blocs/reservations/reservations_event.dart';
import '../../blocs/reservations/reservations_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Room? _room;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _room = args['room'] as Room?;
      _startTime = args['startTime'] as DateTime?;
      _endTime = args['endTime'] as DateTime?;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _makeReservation() {
    if (_formKey.currentState!.validate() &&
        _room != null &&
        _startTime != null &&
        _endTime != null) {
      context.read<ReservationsBloc>().add(ReservationCreateRequested(
            roomId: _room!.id,
            startTime: _startTime!,
            endTime: _endTime!,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_room == null || _startTime == null || _endTime == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Datos de reserva no válidos'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Reserva'),
      ),
      body: BlocListener<ReservationsBloc, ReservationsState>(
        listener: (context, state) {
          if (state.status == ReservationsStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.successMessage ?? 'Reserva creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          } else if (state.status == ReservationsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al crear reserva'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles de la reserva',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Sala:', _room!.name),
                        _buildInfoRow('Ubicación:', _room!.location),
                        _buildInfoRow(
                            'Capacidad:', '${_room!.capacity} personas'),
                        _buildInfoRow('Fecha:', _formatDate(_startTime!)),
                        _buildInfoRow('Hora:',
                            '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}'),
                        _buildInfoRow('Duración:',
                            _formatDuration(_endTime!.difference(_startTime!))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Notes field
                CustomTextField(
                  controller: _notesController,
                  label: 'Notas (opcional)',
                  hintText: 'Agregar notas sobre tu reserva...',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<ReservationsBloc, ReservationsState>(
                    builder: (context, state) {
                      return CustomButton(
                        onPressed: state.status == ReservationsStatus.creating
                            ? null
                            : _makeReservation,
                        text: 'Confirmar Reserva',
                        isLoading: state.status == ReservationsStatus.creating,
                        icon: Icons.check,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Terms text
                Text(
                  'Al confirmar la reserva, aceptas los términos y condiciones de uso de Estudify.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

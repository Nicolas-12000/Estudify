import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/reservations/reservations_bloc.dart';
import '../../blocs/reservations/reservations_event.dart';
import '../../blocs/reservations/reservations_state.dart';
import '../../../domain/entities/reservation.dart';
import '../../widgets/reservation_card.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ReservationsBloc>().add(ReservationsLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Historial'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: BlocListener<ReservationsBloc, ReservationsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildReservationsList(ReservationStatus.active),
            _buildReservationsList(ReservationStatus.completed),
            _buildReservationsList(ReservationStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(ReservationStatus status) {
    return BlocBuilder<ReservationsBloc, ReservationsState>(
      builder: (context, state) {
        if (state.status == ReservationsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ReservationsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text('Error al cargar las reservas'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<ReservationsBloc>()
                        .add(ReservationsLoadRequested());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final filteredReservations =
            state.reservations.where((r) => r.status == status).toList();

        if (filteredReservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(status),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredReservations.length,
          itemBuilder: (context, index) {
            final reservation = filteredReservations[index];
            return ReservationCard(
              reservation: reservation,
              onCancel: reservation.canBeCancelled
                  ? () => _showCancelDialog(reservation.id)
                  : null,
            );
          },
        );
      },
    );
  }

  String _getEmptyMessage(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.active:
        return 'No tienes reservas activas.\n¡Haz tu primera reserva!';
      case ReservationStatus.completed:
        return 'No tienes reservas completadas aún.';
      case ReservationStatus.cancelled:
        return 'No tienes reservas canceladas.';
      case ReservationStatus.expired:
        return 'No tienes reservas expiradas.';
    }
  }

  void _showCancelDialog(String reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content:
            const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ReservationsBloc>().add(
                    ReservationCancelRequested(reservationId),
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

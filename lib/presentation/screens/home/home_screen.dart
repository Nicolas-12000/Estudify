import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/rooms/rooms_bloc.dart';
import '../../blocs/rooms/rooms_event.dart';
import '../../blocs/rooms/rooms_state.dart';
import '../../widgets/room_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/filter_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    context.read<RoomsBloc>().add(RoomsLoadRequested());
  }

  void _selectTimeRange() async {
    final now = DateTime.now();
    final startTime = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (startTime == null) return;

    if (!mounted) return;

    final startTimeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTimeOfDay == null) return;

    final start = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      startTimeOfDay.hour,
      startTimeOfDay.minute,
    );

    if (!mounted) return;

    final endTimeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTimeOfDay.hour + 2,
        minute: startTimeOfDay.minute,
      ),
    );

    if (endTimeOfDay == null) return;

    final end = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      endTimeOfDay.hour,
      endTimeOfDay.minute,
    );

    if (end.isBefore(start)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('La hora de fin debe ser posterior a la hora de inicio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedStartTime = start;
      _selectedEndTime = end;
    });

    // Avoid using BuildContext across async gaps: ensure widget is still mounted
    if (!mounted) return;
    context.read<RoomsBloc>().add(RoomsAvailabilityRequested(
          startTime: start,
          endTime: end,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Time selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona horario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectTimeRange,
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          _selectedStartTime != null && _selectedEndTime != null
                              ? '${_formatTime(_selectedStartTime!)} - ${_formatTime(_selectedEndTime!)}'
                              : 'Seleccionar horario',
                        ),
                      ),
                    ),
                    if (_selectedStartTime != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedStartTime = null;
                            _selectedEndTime = null;
                          });
                          context.read<RoomsBloc>().add(RoomsLoadRequested());
                        },
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Search and filters
          SearchBarWidget(
            onSearchChanged: (query) {
              context.read<RoomsBloc>().add(RoomsFilterChanged(
                    searchQuery: query,
                  ));
            },
          ),
          const FilterChips(),
          // Rooms list
          Expanded(
            child: BlocBuilder<RoomsBloc, RoomsState>(
              builder: (context, state) {
                if (state.status == RoomsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == RoomsStatus.error) {
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
                        Text(
                          'Error al cargar las salas',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedStartTime != null &&
                                _selectedEndTime != null) {
                              context
                                  .read<RoomsBloc>()
                                  .add(RoomsAvailabilityRequested(
                                    startTime: _selectedStartTime!,
                                    endTime: _selectedEndTime!,
                                  ));
                            } else {
                              context
                                  .read<RoomsBloc>()
                                  .add(RoomsLoadRequested());
                            }
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStartTime != null
                              ? 'No hay salas disponibles\nen el horario seleccionado'
                              : 'Selecciona un horario\npara ver salas disponibles',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = state.filteredRooms[index];
                    return RoomCard(
                      room: room,
                      startTime: _selectedStartTime,
                      endTime: _selectedEndTime,
                      onReserve: () {
                        if (_selectedStartTime != null &&
                            _selectedEndTime != null) {
                          Navigator.pushNamed(
                            context,
                            '/reservation',
                            arguments: {
                              'room': room,
                              'startTime': _selectedStartTime,
                              'endTime': _selectedEndTime,
                            },
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/reservations'),
        child: const Icon(Icons.bookmark),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

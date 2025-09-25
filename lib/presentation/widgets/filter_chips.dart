import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/rooms/rooms_bloc.dart';
import '../blocs/rooms/rooms_event.dart';
import '../blocs/rooms/rooms_state.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomsBloc, RoomsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCapacityChip(context, '1-4 personas', 1, 4, state.minCapacity),
                    const SizedBox(width: 8),
                    _buildCapacityChip(context, '5-10 personas', 5, 10, state.minCapacity),
                    const SizedBox(width: 8),
                    _buildCapacityChip(context, '10+ personas', 10, null, state.minCapacity),
                    const SizedBox(width: 8),
                    _buildAmenityChip(context, 'Proyector', state.amenitiesFilter),
                    const SizedBox(width: 8),
                    _buildAmenityChip(context, 'WiFi', state.amenitiesFilter),
                    const SizedBox(width: 8),
                    _buildAmenityChip(context, 'Pizarra', state.amenitiesFilter),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCapacityChip(
    BuildContext context,
    String label,
    int min,
    int? max,
    int? currentCapacity,
  ) {
    final isSelected = currentCapacity != null && 
        currentCapacity >= min && 
        (max == null || currentCapacity <= max);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<RoomsBloc>().add(RoomsFilterChanged(
          minCapacity: selected ? min : null,
        ));
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildAmenityChip(
    BuildContext context,
    String amenity,
    List<String>? currentAmenities,
  ) {
    final isSelected = currentAmenities?.contains(amenity) ?? false;
    
    return FilterChip(
      label: Text(amenity),
      selected: isSelected,
      onSelected: (selected) {
        List<String> newAmenities = List.from(currentAmenities ?? []);
        if (selected) {
          if (!newAmenities.contains(amenity)) {
            newAmenities.add(amenity);
          }
        } else {
          newAmenities.remove(amenity);
        }
        
        context.read<RoomsBloc>().add(RoomsFilterChanged(
          amenities: newAmenities.isEmpty ? null : newAmenities,
        ));
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

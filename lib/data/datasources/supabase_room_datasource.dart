import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> getRoomById(String roomId);
  Future<List<RoomModel>> getAvailableRooms({
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<bool> isRoomAvailable({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
  });
  Stream<List<RoomModel>> watchRooms();
}

class SupabaseRoomDataSource implements RoomRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseRoomDataSource({required this.supabaseClient});

  @override
  Future<List<RoomModel>> getRooms() async {
    try {
      final response =
          await supabaseClient.from('rooms').select().order('name');

      if (response == null) return <RoomModel>[];

      if (response is List) {
        return response.map((json) => RoomModel.fromJson(json)).toList();
      }

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return [RoomModel.fromJson(map)];
      }

      try {
        return (response as List)
            .map((json) => RoomModel.fromJson(json))
            .toList();
      } catch (_) {
        return <RoomModel>[];
      }
    } catch (e) {
      throw Exception('Error al obtener salas: $e');
    }
  }

  @override
  Future<RoomModel> getRoomById(String roomId) async {
    try {
      final response =
          await supabaseClient.from('rooms').select().eq('id', roomId).single();

      if (response == null) throw Exception('Sala no encontrada');

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return RoomModel.fromJson(map);
      }

      // If it's a list with one item
      if (response is List && response.isNotEmpty) {
        final map = Map<String, dynamic>.from(response.first);
        return RoomModel.fromJson(map);
      }

      throw Exception('Respuesta inesperada al obtener sala');
    } catch (e) {
      throw Exception('Error al obtener sala: $e');
    }
  }

  @override
  Future<List<RoomModel>> getAvailableRooms({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await supabaseClient.rpc('get_available_rooms', params: {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      });

      if (response == null) return <RoomModel>[];

      if (response is List) {
        return response.map((json) => RoomModel.fromJson(json)).toList();
      }

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return [RoomModel.fromJson(map)];
      }

      try {
        return (response as List)
            .map((json) => RoomModel.fromJson(json))
            .toList();
      } catch (_) {
        return <RoomModel>[];
      }
    } catch (e) {
      throw Exception('Error al obtener salas disponibles: $e');
    }
  }

  @override
  Future<bool> isRoomAvailable({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await supabaseClient.rpc('is_room_available', params: {
        'room_id': roomId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      });

      if (response == null) return false;

      if (response is bool) return response;

      // RPC sometimes returns [true] or [{'is_available': true}]
      if (response is List && response.isNotEmpty) {
        final first = response.first;
        if (first is bool) return first;
        if (first is Map && first.values.isNotEmpty) {
          final val = first.values.first;
          if (val is bool) return val;
        }
      }

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        // try common keys
        if (map.containsKey('is_available') && map['is_available'] is bool) {
          return map['is_available'] as bool;
        }
        if (map.values.first is bool) return map.values.first as bool;
      }

      return false;
    } catch (e) {
      throw Exception('Error al verificar disponibilidad: $e');
    }
  }

  @override
  Stream<List<RoomModel>> watchRooms() {
    return supabaseClient
        .from('rooms')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) {
          try {
            final iterable = data as Iterable?;
            if (iterable == null) return <RoomModel>[];
            return iterable.map((json) => RoomModel.fromJson(json)).toList();
          } catch (_) {
            return <RoomModel>[];
          }
        });
  }
}

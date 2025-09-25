import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<ReservationModel> createReservation({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
  Future<List<ReservationModel>> getUserReservations();
  Future<ReservationModel> updateReservation({
    required String reservationId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  });
  Future<void> cancelReservation(String reservationId);
  Future<List<ReservationModel>> getRoomReservations({
    required String roomId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Stream<List<ReservationModel>> watchUserReservations();
}

class SupabaseReservationDataSource implements ReservationRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseReservationDataSource({required this.supabaseClient});

  @override
  Future<ReservationModel> createReservation({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await supabaseClient
          .from('reservations')
          .insert({
            'user_id': userId,
            'room_id': roomId,
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'status': 'active',
            if (notes != null) 'notes': notes,
          })
          .select('*, users(*), rooms(*)')
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear reserva: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getUserReservations() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await supabaseClient
          .from('reservations')
          .select('*, users(*), rooms(*)')
          .eq('user_id', userId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => ReservationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener reservas: $e');
    }
  }

  @override
  Future<ReservationModel> updateReservation({
    required String reservationId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (startTime != null) {
        updateData['start_time'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        updateData['end_time'] = endTime.toIso8601String();
      }
      if (notes != null) {
        updateData['notes'] = notes;
      }
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabaseClient
          .from('reservations')
          .update(updateData)
          .eq('id', reservationId)
          .select('*, users(*), rooms(*)')
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar reserva: $e');
    }
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    try {
      await supabaseClient.from('reservations').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reservationId);
    } catch (e) {
      throw Exception('Error al cancelar reserva: $e');
    }
  }

  @override
  Future<List<ReservationModel>> getRoomReservations({
    required String roomId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = supabaseClient
          .from('reservations')
          .select('*, users(*), rooms(*)')
          .eq('room_id', roomId)
          .neq('status', 'cancelled');

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('end_time', endDate.toIso8601String());
      }

      final response = await query.order('start_time');

      // Defensive parsing: Supabase responses can be a List or Map depending
      // on the query (e.g., .single()). Ensure we handle both safely.
      if (response == null) {
        return <ReservationModel>[];
      }

      if (response is List) {
        return response.map((json) => ReservationModel.fromJson(json)).toList();
      }

      // If it's a single object, wrap it into a list
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        return [ReservationModel.fromJson(map)];
      }

      // Fallback: try to cast if possible, otherwise return empty
      try {
        return (response as List)
            .map((json) => ReservationModel.fromJson(json))
            .toList();
      } catch (_) {
        return <ReservationModel>[];
      }
    } catch (e) {
      throw Exception('Error al obtener reservas de la sala: $e');
    }
  }

  @override
  Stream<List<ReservationModel>> watchUserReservations() {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return supabaseClient
        .from('reservations')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('start_time', ascending: false)
        .map((data) =>
            data.map((json) => ReservationModel.fromJson(json)).toList());
  }
}

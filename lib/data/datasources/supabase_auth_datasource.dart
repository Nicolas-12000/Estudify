import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp(
      {required String email, required String password, String? name});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({String? name, String? avatarUrl});
  Stream<UserModel?> get authStateChanges;
}

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSource({required this.supabaseClient});

  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      final userMap = Map<String, dynamic>.from(response.user!.toJson());
      return UserModel.fromJson(userMap);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<UserModel> signUp(
      {required String email, required String password, String? name}) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('Error al registrar usuario');
      }

      final userMap = Map<String, dynamic>.from(response.user!.toJson());
      return UserModel.fromJson(userMap);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      return user != null ? UserModel.fromJson(user.toJson()) : null;
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({String? name, String? avatarUrl}) async {
    try {
      final response = await supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );

      if (response.user == null) {
        throw Exception('Error al actualizar perfil');
      }

      final userMap = Map<String, dynamic>.from(response.user!.toJson());
      return UserModel.fromJson(userMap);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      final userMap = Map<String, dynamic>.from(user.toJson());
      return UserModel.fromJson(userMap);
    });
  }
}

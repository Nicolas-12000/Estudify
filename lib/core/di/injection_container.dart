import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/datasources/supabase_room_datasource.dart';
import '../../data/datasources/supabase_reservation_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../domain/usecases/auth/sign_in.dart';
import '../../domain/usecases/auth/sign_up.dart';
import '../../domain/usecases/reservations/create_reservation.dart';
import '../../domain/usecases/rooms/get_available_rooms.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/rooms/rooms_bloc.dart';
import '../../presentation/blocs/reservations/reservations_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => AuthBloc(signIn: sl(), signUp: sl()));
  sl.registerFactory(() => RoomsBloc(getAvailableRooms: sl()));
  sl.registerFactory(() => ReservationsBloc(createReservation: sl()));

  // Use cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => CreateReservation(sl()));
  sl.registerLazySingleton(() => GetAvailableRooms(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReservationRepository>(
    () => ReservationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthDataSource(supabaseClient: sl()),
  );
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => SupabaseRoomDataSource(supabaseClient: sl()),
  );
  sl.registerLazySingleton<ReservationRemoteDataSource>(
    () => SupabaseReservationDataSource(supabaseClient: sl()),
  );

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
}

import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Register services, repositories, datasources, blocs, etc.
  // Example:
  // sl.registerLazySingleton<SomeRepository>(() => SomeRepositoryImpl());
}

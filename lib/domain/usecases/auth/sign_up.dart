import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String? name;

  const SignUpParams({
    required this.email,
    required this.password,
    this.name,
  });
}

class SignUp implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  const SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/sign_in.dart';
import '../../../domain/usecases/auth/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;

  AuthBloc({
    required this.signIn,
    required this.signUp,
  }) : super(const AuthState()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await signIn(SignInParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.toString(),
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await signUp(SignUpParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.toString(),
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    // TODO: Implement sign out
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Check current user
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}

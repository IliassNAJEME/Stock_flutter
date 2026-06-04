import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._service);

  final FirebaseAuthService _service;

  @override
  AppUser? get currentUser {
    final user = _service.currentUser;
    if (user == null || user.email == null) {
      return null;
    }

    return AppUser(id: user.uid, email: user.email!);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _service.authStateChanges().map((user) {
      if (user == null || user.email == null) {
        return null;
      }

      return AppUser(id: user.uid, email: user.email!);
    });
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final credential = await _service.register(email: email, password: password);
    final user = credential.user;
    return AppUser(id: user!.uid, email: user.email ?? email);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _service.signIn(email: email, password: password);
    final user = credential.user;
    return AppUser(id: user!.uid, email: user.email ?? email);
  }

  @override
  Future<void> signOut() => _service.signOut();
}

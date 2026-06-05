import 'package:fitness_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/models/user_model.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final user = await remoteDataSource.signInWithGoogle();

    if (user != null) {
      await localDataSource.cacheUser(user);
    }

    return user;
  }

  @override
  Future<UserEntity?> signInAsGuest() async {
    final user = await remoteDataSource.signInAsGuest();

    if (user != null) {
      await localDataSource.cacheUser(user);
    }

    return user;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final remoteUser = await remoteDataSource.getCurrentUser();

    if (remoteUser != null) {
      await localDataSource.cacheUser(remoteUser);
      return remoteUser;
    }

    return await localDataSource.getCachedUser();
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return remoteDataSource.watchAuthState();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearCache();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
    await localDataSource.clearCache();
  }

  @override
  Future<void> saveUserProfile(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);

    await remoteDataSource.saveUserProfile(userModel);

    await localDataSource.cacheUser(userModel);
  }
}

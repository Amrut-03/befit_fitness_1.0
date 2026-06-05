import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:hive/hive.dart';

abstract class ProfileLocalDatasource {
  Future<ProfileModel?> getProfile();

  Future<void> saveProfile(ProfileModel profile);
}

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  final Box box;

  ProfileLocalDatasourceImpl(this.box);

  static const key = 'profile';

  @override
  Future<ProfileModel?> getProfile() async {
    final data = box.get(key);

    if (data == null) {
      return null;
    }

    return ProfileModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await box.put(key, profile.toJson());
  }
}

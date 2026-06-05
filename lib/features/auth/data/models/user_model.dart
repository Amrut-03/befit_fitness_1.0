import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.name,
    super.email,
    super.photoUrl,
    required super.isGuest,
    super.createdAt,
  });

  /// Firebase / Firestore / JSON → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      isGuest: map['isGuest'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  /// UserModel → Firestore / JSON
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Entity → Model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      isGuest: entity.isGuest,
      createdAt: entity.createdAt,
    );
  }

  /// FirebaseAuth User → Model
  factory UserModel.fromFirebaseUser(dynamic user, {required bool isGuest}) {
    return UserModel(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      isGuest: isGuest,
      createdAt: DateTime.now(),
    );
  }

  /// Copy object with updated values
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    bool? isGuest,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

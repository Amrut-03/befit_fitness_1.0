import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final bool isGuest;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    required this.isGuest,
    this.createdAt,
  });

  @override
  List<Object?> get props => [uid, name, email, photoUrl, isGuest, createdAt];
}

import '../../auth/data/auth_dto.dart';
import '../domain/family.dart';

class FamilyDto {
  const FamilyDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.inviteCode,
  });

  factory FamilyDto.fromJson(Map<String, dynamic> json) {
    return FamilyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String name;
  final String? inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Family toDomain() {
    return Family(
      id: id,
      name: name,
      inviteCode: inviteCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class FamilyMemberDto {
  const FamilyMemberDto({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.user,
  });

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) {
    return FamilyMemberDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      role: _roleFromJson(json['role'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] is Map<String, dynamic>
          ? AuthUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String familyId;
  final String userId;
  final FamilyRole role;
  final DateTime createdAt;
  final AuthUserDto? user;

  FamilyMember toDomain() {
    return FamilyMember(
      id: id,
      familyId: familyId,
      userId: userId,
      role: role,
      createdAt: createdAt,
      user: user?.toDomain(),
    );
  }
}

class CurrentFamilyDto {
  const CurrentFamilyDto({
    required this.family,
    required this.currentMember,
  });

  factory CurrentFamilyDto.fromJson(Map<String, dynamic> json) {
    return CurrentFamilyDto(
      family: FamilyDto.fromJson(json),
      currentMember: FamilyMemberDto.fromJson(
        json['currentMember'] as Map<String, dynamic>,
      ),
    );
  }

  final FamilyDto family;
  final FamilyMemberDto currentMember;

  CurrentFamilyContext toDomain() {
    return CurrentFamilyContext(
      family: family.toDomain(),
      currentMember: currentMember.toDomain(),
    );
  }
}

class FamilyInviteDto {
  const FamilyInviteDto({
    required this.inviteCode,
    required this.inviteLink,
  });

  factory FamilyInviteDto.fromJson(Map<String, dynamic> json) {
    return FamilyInviteDto(
      inviteCode: json['inviteCode'] as String,
      inviteLink: json['inviteLink'] as String,
    );
  }

  final String inviteCode;
  final String inviteLink;

  FamilyInvite toDomain() {
    return FamilyInvite(
      inviteCode: inviteCode,
      inviteLink: inviteLink,
    );
  }
}

FamilyRole _roleFromJson(String value) {
  return switch (value) {
    'OWNER' => FamilyRole.owner,
    'ADULT' => FamilyRole.adult,
    'CHILD' => FamilyRole.child,
    _ => FamilyRole.child,
  };
}

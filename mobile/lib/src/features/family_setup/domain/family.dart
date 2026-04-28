import '../../auth/domain/auth_user.dart';

enum FamilyRole {
  owner,
  adult,
  child,
}

extension FamilyRoleX on FamilyRole {
  bool get isCreator => this == FamilyRole.owner;
  bool get isAdult => this == FamilyRole.owner || this == FamilyRole.adult;

  String get apiValue {
    return switch (this) {
      FamilyRole.owner => 'OWNER',
      FamilyRole.adult => 'ADULT',
      FamilyRole.child => 'CHILD',
    };
  }
}

class Family {
  const Family({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.inviteCode,
  });

  final String id;
  final String name;
  final String? inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.user,
  });

  final String id;
  final String familyId;
  final String userId;
  final FamilyRole role;
  final DateTime createdAt;
  final AuthUser? user;

  String get displayName => user?.name ?? userId;
}

class CurrentFamilyContext {
  const CurrentFamilyContext({
    required this.family,
    required this.currentMember,
  });

  final Family family;
  final FamilyMember currentMember;
}

class FamilyInvite {
  const FamilyInvite({
    required this.inviteCode,
    required this.inviteLink,
  });

  final String inviteCode;
  final String inviteLink;
}

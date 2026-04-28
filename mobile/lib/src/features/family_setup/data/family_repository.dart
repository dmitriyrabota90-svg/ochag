import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../../../core/network/api_client.dart';
import '../domain/family.dart';
import 'family_dto.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(ref.watch(apiClientProvider));
});

class FamilyRepository {
  const FamilyRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CurrentFamilyContext> createFamily(String name) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/families',
      data: {'name': name.trim()},
    );
    return CurrentFamilyDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<CurrentFamilyContext> getCurrentFamily() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/families/current',
    );
    return CurrentFamilyDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<CurrentFamilyContext> joinFamily(String inviteCode) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/families/join',
      data: {'inviteCode': inviteCode.trim()},
    );
    return CurrentFamilyDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<List<FamilyMember>> getCurrentFamilyMembers() async {
    final response = await _apiClient.get<List<dynamic>>(
      '/families/current/members',
    );
    final data = response.data ?? const [];
    return data
        .cast<Map<String, dynamic>>()
        .map((json) => FamilyMemberDto.fromJson(json).toDomain())
        .toList();
  }

  Future<Family> updateFamilyName(String name) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/families/current',
      data: {'name': name.trim()},
    );
    return FamilyDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<void> leaveFamily() async {
    await _apiClient.post<Map<String, dynamic>>('/families/current/leave');
  }

  Future<FamilyMember> changeMemberRole({
    required String memberId,
    required FamilyRole role,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/families/current/members/$memberId/role',
      data: {'role': role.apiValue},
    );
    return FamilyMemberDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<void> removeMember(String memberId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/families/current/members/$memberId',
    );
  }

  Future<FamilyMember> transferCreator(String memberId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/families/current/transfer-creator',
      data: {'memberId': memberId},
    );
    return FamilyMemberDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<FamilyInvite> createInviteLink() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/families/current/invites/link',
    );
    return FamilyInviteDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<FamilyInvite> regenerateInviteCode() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/families/current/invites/code/regenerate',
    );
    return FamilyInviteDto.fromJson(_requireMap(response.data)).toDomain();
  }

  Future<void> requestFamilyDelete() async {
    await _apiClient.post<Map<String, dynamic>>(
      '/families/current/delete-request',
    );
  }

  Map<String, dynamic> _requireMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Empty server response');
    }
    return data;
  }
}

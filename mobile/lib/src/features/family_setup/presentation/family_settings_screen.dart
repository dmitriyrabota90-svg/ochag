import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ochag_mobile/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/app_base_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/family_controller.dart';
import '../domain/family.dart';

class FamilySettingsScreen extends ConsumerStatefulWidget {
  const FamilySettingsScreen({super.key});

  static const routePath = '/family-settings';
  static const routeName = 'familySettings';

  @override
  ConsumerState<FamilySettingsScreen> createState() =>
      _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends ConsumerState<FamilySettingsScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final familyAsync = ref.watch(familyControllerProvider);

    ref.listen(familyControllerProvider, (previous, next) {
      final state = next.valueOrNull;
      final message = state?.errorMessage ?? _successText(l10n, state);
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return AppScaffold(
      title: l10n.familySettingsTitle,
      body: familyAsync.when(
        loading: () => const AppLoadingState(),
        error: (error, stackTrace) => AppErrorState(
          message: l10n.genericErrorMessage,
          onRetry: () => ref.read(familyControllerProvider.notifier).reload(),
        ),
        data: (state) {
          final family = state.family;
          if (family == null) {
            return Center(child: Text(l10n.noFamilyMessage));
          }
          if (_nameController.text.isEmpty) {
            _nameController.text = family.name;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FamilyInfoCard(
                familyName: family.name,
                inviteCode: state.invite?.inviteCode ?? family.inviteCode,
              ),
              const SizedBox(height: 16),
              if (state.canManageFamily)
                _RenameFamilyCard(
                  formKey: _nameFormKey,
                  controller: _nameController,
                  isSubmitting: state.isSubmitting,
                  onSubmit: _updateFamilyName,
                ),
              if (state.canManageFamily) const SizedBox(height: 16),
              if (state.canManageInvites)
                _InviteCard(
                  invite: state.invite,
                  existingInviteCode: family.inviteCode,
                  isSubmitting: state.isSubmitting,
                  onCreate: () => ref
                      .read(familyControllerProvider.notifier)
                      .createInviteLink(),
                  onRegenerate: _confirmRegenerateInvite,
                ),
              if (state.canManageInvites) const SizedBox(height: 16),
              _MembersCard(
                state: state,
                onRoleChanged: (member, role) {
                  ref.read(familyControllerProvider.notifier).changeMemberRole(
                        memberId: member.id,
                        role: role,
                      );
                },
                onRemove: _confirmRemoveMember,
                onTransferCreator: _confirmTransferCreator,
              ),
              const SizedBox(height: 16),
              _DangerZoneCard(
                canRequestDelete: state.canManageFamily,
                isSubmitting: state.isSubmitting,
                onLeave: _confirmLeaveFamily,
                onRequestDelete: _confirmDeleteRequest,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateFamilyName() async {
    if (!_nameFormKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(familyControllerProvider.notifier)
        .updateFamilyName(_nameController.text);
  }

  Future<void> _confirmLeaveFamily() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.leaveFamilyAction,
      body: l10n.leaveFamilyConfirmMessage,
    );
    if (confirmed) {
      await ref.read(familyControllerProvider.notifier).leaveFamily();
    }
  }

  Future<void> _confirmRemoveMember(FamilyMember member) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.removeMemberAction,
      body: l10n.removeMemberConfirmMessage,
    );
    if (confirmed) {
      await ref.read(familyControllerProvider.notifier).removeMember(member.id);
    }
  }

  Future<void> _confirmTransferCreator(FamilyMember member) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.transferCreatorAction,
      body: l10n.transferCreatorConfirmMessage,
    );
    if (confirmed) {
      await ref
          .read(familyControllerProvider.notifier)
          .transferCreator(member.id);
    }
  }

  Future<void> _confirmRegenerateInvite() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.regenerateInviteCodeAction,
      body: l10n.regenerateInviteConfirmMessage,
    );
    if (confirmed) {
      await ref.read(familyControllerProvider.notifier).regenerateInviteCode();
    }
  }

  Future<void> _confirmDeleteRequest() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.requestFamilyDeleteAction,
      body: l10n.requestFamilyDeleteConfirmMessage,
    );
    if (confirmed) {
      await ref.read(familyControllerProvider.notifier).requestFamilyDelete();
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
  }) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancelAction),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.confirmAction),
              ),
            ],
          ),
        ) ??
        false;
  }

  String? _successText(AppLocalizations l10n, FamilyState? state) {
    return switch (state?.successMessage) {
      'family_created' => l10n.familyCreatedMessage,
      'family_joined' => l10n.familyJoinedMessage,
      'family_updated' => l10n.familyUpdatedMessage,
      'family_left' => l10n.familyLeftMessage,
      'member_role_updated' => l10n.memberRoleUpdatedMessage,
      'member_removed' => l10n.memberRemovedMessage,
      'creator_transferred' => l10n.creatorTransferredMessage,
      'invite_created' => l10n.inviteCreatedMessage,
      'invite_regenerated' => l10n.inviteRegeneratedMessage,
      'family_delete_requested' => l10n.familyDeleteRequestedMessage,
      _ => null,
    };
  }
}

class _FamilyInfoCard extends StatelessWidget {
  const _FamilyInfoCard({
    required this.familyName,
    required this.inviteCode,
  });

  final String familyName;
  final String? inviteCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(familyName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            inviteCode == null
                ? l10n.inviteCodeNotCreatedMessage
                : '${l10n.inviteCodeLabel}: $inviteCode',
          ),
        ],
      ),
    );
  }
}

class _RenameFamilyCard extends StatelessWidget {
  const _RenameFamilyCard({
    required this.formKey,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.updateFamilyNameTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(labelText: l10n.familyNameLabel),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty || trimmed.length > 80) {
                  return l10n.familyNameValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.saveAction,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.existingInviteCode,
    required this.isSubmitting,
    required this.onCreate,
    required this.onRegenerate,
  });

  final FamilyInvite? invite;
  final String? existingInviteCode;
  final bool isSubmitting;
  final VoidCallback onCreate;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inviteCode = invite?.inviteCode ?? existingInviteCode;

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.familyInviteTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(inviteCode ?? l10n.inviteCodeNotCreatedMessage),
          if (invite?.inviteLink != null) ...[
            const SizedBox(height: 8),
            SelectableText(invite!.inviteLink),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: invite!.inviteLink),
                ),
                icon: const Icon(Icons.copy),
                label: Text(l10n.copyInviteLinkAction),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: isSubmitting ? null : onCreate,
                child: Text(l10n.createInviteLinkAction),
              ),
              OutlinedButton(
                onPressed: isSubmitting ? null : onRegenerate,
                child: Text(l10n.regenerateInviteCodeAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.state,
    required this.onRoleChanged,
    required this.onRemove,
    required this.onTransferCreator,
  });

  final FamilyState state;
  final void Function(FamilyMember member, FamilyRole role) onRoleChanged;
  final void Function(FamilyMember member) onRemove;
  final void Function(FamilyMember member) onTransferCreator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentMemberId = state.currentMember?.id;

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.familyMembersTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final member in state.members)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(member.displayName),
              subtitle: Text(_roleLabel(l10n, member.role)),
              trailing: state.canManageFamily && member.id != currentMemberId
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'adult':
                            onRoleChanged(member, FamilyRole.adult);
                          case 'child':
                            onRoleChanged(member, FamilyRole.child);
                          case 'remove':
                            onRemove(member);
                          case 'transfer':
                            onTransferCreator(member);
                        }
                      },
                      itemBuilder: (context) => [
                        if (member.role != FamilyRole.owner) ...[
                          PopupMenuItem(
                            value: 'adult',
                            child: Text(l10n.makeAdultAction),
                          ),
                          PopupMenuItem(
                            value: 'child',
                            child: Text(l10n.makeChildAction),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text(l10n.removeMemberAction),
                          ),
                        ],
                        if (member.role == FamilyRole.adult)
                          PopupMenuItem(
                            value: 'transfer',
                            child: Text(l10n.transferCreatorAction),
                          ),
                      ],
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  String _roleLabel(AppLocalizations l10n, FamilyRole role) {
    return switch (role) {
      FamilyRole.owner => l10n.familyRoleOwner,
      FamilyRole.adult => l10n.familyRoleAdult,
      FamilyRole.child => l10n.familyRoleChild,
    };
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({
    required this.canRequestDelete,
    required this.isSubmitting,
    required this.onLeave,
    required this.onRequestDelete,
  });

  final bool canRequestDelete;
  final bool isSubmitting;
  final VoidCallback onLeave;
  final VoidCallback onRequestDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.familyDangerZoneTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: isSubmitting ? null : onLeave,
            child: Text(l10n.leaveFamilyAction),
          ),
          if (canRequestDelete) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: isSubmitting ? null : onRequestDelete,
              child: Text(l10n.requestFamilyDeleteAction),
            ),
          ],
        ],
      ),
    );
  }
}

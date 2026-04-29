# Manual QA

## 1. Auth

- [ ] Open app without saved session.
- [ ] Register a new adult account.
- [ ] Log out.
- [ ] Log in with the same account.
- [ ] Try invalid email/password and check error copy.
- [ ] Trigger forgot password flow.
- [ ] Use backend log reset link and set a new password.
- [ ] Confirm old password no longer works.
- [ ] Confirm app restores session after restart.

## 2. Family

- [ ] Create a new family.
- [ ] Check current family name on Home/Profile.
- [ ] Generate invite code/link.
- [ ] Register second account and join by invite.
- [ ] Confirm joined member appears in family settings.
- [ ] Change member role where allowed.
- [ ] Try owner transfer to an adult member.
- [ ] Try removing a member.
- [ ] Try leaving family.
- [ ] Trigger family delete request and check backend log confirmation link.

## 3. Tasks

- [ ] Create a task as adult/owner.
- [ ] Assign task to a child.
- [ ] Add reward/experience values.
- [ ] Open task details.
- [ ] Submit task as assignee.
- [ ] Approve submitted task as adult/owner.
- [ ] Confirm task becomes completed.
- [ ] Confirm history/rating update after approval.
- [ ] Create another task and reject submission.
- [ ] Confirm rejected task returns to active state.
- [ ] Add a task comment.
- [ ] Create and use a task template if available.
- [ ] Check recurring task behavior after approval.

## 4. Initiatives

- [ ] Create initiative as child.
- [ ] Open initiative details.
- [ ] Confirm discussion state is visible.
- [ ] Wait or simulate discussion lock expiration.
- [ ] Confirm waiting decision state appears.
- [ ] Approve initiative as adult/owner.
- [ ] Create another initiative and approve without reward.
- [ ] Create another initiative and reject.
- [ ] Confirm submitter cannot decide their own initiative.
- [ ] Confirm history/rating updates where expected.

## 5. Rewards

- [ ] Create/propose reward.
- [ ] Approve reward as adult/owner.
- [ ] Reprice reward before approval if available.
- [ ] Reject another reward.
- [ ] Request approved reward as child.
- [ ] Open reward request details.
- [ ] Mark reward fulfilled as provider.
- [ ] Confirm reward received as requester.
- [ ] Request cancellation.
- [ ] Respond to cancellation as the other side.
- [ ] Check spark balance behavior for paid rewards.
- [ ] Check free-level reward behavior if available.

## 6. Family Goal

- [ ] Create family goal as adult/owner.
- [ ] Confirm active goal appears on Home.
- [ ] Contribute sparks as a member.
- [ ] Confirm progress increases.
- [ ] Confirm contribution appears in history.
- [ ] Reach target amount.
- [ ] Confirm goal switches to completion/confirmation state.
- [ ] Confirm completion as each required member.
- [ ] Check completed state after final confirmation.
- [ ] Edit active goal where allowed.

## 7. History

- [ ] Open History from app navigation.
- [ ] Confirm latest task event appears.
- [ ] Confirm latest initiative event appears.
- [ ] Confirm latest reward event appears.
- [ ] Confirm latest goal contribution appears.
- [ ] Check date/time formatting.
- [ ] Use filters if available.
- [ ] Load more events if pagination is available.
- [ ] Check empty state on a new family.

## 8. Rating

- [ ] Open Rating.
- [ ] Confirm all current family members are listed.
- [ ] Confirm levels/XP/sparks are visible.
- [ ] Complete a task and approve it.
- [ ] Reopen Rating and confirm progress changed.
- [ ] Check sorting/order is understandable.
- [ ] Check empty/new-family state.

## 9. Notifications

- [ ] Open Notifications.
- [ ] Confirm list loads without 404.
- [ ] Confirm unread notifications are visually distinct.
- [ ] Tap mark as read.
- [ ] Confirm item switches to read state.
- [ ] Repeat mark as read on same item and confirm no error.
- [ ] Trigger a task/reward/goal event that creates notification.
- [ ] Reload and confirm notification appears.
- [ ] Use load more if pagination is available.
- [ ] Check empty state on a user with no notifications.

## 10. Home

- [ ] Open Home after login with family.
- [ ] Confirm family name is shown.
- [ ] Confirm progress/level summary is shown when data exists.
- [ ] Confirm active tasks preview is shown.
- [ ] Tap Tasks CTA.
- [ ] Confirm waiting actions block appears when reviews/decisions exist.
- [ ] Confirm family goal preview is shown.
- [ ] Tap Goal CTA.
- [ ] Confirm recent history preview is shown.
- [ ] Check quick actions for current role.
- [ ] Confirm Home handles empty new-family state.

## 11. Role-based checks

### Child

- [ ] Can see assigned tasks.
- [ ] Can submit own tasks.
- [ ] Cannot approve/reject task reviews unless explicitly allowed by flow.
- [ ] Can create initiatives.
- [ ] Cannot decide own initiatives.
- [ ] Can request approved rewards.
- [ ] Cannot approve/reprice/reject rewards.
- [ ] Can contribute to active family goal if balance allows.
- [ ] Cannot access owner-only family settings actions.

### Adult

- [ ] Can create tasks.
- [ ] Can approve/reject submitted tasks where allowed.
- [ ] Can decide initiatives where allowed.
- [ ] Can approve/reprice/reject rewards.
- [ ] Can fulfill provided reward requests.
- [ ] Can create/update family goal where allowed.
- [ ] Cannot transfer ownership unless current flow allows it.
- [ ] Cannot perform owner-only delete/transfer actions if restricted.

### Owner

- [ ] Can access family settings.
- [ ] Can change member roles.
- [ ] Can remove members where allowed.
- [ ] Can transfer ownership to adult.
- [ ] Can request family deletion.
- [ ] Can create/manage tasks, rewards, initiatives, and goal.
- [ ] Cannot leave/delete in invalid family states.

## 12. Error/empty states

- [ ] Start app with backend stopped.
- [ ] Confirm key screens show error state, not blank UI.
- [ ] Tap retry after backend is restored.
- [ ] Check Auth invalid credentials error.
- [ ] Check create forms with missing required fields.
- [ ] Check empty Tasks state.
- [ ] Check empty Initiatives state.
- [ ] Check empty Rewards state.
- [ ] Check empty Family Goal state.
- [ ] Check empty History state.
- [ ] Check empty Notifications state.
- [ ] Check loading indicators during slow requests.
- [ ] Check irreversible actions show confirmation dialogs.

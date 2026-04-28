# Ochag MVP Assumptions

## Family

- A user has at most one active family.
  - Backend blocks creating or joining another family when any membership exists.
  - Current family is resolved from the user's first membership.
- `FamilyRole.OWNER` is the creator/owner role.
  - Mobile labels it as creator.
  - Backend creator-only checks require `OWNER`.
- `OWNER` and `ADULT` are adult roles.
  - Adult permissions include invites, task creation, reward template management, goal management, and review flows.
- Joining by invite creates the new member as `CHILD`.
- Creator cannot be removed.
- Creator must transfer creator role before leaving unless the family is being deleted.
- Creator transfer is only allowed to an `ADULT`.
- The only adult cannot leave while children remain in the family.
- Invite links are built from `APP_BASE_URL` and `?code=...`.

## Auth And Mail

- Auth uses access and refresh tokens.
- Mobile stores tokens in `flutter_secure_storage`.
- API client retries authenticated requests once after access-token refresh on `401`.
- Password reset email is an MVP log-based flow.
  - Backend logs the reset URL instead of sending real email.
- Family delete confirmation is an MVP log-based flow.
  - Backend logs the confirm URL instead of sending real email.

## Tasks

- Adults/owners can create tasks.
- Task submit is allowed only for the assignee while task is active.
- Task review requires `PENDING_CONFIRMATION`.
- Reviewer cannot be the assignee.
- Adult creator can review own created task when reviewing another member's submission.
- Child review is allowed only in the special case where there is exactly one adult and the assignee is an adult.
- Approving a task grants sparks and experience to the assignee member.
- Rejecting a task returns it to active status.
- Recurring tasks are created after approval, based on existing recurrence settings.
- Deleted/cancelled/skipped/confirmed tasks are treated as history in mobile.

## Initiatives

- New initiatives enter `DISCUSSION`.
- Discussion lock is currently 15 minutes.
- `waitingDecision` is derived state, not a separate backend status.
  - Mobile derives it when status is `DISCUSSION` and `discussionLockedUntil` is null or in the past.
  - Backend allows approve/reject only after the discussion lock expires.
- Initiative submitter cannot review their own initiative.
- Adults can review initiatives.
- Child review follows the same special-case pattern as tasks: exactly one adult and the submitter is an adult.
- Approved initiatives may grant final sparks; approved-without-reward grants no reward.

## Rewards

- Rewards can be proposed by any family member.
- Reward approval/reprice/reject requires adult permissions.
- Reward requests can be created only for active approved rewards.
- Reward provider is the family member whose user approved the reward (`approvedById`).
- Reward requester is the current member creating the request.
- Provider marks reward as fulfilled.
- Requester confirms reward received.
- Either requester or provider can request cancellation.
- The other participant must respond to a cancellation request.
- Spark rewards charge sparks immediately when the request is created.
- Level-free rewards store `levelSnapshot` and do not charge sparks.
- Level-free availability is checked against current level and previous non-cancelled requests for the same reward.
- There is no backend list endpoint for reward requests in the current MVP.
  - Mobile `RewardsState.requests` is populated only from create/get/action flows.
  - Home can show reward request actions only for requests already loaded into mobile state.

## Family Goal

- There is one current family goal surface in mobile.
- Goal create/update requires adult permissions.
- Contributions are allowed only while the goal is active.
- Contributions spend member sparks immediately.
- Contribution experience is `floor(sparks * 1.5)`.
- When current sparks reach target sparks, goal moves to `AWAITING_EXECUTION`.
- Completion confirmation is per family member.
- Mobile shows a confirmation action only if the current member has not confirmed yet.

## History

- History is family-scoped.
- History supports cursor/page pagination plus optional `entityType` and `eventType` filters.
- Mobile uses history as an audit preview on Home and full list under Profile.

## Notifications

- Notifications are family-scoped and user-scoped.
- Notification payload is stored in the domain model but not rendered in cards.
- Notification read is idempotent.
  - Backend returns the existing notification if `readAt` already exists.
  - Mobile avoids duplicate read calls for already-read or in-flight items.
- Notification list uses `limit` plus cursor/page pagination.

## Rating And Home

- Rating/analytics periods are `day`, `week`, `month`, `all_time`.
- Home uses existing feature controllers as an aggregator.
- Home does not call a dedicated backend endpoint.
- Home summary is limited by currently available mobile models.
  - There is no direct mobile member balance/progress endpoint.
  - Home uses rating/analytics data for level, XP, sparks, and completed task summary.
  - Home level-free reward count is best-effort from loaded rewards and loaded reward requests.
- Home previews are capped:
  - My active tasks: 3
  - Waiting actions: 5
  - Latest history events: 3

## Mobile Runtime

- Mobile default API base URL is `http://10.0.2.2:3000/v1`.
- API base URL can be overridden with `--dart-define=API_BASE_URL=...`.
- Mobile uses generated l10n files from `lib/l10n/generated`.
- Flutter app assumes authenticated users without a family must go through Family Setup.
- Main app navigation is guarded by auth state and family state.

## Backend Runtime

- Backend API prefix is `/v1`.
- Backend uses PostgreSQL through Prisma.
- Local Docker setup uses the development Postgres credentials in `docker-compose.yml`.
- `.env.example` contains local placeholders only; real `.env` is not committed.

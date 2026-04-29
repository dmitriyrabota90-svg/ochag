# Test Users And Scenarios

## Test Users

| User | Role | Purpose |
| --- | --- | --- |
| `owner@example.test` | owner | Family creation, settings, role changes, final approvals. |
| `adult@example.test` | adult | Reviews, decisions, reward approval/fulfillment, shared parent flow. |
| `child@example.test` | child | Assigned tasks, initiatives, reward requests, goal contributions. |

Use simple local passwords and do not reuse real credentials.

## Role Setup

1. Register `owner@example.test`.
2. Create a family as owner.
3. Generate invite code/link.
4. Register `child@example.test`.
5. Join family with invite; default role should be child.
6. Register `adult@example.test`.
7. Join family with invite.
8. Change `adult@example.test` role from child to adult as owner.
9. Confirm all three members appear in family settings with correct roles.

## Owner Scenarios

- Create family.
- Generate/regenerate invite code.
- Change member role.
- Transfer ownership to adult.
- Remove member where allowed.
- Request family deletion.
- Create task for child.
- Review submitted task.
- Decide initiative.
- Approve/reprice/reject reward.
- Create/update family goal.
- Check Home waiting actions.
- Check History, Rating, Notifications.

## Adult Scenarios

- Create task for child.
- Review task submitted by child.
- Decide child initiative.
- Approve/reprice/reject reward.
- Fulfill reward request where adult is provider.
- Contribute to family goal.
- Confirm goal completion.
- Check role-limited family settings.
- Check Home quick actions.
- Check Notifications for review/decision events.

## Child Scenarios

- View assigned tasks.
- Submit task for review.
- Create initiative.
- Request approved reward.
- Confirm received reward.
- Request reward cancellation.
- Contribute to active family goal.
- Confirm goal completion.
- Check Rating progress.
- Check own Notifications.
- Confirm adult/owner actions are hidden or blocked.

## Can Test With One User

- Register/login/logout.
- Create family.
- Basic profile screen.
- Empty Home state.
- Empty Tasks/Initiatives/Rewards/History/Notifications states.
- Create family goal if owner permissions are enough.
- Basic API health check.

## Requires Two Users

- Invite and join family.
- Assign task to another member.
- Submit task as assignee and review as adult/owner.
- Child initiative reviewed by adult/owner.
- Reward request and fulfillment by provider.
- Role-aware UI checks for child vs owner/adult.
- Notifications between two members.
- Owner transfer to adult if second user is adult.

## Best With Three Users

- Full owner/adult/child permission matrix.
- Owner creates task, child submits, adult reviews.
- Child creates initiative, adult decides, owner verifies history.
- Adult approves reward, child requests it, owner checks family state.
- Family goal contributions by multiple members.
- Rating order with meaningful differences.
- Notifications across different recipient roles.
- Family settings with role change and member removal checks.

## Mobile App Testing

- Use Android emulator for the main user flow.
- Log out and switch accounts between owner/adult/child.
- For faster role checks, keep backend running and reuse the same family.
- Use Home as smoke test after every major action.
- Use Notifications and History to verify side effects.

## API Client Testing

Use Postman, Bruno, or curl for setup and edge cases.

Helpful API checks:

- `GET /v1/health`
- Auth register/login/logout.
- Current user: `GET /v1/me`
- Current family: `GET /v1/families/current`
- Family members: `GET /v1/families/current/members`
- Notifications: `GET /v1/notifications`
- Mark notification read: `POST /v1/notifications/:notificationId/read`

Use API client when:

- You need to create test data faster than the UI.
- You need to verify backend response shape.
- You need to reproduce permission errors.
- You need to compare mobile behavior against raw API output.

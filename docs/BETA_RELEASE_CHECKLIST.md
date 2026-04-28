# Beta Release Checklist

## 1. Backend readiness

- [ ] Copy `backend/.env.example` to `backend/.env` for the beta environment.
- [ ] Set a real `DATABASE_URL` for the beta database.
- [ ] Replace `AUTH_ACCESS_TOKEN_SECRET` with a non-placeholder secret.
- [ ] Run backend dependency install.
- [ ] Run Prisma client generation.
- [ ] Apply Prisma migrations to the beta database.
- [ ] Run backend build and available backend tests.
- [ ] Verify `/v1/health` responds from the beta backend.
- [ ] Verify mobile API base URL points to the same backend `/v1` prefix.
- [ ] Confirm password reset and family delete confirmation log links are acceptable for MVP beta.
- [ ] Confirm real `.env` files are not committed or included in beta artifacts.

## 2. Mobile readiness

- [ ] Run `flutter pub get`.
- [ ] Run `flutter gen-l10n`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run the app with the intended API URL: `--dart-define=API_BASE_URL=...`.
- [ ] Verify generated localization files are current for English and Russian.
- [ ] Verify unauthenticated users land in auth flow.
- [ ] Verify authenticated users without a family land in family setup.
- [ ] Verify authenticated users with a family land on Home.
- [ ] Verify logout clears secure tokens and returns to auth.
- [ ] Verify token refresh retry works after access token expiration.

## 3. Android build readiness

- [ ] Install Android SDK Command-line Tools in Android Studio SDK Manager.
- [ ] Run `flutter doctor --android-licenses` after `sdkmanager` is available.
- [ ] Accept all Android SDK licenses.
- [ ] Create an Android emulator in Android Studio Device Manager or connect a physical Android device.
- [ ] Run `flutter devices` and confirm an Android target is visible.
- [ ] Run `flutter doctor` and confirm Android toolchain has no blocking issues.
- [ ] Build a release APK or app bundle with the beta API URL.
- [ ] Install the release build on an Android device and complete first-run auth/family flows.

## 4. Manual QA

- [ ] Register, log in, log out, and reopen the app with an existing session.
- [ ] Trigger password reset and verify the backend log URL flow.
- [ ] Create a family, generate invite code, and join as a child account.
- [ ] Verify owner, adult, and child role-aware actions.
- [ ] Verify family member role changes and owner transfer rules.
- [ ] Verify family delete confirmation through backend log URL.
- [ ] Create, submit, approve, reject, and delete tasks.
- [ ] Verify recurring task creation after approval.
- [ ] Create initiatives, wait for discussion lock, and resolve waiting decisions.
- [ ] Propose, approve, reprice, reject, request, fulfill, confirm, and cancel rewards.
- [ ] Create/update family goal, contribute sparks, reach target, and confirm completion.
- [ ] Open History and verify recent events and pagination.
- [ ] Open Rating and verify member progress data.
- [ ] Open Notifications, load more, mark unread items as read, and repeat mark-read action.
- [ ] Open Home and verify real previews for tasks, waiting actions, goal, history, and quick actions.
- [ ] Turn backend off and verify loading/error/retry states on key screens.

## 5. Store assets

- [ ] Replace default Flutter launcher icon if beta build is distributed outside local development.
- [ ] Prepare app display name `Очаг` / `Ochag` consistently.
- [ ] Capture Android screenshots from a real beta build.
- [ ] Prepare short tester notes that mention MVP log-based email flows.
- [ ] Prepare release notes listing current MVP flows: family, tasks, initiatives, rewards, goal, history, rating, notifications, home.

## 6. Privacy / legal / metadata

- [ ] Document stored account, family, task, initiative, reward, goal, history, rating, and notification data.
- [ ] Document that reset/delete confirmation links are logged by the MVP backend.
- [ ] Confirm no production secrets are present in git or release artifacts.
- [ ] Define beta support/contact channel for feedback entry.
- [ ] Prepare privacy policy URL before Play Console distribution.
- [ ] Confirm beta backend/database retention expectations before inviting testers.

## 7. Known beta limitations

- [ ] One active family per user is assumed.
- [ ] Family creator is mapped to owner.
- [ ] Joining by invite creates a child member by default.
- [ ] Reward provider is the member whose user approved the reward.
- [ ] Initiative `waiting_decision` is derived by mobile from discussion lock timing.
- [ ] Reward requests do not have a dedicated backend list endpoint in MVP.
- [ ] Home summary is assembled from existing feature data, not a dedicated backend summary endpoint.
- [ ] Home balance/progress can be incomplete where no direct member balance endpoint exists.
- [ ] Password reset and family delete confirmation are mail/log-based MVP flows.
- [ ] Android command-line tools, licenses, and emulator/device must be completed before Android beta build.
- [ ] Feedback entry point is app-level beta UX, not a full backend feedback system.

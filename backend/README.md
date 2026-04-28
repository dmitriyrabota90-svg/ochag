# Ochag Backend

Backend foundation for the Ochag project.

## Stack

- NestJS
- PostgreSQL
- Prisma
- Modular monolith
- Docker for local backend + database startup

## Local Setup

```bash
cp .env.example .env
npm install
npm run prisma:generate
npm run build
```

For local development without Docker, set `DATABASE_URL` in `.env` to a reachable PostgreSQL instance.

## Docker

```bash
docker compose up --build
```

The API listens on:

```text
http://localhost:3000/v1/health
```

## Auth Endpoints

- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/refresh`
- `POST /v1/auth/logout`
- `POST /v1/auth/forgot-password`
- `POST /v1/auth/reset-password`
- `GET /v1/me`

## Family Endpoints

- `POST /v1/families`
- `GET /v1/families/current`
- `POST /v1/families/join`
- `GET /v1/families/current/members`
- `PATCH /v1/families/current`
- `POST /v1/families/current/leave`
- `PATCH /v1/families/current/members/:memberId/role`
- `DELETE /v1/families/current/members/:memberId`
- `POST /v1/families/current/transfer-creator`
- `POST /v1/families/current/invites/link`
- `POST /v1/families/current/invites/code/regenerate`
- `POST /v1/families/current/delete-request`
- `POST /v1/families/current/delete-confirm`

## Task Endpoints

- `GET /v1/tasks`
- `GET /v1/tasks/:taskId`
- `POST /v1/tasks`
- `PATCH /v1/tasks/:taskId`
- `DELETE /v1/tasks/:taskId`
- `POST /v1/tasks/:taskId/submit`
- `POST /v1/tasks/:taskId/approve`
- `POST /v1/tasks/:taskId/reject`
- `POST /v1/tasks/:taskId/comments`
- `GET /v1/task-templates`
- `POST /v1/task-templates`
- `PATCH /v1/task-templates/:templateId`

## Initiative Endpoints

- `GET /v1/initiatives`
- `GET /v1/initiatives/:initiativeId`
- `POST /v1/initiatives`
- `POST /v1/initiatives/:initiativeId/approve`
- `POST /v1/initiatives/:initiativeId/approve-without-reward`
- `POST /v1/initiatives/:initiativeId/reject`

## Reward Endpoints

- `GET /v1/rewards`
- `GET /v1/rewards/:rewardId`
- `POST /v1/rewards`
- `POST /v1/rewards/:rewardId/approve`
- `POST /v1/rewards/:rewardId/reprice`
- `POST /v1/rewards/:rewardId/reject`
- `GET /v1/reward-templates`
- `POST /v1/reward-templates`
- `PATCH /v1/reward-templates/:templateId`
- `POST /v1/reward-requests`
- `GET /v1/reward-requests/:requestId`
- `POST /v1/reward-requests/:requestId/mark-fulfilled`
- `POST /v1/reward-requests/:requestId/confirm-received`
- `POST /v1/reward-requests/:requestId/cancel`
- `POST /v1/reward-requests/:requestId/cancel/respond`

## Family Goal Endpoints

- `GET /v1/family-goal`
- `POST /v1/family-goal`
- `PATCH /v1/family-goal/:goalId`
- `POST /v1/family-goal/:goalId/contributions`
- `POST /v1/family-goal/:goalId/confirm-completion`

## History Endpoints

- `GET /v1/history`

Basic query params:

- `cursor`
- `page`
- `limit`
- `eventType`
- `entityType`

## Notification Endpoints

- `GET /v1/notifications`
- `POST /v1/notifications/:notificationId/read`

## Rating / Analytics Endpoints

- `GET /v1/rating?period=day|week|month|all_time`
- `GET /v1/analytics/summary?period=day|week|month|all_time`

The local PostgreSQL connection string from the backend container is:

```text
postgresql://ochag:ochag@postgres:5432/ochag?schema=public
```

From the host machine, use:

```text
postgresql://ochag:ochag@localhost:5432/ochag?schema=public
```

## Prisma Commands

```bash
npm run prisma:generate
npm run prisma:migrate
npm run prisma:studio
```

## Modules

The backend currently contains runnable foundation plus implemented MVP modules:

- `auth`
- `family`
- `tasks`
- `initiatives`
- `rewards`
- `family-goal`
- `history`
- `analytics`
- `notifications`

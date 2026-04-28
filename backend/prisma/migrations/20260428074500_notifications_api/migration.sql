ALTER TABLE "Notification"
ADD COLUMN "type" TEXT NOT NULL DEFAULT 'notification',
ADD COLUMN "payload" JSONB;

ALTER TABLE "Notification"
ALTER COLUMN "type" DROP DEFAULT;

CREATE INDEX "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");

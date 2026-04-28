-- AlterEnum
ALTER TYPE "InitiativeStatus" ADD VALUE IF NOT EXISTS 'DISCUSSION';
ALTER TYPE "InitiativeStatus" ADD VALUE IF NOT EXISTS 'APPROVED';
ALTER TYPE "InitiativeStatus" ADD VALUE IF NOT EXISTS 'APPROVED_WITHOUT_REWARD';
ALTER TYPE "InitiativeStatus" ADD VALUE IF NOT EXISTS 'REJECTED';

-- AlterTable
ALTER TABLE "Initiative" ADD COLUMN IF NOT EXISTS "discussionLockedUntil" TIMESTAMP(3);
ALTER TABLE "Initiative" ADD COLUMN IF NOT EXISTS "finalSparks" INTEGER;
ALTER TABLE "Initiative" ADD COLUMN IF NOT EXISTS "decidedById" TEXT;
ALTER TABLE "Initiative" ADD COLUMN IF NOT EXISTS "decidedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "SparkLedger" ADD COLUMN IF NOT EXISTS "initiativeId" TEXT;
ALTER TABLE "ExperienceLedger" ADD COLUMN IF NOT EXISTS "initiativeId" TEXT;

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Initiative_createdById_idx" ON "Initiative"("createdById");
CREATE INDEX IF NOT EXISTS "Initiative_decidedById_idx" ON "Initiative"("decidedById");
CREATE INDEX IF NOT EXISTS "SparkLedger_initiativeId_idx" ON "SparkLedger"("initiativeId");
CREATE INDEX IF NOT EXISTS "ExperienceLedger_initiativeId_idx" ON "ExperienceLedger"("initiativeId");

-- AddForeignKey
ALTER TABLE "Initiative" ADD CONSTRAINT "Initiative_decidedById_fkey" FOREIGN KEY ("decidedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "SparkLedger" ADD CONSTRAINT "SparkLedger_initiativeId_fkey" FOREIGN KEY ("initiativeId") REFERENCES "Initiative"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ExperienceLedger" ADD CONSTRAINT "ExperienceLedger_initiativeId_fkey" FOREIGN KEY ("initiativeId") REFERENCES "Initiative"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AlterEnum
ALTER TYPE "GoalStatus" ADD VALUE IF NOT EXISTS 'AWAITING_EXECUTION';

-- AlterTable
ALTER TABLE "FamilyGoal" ADD COLUMN IF NOT EXISTS "targetSparks" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "FamilyGoal" ADD COLUMN IF NOT EXISTS "currentSparks" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "FamilyGoal" ADD COLUMN IF NOT EXISTS "achievedAt" TIMESTAMP(3);
ALTER TABLE "FamilyGoal" ADD COLUMN IF NOT EXISTS "completedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "SparkLedger" ADD COLUMN IF NOT EXISTS "familyGoalId" TEXT;
ALTER TABLE "ExperienceLedger" ADD COLUMN IF NOT EXISTS "familyGoalId" TEXT;

-- CreateTable
CREATE TABLE "FamilyGoalCompletionConfirmation" (
    "id" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "goalId" TEXT NOT NULL,
    "memberId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FamilyGoalCompletionConfirmation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "FamilyGoalCompletionConfirmation_goalId_memberId_key" ON "FamilyGoalCompletionConfirmation"("goalId", "memberId");
CREATE INDEX "FamilyGoalCompletionConfirmation_familyId_idx" ON "FamilyGoalCompletionConfirmation"("familyId");
CREATE INDEX "FamilyGoalCompletionConfirmation_memberId_idx" ON "FamilyGoalCompletionConfirmation"("memberId");
CREATE INDEX "SparkLedger_familyGoalId_idx" ON "SparkLedger"("familyGoalId");
CREATE INDEX "ExperienceLedger_familyGoalId_idx" ON "ExperienceLedger"("familyGoalId");

-- AddForeignKey
ALTER TABLE "FamilyGoalCompletionConfirmation" ADD CONSTRAINT "FamilyGoalCompletionConfirmation_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "Family"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FamilyGoalCompletionConfirmation" ADD CONSTRAINT "FamilyGoalCompletionConfirmation_goalId_fkey" FOREIGN KEY ("goalId") REFERENCES "FamilyGoal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "FamilyGoalCompletionConfirmation" ADD CONSTRAINT "FamilyGoalCompletionConfirmation_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "FamilyMember"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SparkLedger" ADD CONSTRAINT "SparkLedger_familyGoalId_fkey" FOREIGN KEY ("familyGoalId") REFERENCES "FamilyGoal"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ExperienceLedger" ADD CONSTRAINT "ExperienceLedger_familyGoalId_fkey" FOREIGN KEY ("familyGoalId") REFERENCES "FamilyGoal"("id") ON DELETE SET NULL ON UPDATE CASCADE;

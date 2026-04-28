-- CreateEnum
CREATE TYPE "RewardStatus" AS ENUM ('PROPOSED', 'ACTIVE', 'REJECTED');

-- CreateEnum
CREATE TYPE "RewardPaymentMode" AS ENUM ('SPARKS', 'LEVEL_FREE');

-- CreateEnum
CREATE TYPE "RewardRequestStatus" AS ENUM ('IN_PROGRESS', 'FULFILLED', 'RECEIVED', 'CANCEL_REQUESTED', 'CANCELLED');

-- AlterTable
ALTER TABLE "Reward" ADD COLUMN "paymentMode" "RewardPaymentMode" NOT NULL DEFAULT 'SPARKS';
ALTER TABLE "Reward" ADD COLUMN "status" "RewardStatus" NOT NULL DEFAULT 'PROPOSED';
ALTER TABLE "Reward" ADD COLUMN "levelRequired" INTEGER;
ALTER TABLE "Reward" ADD COLUMN "approvedById" TEXT;
ALTER TABLE "Reward" ADD COLUMN "approvedAt" TIMESTAMP(3);
ALTER TABLE "Reward" ADD COLUMN "rejectedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "SparkLedger" ADD COLUMN "rewardRequestId" TEXT;

-- CreateTable
CREATE TABLE "RewardTemplate" (
    "id" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "pointsCost" INTEGER NOT NULL DEFAULT 0,
    "paymentMode" "RewardPaymentMode" NOT NULL DEFAULT 'SPARKS',
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RewardTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RewardRequest" (
    "id" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "rewardId" TEXT NOT NULL,
    "requesterMemberId" TEXT NOT NULL,
    "providerMemberId" TEXT NOT NULL,
    "status" "RewardRequestStatus" NOT NULL DEFAULT 'IN_PROGRESS',
    "statusBeforeCancel" "RewardRequestStatus",
    "paymentMode" "RewardPaymentMode" NOT NULL,
    "sparksCost" INTEGER NOT NULL DEFAULT 0,
    "levelSnapshot" INTEGER,
    "fulfilledAt" TIMESTAMP(3),
    "receivedAt" TIMESTAMP(3),
    "cancelRequestedById" TEXT,
    "cancelRequestedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RewardRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Reward_familyId_status_idx" ON "Reward"("familyId", "status");
CREATE INDEX "Reward_createdById_idx" ON "Reward"("createdById");
CREATE INDEX "Reward_approvedById_idx" ON "Reward"("approvedById");
CREATE INDEX "RewardTemplate_familyId_idx" ON "RewardTemplate"("familyId");
CREATE INDEX "RewardRequest_familyId_status_idx" ON "RewardRequest"("familyId", "status");
CREATE INDEX "RewardRequest_rewardId_idx" ON "RewardRequest"("rewardId");
CREATE INDEX "RewardRequest_requesterMemberId_idx" ON "RewardRequest"("requesterMemberId");
CREATE INDEX "RewardRequest_providerMemberId_idx" ON "RewardRequest"("providerMemberId");
CREATE INDEX "SparkLedger_rewardRequestId_idx" ON "SparkLedger"("rewardRequestId");

-- AddForeignKey
ALTER TABLE "Reward" ADD CONSTRAINT "Reward_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "RewardTemplate" ADD CONSTRAINT "RewardTemplate_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "Family"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RewardTemplate" ADD CONSTRAINT "RewardTemplate_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RewardRequest" ADD CONSTRAINT "RewardRequest_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "Family"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RewardRequest" ADD CONSTRAINT "RewardRequest_rewardId_fkey" FOREIGN KEY ("rewardId") REFERENCES "Reward"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RewardRequest" ADD CONSTRAINT "RewardRequest_requesterMemberId_fkey" FOREIGN KEY ("requesterMemberId") REFERENCES "FamilyMember"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "RewardRequest" ADD CONSTRAINT "RewardRequest_providerMemberId_fkey" FOREIGN KEY ("providerMemberId") REFERENCES "FamilyMember"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SparkLedger" ADD CONSTRAINT "SparkLedger_rewardRequestId_fkey" FOREIGN KEY ("rewardRequestId") REFERENCES "RewardRequest"("id") ON DELETE SET NULL ON UPDATE CASCADE;

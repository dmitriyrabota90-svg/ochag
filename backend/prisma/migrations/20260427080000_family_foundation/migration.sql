-- AlterTable
ALTER TABLE "Family" ADD COLUMN "inviteCode" TEXT;

-- CreateTable
CREATE TABLE "FamilyDeleteRequest" (
    "id" TEXT NOT NULL,
    "tokenId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FamilyDeleteRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Family_inviteCode_key" ON "Family"("inviteCode");

-- CreateIndex
CREATE UNIQUE INDEX "FamilyDeleteRequest_tokenId_key" ON "FamilyDeleteRequest"("tokenId");

-- CreateIndex
CREATE INDEX "FamilyDeleteRequest_familyId_usedAt_idx" ON "FamilyDeleteRequest"("familyId", "usedAt");

-- CreateIndex
CREATE INDEX "FamilyDeleteRequest_userId_usedAt_idx" ON "FamilyDeleteRequest"("userId", "usedAt");

-- CreateIndex
CREATE INDEX "FamilyDeleteRequest_expiresAt_idx" ON "FamilyDeleteRequest"("expiresAt");

-- AddForeignKey
ALTER TABLE "FamilyDeleteRequest" ADD CONSTRAINT "FamilyDeleteRequest_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "Family"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FamilyDeleteRequest" ADD CONSTRAINT "FamilyDeleteRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

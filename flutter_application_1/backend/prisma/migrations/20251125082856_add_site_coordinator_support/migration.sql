-- CreateEnum
CREATE TYPE "AssignedRole" AS ENUM ('worker', 'sitecoordinator');

-- AlterTable
ALTER TABLE "announcements" ADD COLUMN     "created_by" UUID;

-- CreateTable
CREATE TABLE "site_user_assignments" (
    "id" UUID NOT NULL,
    "site_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "assigned_role" "AssignedRole" NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "site_user_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "site_user_assignments_site_id_idx" ON "site_user_assignments"("site_id");

-- CreateIndex
CREATE INDEX "site_user_assignments_user_id_idx" ON "site_user_assignments"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "site_user_assignments_site_id_user_id_key" ON "site_user_assignments"("site_id", "user_id");

-- CreateIndex
CREATE INDEX "announcements_created_by_idx" ON "announcements"("created_by");

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_user_assignments" ADD CONSTRAINT "site_user_assignments_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "sites"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "site_user_assignments" ADD CONSTRAINT "site_user_assignments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

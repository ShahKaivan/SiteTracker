-- CreateTable
CREATE TABLE "announcements" (
    "id" UUID NOT NULL,
    "site_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "message" TEXT NOT NULL,
    "priority" VARCHAR(20) NOT NULL DEFAULT 'medium',
    "expiry_date" TIMESTAMP(6),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "announcements_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "announcements_site_id_idx" ON "announcements"("site_id");

-- AddForeignKey
ALTER TABLE "announcements"
    ADD CONSTRAINT "announcements_site_id_fkey"
    FOREIGN KEY ("site_id") REFERENCES "sites"("id")
    ON DELETE SET NULL
    ON UPDATE CASCADE;




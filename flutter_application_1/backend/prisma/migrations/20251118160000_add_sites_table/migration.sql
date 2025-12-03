-- Create sites table if it doesn't exist
CREATE TABLE IF NOT EXISTS "sites" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50),
    "name" VARCHAR(255) NOT NULL,
    "address" TEXT,
    "latitude" DECIMAL(10,8),
    "longitude" DECIMAL(11,8),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,
    CONSTRAINT "sites_pkey" PRIMARY KEY ("id")
);

-- Ensure code is unique when provided
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE schemaname = 'public' AND indexname = 'sites_code_key'
    ) THEN
        CREATE UNIQUE INDEX "sites_code_key" ON "sites"("code");
    END IF;
END;
$$;

-- Refresh attendance -> sites foreign key
ALTER TABLE "attendance"
    DROP CONSTRAINT IF EXISTS "attendance_site_id_fkey";

ALTER TABLE "attendance"
    ADD CONSTRAINT "attendance_site_id_fkey"
    FOREIGN KEY ("site_id")
    REFERENCES "sites"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE;




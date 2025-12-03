-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "mobile_number" VARCHAR(20) NOT NULL,
    "country_code" VARCHAR(10) NOT NULL,
    "password_hash" VARCHAR(255),
    "full_name" VARCHAR(255),
    "role" VARCHAR(50),
    "is_mobile_verified" BOOLEAN NOT NULL DEFAULT false,
    "profile_image_url" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,
    "last_login_at" TIMESTAMP(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance" (
    "id" UUID NOT NULL,
    "worker_id" UUID NOT NULL,
    "site_id" UUID NOT NULL,
    "date" TIMESTAMP(6) NOT NULL,
    "punch_in_time" TIMESTAMP(6),
    "punch_in_latitude" DECIMAL(10,8),
    "punch_in_longitude" DECIMAL(11,8),
    "punch_in_selfie_url" TEXT,
    "punch_out_time" TIMESTAMP(6),
    "punch_out_latitude" DECIMAL(10,8),
    "punch_out_longitude" DECIMAL(11,8),
    "punch_out_selfie_url" TEXT,
    "total_hours" DECIMAL(10,2),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "attendance_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_country_code_mobile_number_key" ON "users"("country_code", "mobile_number");

-- CreateIndex
CREATE INDEX "attendance_worker_id_idx" ON "attendance"("worker_id");

-- CreateIndex
CREATE INDEX "attendance_date_idx" ON "attendance"("date");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_worker_id_date_key" ON "attendance"("worker_id", "date");

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_worker_id_fkey" FOREIGN KEY ("worker_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

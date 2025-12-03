-- ============================================
-- Test Data for Site-Coordinator Features
-- ============================================

-- Clear existing data (optional - uncomment if needed)
-- DELETE FROM "attendance";
-- DELETE FROM "announcements";
-- DELETE FROM "site_user_assignments";
-- DELETE FROM "sites";
-- DELETE FROM "users";

-- ============================================
-- 1. CREATE SITES
-- ============================================

INSERT INTO "sites" (id, name, code, location, latitude, longitude, created_at, updated_at)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Construction Site A', 'CS-A', 'Sector 14, Gurgaon', 28.4595, 77.0266, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Construction Site B', 'CS-B', 'Cyber City, Gurgaon', 28.4949, 77.0825, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333333', 'Renovation Site C', 'RS-C', 'Golf Course Road, Gurgaon', 28.4355, 77.0869, NOW(), NOW());

-- ============================================
-- 2. CREATE USERS
-- ============================================

-- Site Coordinator (Login: +91 9999999999)
INSERT INTO users (id, mobile_number, country_code, password_hash, full_name, role, created_at, updated_at)
VALUES 
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '9999999999', '+91', '$2b$10$dummyhashforcoordinator', 'Rajesh Kumar (Coordinator)', 'site_coordinator', NOW(), NOW());

-- Workers for Site A
INSERT INTO users (id, mobile_number, country_code, password_hash, full_name, role, created_at, updated_at)
VALUES 
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '9876543210', '+91', '$2b$10$dummyhashforworker1', 'John Doe', 'worker', NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '9876543211', '+91', '$2b$10$dummyhashforworker2', 'Jane Smith', 'worker', NOW(), NOW()),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '9876543212', '+91', '$2b$10$dummyhashforworker3', 'Robert Johnson', 'worker', NOW(), NOW());

-- Workers for Site B
INSERT INTO users (id, mobile_number, country_code, password_hash, full_name, role, created_at, updated_at)
VALUES 
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '9876543213', '+91', '$2b$10$dummyhashforworker4', 'Mike Wilson', 'worker', NOW(), NOW()),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', '9876543214', '+91', '$2b$10$dummyhashforworker5', 'Sarah Davis', 'worker', NOW(), NOW());

-- Worker for Site C
INSERT INTO users (id, mobile_number, country_code, password_hash, full_name, role, created_at, updated_at)
VALUES 
  ('gggggggg-gggg-gggg-gggg-gggggggggggg', '9876543215', '+91', '$2b$10$dummyhashforworker6', 'David Brown', 'worker', NOW(), NOW());

-- ============================================
-- 3. ASSIGN COORDINATOR TO SITES
-- ============================================

INSERT INTO "site_user_assignments" (id, site_id, user_id, assigned_role, created_at, updated_at)
VALUES 
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'sitecoordinator', NOW(), NOW()),
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'sitecoordinator', NOW(), NOW()),
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'sitecoordinator', NOW(), NOW());

-- ============================================
-- 4. ASSIGN WORKERS TO SITES
-- ============================================

-- Site A Workers
INSERT INTO "site_user_assignments" (id, site_id, user_id, assigned_role, created_at, updated_at)
VALUES 
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'worker', NOW(), NOW()),
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'worker', NOW(), NOW()),
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'worker', NOW(), NOW());

-- Site B Workers
INSERT INTO "site_user_assignments" (id, site_id, user_id, assigned_role, created_at, updated_at)
VALUES 
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'worker', NOW(), NOW()),
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'worker', NOW(), NOW());

-- Site C Worker
INSERT INTO "site_user_assignments" (id, site_id, user_id, assigned_role, created_at, updated_at)
VALUES 
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'gggggggg-gggg-gggg-gggg-gggggggggggg', 'worker', NOW(), NOW());

-- ============================================
-- 5. CREATE ANNOUNCEMENTS
-- ============================================

-- Active Announcements (Site A)
INSERT INTO "announcements" (id, site_id, title, message, priority, is_active, created_by, created_at, updated_at, expiry_date)
VALUES 
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Safety Equipment Update', 'New safety helmets and vests have arrived. Please collect them from the site office before starting work today.', 'high', true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '2 days', NOW(), NOW() + INTERVAL '5 days'),
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Weekly Team Meeting', 'Team meeting scheduled for Friday at 3 PM in the main conference room. Attendance is mandatory for all workers.', 'medium', true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '1 day', NOW(), NOW() + INTERVAL '3 days');

-- Active Announcement (Site B)
INSERT INTO "announcements" (id, site_id, title, message, priority, is_active, created_by, created_at, updated_at, expiry_date)
VALUES 
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'Material Delivery Tomorrow', 'Cement and steel delivery expected tomorrow morning at 8 AM. Please ensure the storage area is clear.', 'high', true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '5 hours', NOW(), NOW() + INTERVAL '1 day');

-- Expired Announcement (Site B)
INSERT INTO "announcements" (id, site_id, title, message, priority, is_active, created_by, created_at, updated_at, expiry_date)
VALUES 
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'Holiday Notice - Diwali', 'Site will be closed on October 31st and November 1st for Diwali celebrations.', 'low', true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '10 days', NOW(), NOW() - INTERVAL '1 day');

-- Active Announcement (Site C)
INSERT INTO "announcements" (id, site_id, title, message, priority, is_active, created_by, created_at, updated_at)
VALUES 
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'Quality Inspection Next Week', 'Government quality inspection team will visit next week. Ensure all work meets standards.', 'medium', true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '3 hours', NOW(), NULL);

-- ============================================
-- 6. CREATE ATTENDANCE RECORDS
-- ============================================

-- Attendance for John Doe (Site A) - Last 7 days
INSERT INTO "attendance" (id, worker_id, site_id, date, punch_in_time, punch_out_time, total_hours, created_at, updated_at)
VALUES 
  -- Complete Days
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days' + INTERVAL '9 hours', NOW() - INTERVAL '6 days' + INTERVAL '17 hours', 8.0, NOW(), NOW()),
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '9 hours', NOW() - INTERVAL '5 days' + INTERVAL '18 hours', 9.0, NOW(), NOW()),
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days' + INTERVAL '8 hours 30 minutes', NOW() - INTERVAL '4 days' + INTERVAL '17 hours', 8.5, NOW(), NOW()),
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '9 hours', NOW() - INTERVAL '3 days' + INTERVAL '17 hours 30 minutes', 8.5, NOW(), NOW()),
  -- Incomplete Day (only punch in)
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '9 hours', NULL, NULL, NOW(), NOW()),
  -- Complete Days
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '9 hours', NOW() - INTERVAL '1 day' + INTERVAL '18 hours', 9.0, NOW(), NOW()),
  -- Today - only punch in
  (gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', NOW()::date, NOW() - INTERVAL '2 hours', NULL, NULL, NOW(), NOW());

-- Attendance for Jane Smith (Site A) - Last 5 days
INSERT INTO "attendance" (id, worker_id, site_id, date, punch_in_time, punch_out_time, total_hours, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days' + INTERVAL '9 hours', NOW() - INTERVAL '4 days' + INTERVAL '17 hours', 8.0, NOW(), NOW()),
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '9 hours 15 minutes', NOW() - INTERVAL '3 days' + INTERVAL '18 hours', 8.75, NOW(), NOW()),
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '9 hours', NOW() - INTERVAL '2 days' + INTERVAL '17 hours 30 minutes', 8.5, NOW(), NOW()),
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '9 hours', NOW() - INTERVAL '1 day' + INTERVAL '18 hours 15 minutes', 9.25, NOW(), NOW()),
  (gen_random_uuid(), 'cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', NOW()::date, NOW() - INTERVAL '1 hour 30 minutes', NULL, NULL, NOW(), NOW());

-- Attendance for Mike Wilson (Site B) - Last 3 days
INSERT INTO "attendance" (id, worker_id, site_id, date, punch_in_time, punch_out_time, total_hours, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '8 hours 30 minutes', NOW() - INTERVAL '2 days' + INTERVAL '17 hours', 8.5, NOW(), NOW()),
  (gen_random_uuid(), 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '9 hours', NOW() - INTERVAL '1 day' + INTERVAL '18 hours 30 minutes', 9.5, NOW(), NOW()),
  (gen_random_uuid(), 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', NOW()::date, NOW() - INTERVAL '3 hours', NULL, NULL, NOW(), NOW());

-- Attendance for David Brown (Site C) - Last 2 days
INSERT INTO "attendance" (id, worker_id, site_id, date, punch_in_time, punch_out_time, total_hours, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'gggggggg-gggg-gggg-gggg-gggggggggggg', '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '9 hours', NOW() - INTERVAL '1 day' + INTERVAL '17 hours', 8.0, NOW(), NOW()),
  (gen_random_uuid(), 'gggggggg-gggg-gggg-gggg-gggggggggggg', '33333333-3333-3333-3333-333333333333', NOW()::date, NOW() - INTERVAL '4 hours', NULL, NULL, NOW(), NOW());

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check all data was inserted correctly
SELECT 'Sites' as table_name, COUNT(*) as count FROM "sites"
UNION ALL
SELECT 'Users', COUNT(*) FROM users
UNION ALL
SELECT 'Site Assignments', COUNT(*) FROM "site_user_assignments"
UNION ALL
SELECT 'Announcements', COUNT(*) FROM "announcements"
UNION ALL
SELECT 'attendance Records', COUNT(*) FROM "attendance";

-- Test Coordinator Login Info
SELECT 
  'COORDINATOR LOGIN' as info,
  country_code || ' ' || mobile_number as login_number,
  full_name,
  role
FROM users 
WHERE role = 'site_coordinator';

-- Test Worker Login Info
SELECT 
  'WORKER LOGINS' as info,
  country_code || ' ' || mobile_number as login_number,
  full_name,
  role
FROM users 
WHERE role = 'worker'
ORDER BY mobile_number;

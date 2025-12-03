# Database Test Data & Testing Guide

## 📋 Setup Instructions

### 1. Run the SQL Script

Execute the test data SQL file in your PostgreSQL database:

```bash
# Navigate to backend folder
cd backend

# Run the SQL script
psql -U your_username -d your_database_name -f test_data.sql
```

**OR** using a GUI tool like pgAdmin, DBeaver, or TablePlus:
- Open the `test_data.sql` file
- Execute all queries

---

## 🔑 Test Login Credentials

### Site Coordinator
- **Mobile Number**: `+91 9999999999`
- **Name**: Rajesh Kumar (Coordinator)
- **Has access to**: All 3 sites (CS-A, CS-B, RS-C)

### Workers (Site A)
- **John Doe**: `+91 9876543210`
- **Jane Smith**: `+91 9876543211`
- **Robert Johnson**: `+91 9876543212`

### Workers (Site B)
- **Mike Wilson**: `+91 9876543213`
- **Sarah Davis**: `+91 9876543214`

### Workers (Site C)
- **David Brown**: `+91 9876543215`

---

## 🧪 Testing Checklist

### ✅ 1. Announcements Module

**Test as Coordinator** (`+91 9999999999`):

1. **View Announcements**
   - Should see announcements from all sites
   - Check priority colors (High=Red, Medium=Orange, Low=Blue)
   - Verify expired announcements show correctly

2. **Create Announcement**
   - Navigate: Drawer → "Create Announcement"
   - Select a site (CS-A, CS-B, or RS-C)
   - Enter title and message
   - Select priority (Low/Medium/High)
   - Set expiry date (optional)
   - Submit and verify success

3. **My Announcements**
   - Navigate: Drawer → "My Announcements"
   - Filter by different sites
   - Check statistics (Total/Active/Expired)
   - View announcement details
   - Try deactivating an active announcement

**Expected Data**:
- 5 announcements total
- 4 active, 1 expired
- Sites A, B, and C have announcements

---

### ✅ 2. Attendance Management

**Test as Coordinator** (`+91 9999999999`):

1. **Filter Attendance**
   - Navigate: Drawer → "Attendance Management"
   - Select Site: Construction Site A
   - Select Worker: "All Workers" / "Myself" / specific worker
   - Pick date range (last 7 days)
   - Tap "View Attendance"

2. **View Results**
   - Check statistics summary
   - Verify attendance cards show correctly
   - Complete vs Incomplete days
   - Total hours calculation
   - Tap card to see details modal

**Expected Data**:
- Site A: John (7 records), Jane (5 records)
- Site B: Mike (3 records)
- Site C: David (2 records)
- Mix of complete and incomplete days

---

### ✅ 3. Worker Management

**Test as Coordinator** (`+91 9999999999`):

1. **View Workers in Sites**
   - Navigate: Drawer → "Workers in My Sites"
   - Select different sites from dropdown
   - Verify worker cards show:
     - Name initials or profile image
     - Mobile number
     - Role badge
   - Tap menu (⋮) on worker
   - Check action options

2. **Add Worker to Site**
   - Navigate: Drawer → "Add Worker to Site"
   - Select site
   - Enter full name (min 3 chars)
   - Select country code (default +91)
   - Enter mobile number (10 digits)
   - Submit
   - Verify success dialog
   - Check worker appears in list

**Expected Data**:
- Site A: 3 workers
- Site B: 2 workers
- Site C: 1 worker

---

### ✅ 4. Worker Features

**Test as Worker** (e.g., `+91 9876543210` - John Doe):

1. **View Announcements**
   - Should see Site A announcements only
   - Check priority indicators
   - Verify can't create/edit announcements

2. **Attendance History**
   - Navigate: Drawer → "Attendance History"
   - Should see 7 attendance records
   - Mix of complete (6) and incomplete (1) days
   - Today's record shows as incomplete
   - Tap record to see details

3. **Punch In/Out** (if implemented)
   - Test punch-in functionality
   - Verify location capture
   - Test punch-out

---

## 📊 Data Summary

| Item | Count |
|------|-------|
| Sites | 3 |
| Total Users | 7 |
| Coordinators | 1 |
| Workers | 6 |
| Site Assignments | 9 |
| Announcements | 5 |
| Attendance Records | 17 |

---

## 🎯 Feature Coverage

### ✅ Implemented & Testable
- [x] Site-Coordinator role assignment
- [x] Announcements creation & viewing
- [x] My Announcements management
- [x] Attendance filtering (by site, worker, date)
- [x] Filtered attendance results with statistics
- [x] Add worker to site
- [x] Workers in my sites listing
- [x] Worker-specific announcement viewing
- [x] Worker attendance history

### 🔄 Requires Backend Integration
- [ ] Actual API calls (currently using placeholder data)
- [ ] Authentication with real tokens
- [ ] Profile image upload
- [ ] Announcement deactivation API
- [ ] Worker removal from site API
- [ ] Export to Excel/CSV

---

## 🐛 Common Issues & Solutions

### Issue: Can't login
**Solution**: Ensure backend is running (`npm run dev`) and database is populated

### Issue: No data showing
**Solution**: 
1. Check if SQL script ran successfully
2. Verify backend is connected to correct database
3. Check console for API errors

### Issue: API errors
**Solution**:
1. Ensure `baseUrl` in `constants.dart` matches your backend URL
2. Backend should be running on port 3000
3. Check backend logs for errors

---

## 📝 Notes

- All passwords are dummy hashes - backend needs proper authentication
- Attendance records have realistic timestamps (last 7 days)
- UUIDs are hardcoded for easy reference
- Profile images are NULL (will show initials)
- All dates use `NOW()` function for relative timestamps

---

**Happy Testing! 🚀**

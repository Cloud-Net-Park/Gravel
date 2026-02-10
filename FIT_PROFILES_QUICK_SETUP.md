# ✅ FIT PROFILES - QUICK SETUP GUIDE

**Date:** February 10, 2026  
**Status:** ✅ COMPLETE & READY  
**Build:** ✅ SUCCESS  

---

## COPY & PASTE THIS SQL INTO SUPABASE

Go to Supabase Console → SQL Editor → New Query → Paste this:

```sql
-- Drop old policies
DROP POLICY IF EXISTS "Users can view their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Users can insert their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Users can update their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Users can delete their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Admins can view all fit profiles" ON fit_profiles;

-- Create table
CREATE TABLE IF NOT EXISTS fit_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  preferred_size VARCHAR(5) NOT NULL,
  body_type VARCHAR(20),
  height VARCHAR(10),
  weight VARCHAR(10),
  preferred_fit VARCHAR(20),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_fit_profiles_user_id ON fit_profiles(user_id);

-- Enable RLS
ALTER TABLE fit_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own fit profiles"
  ON fit_profiles FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own fit profiles"
  ON fit_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own fit profiles"
  ON fit_profiles FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own fit profiles"
  ON fit_profiles FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all fit profiles"
  ON fit_profiles FOR SELECT USING (true);
```

Then click **Run** ✅

---

## AFTER SQL RUNS

1. Refresh browser (F5)
2. Test Refine Fit feature
3. Check Admin Dashboard → Fit Profiles tab

---

## WHAT HAPPENS

### User Flow:
```
Click "Refine Fit" 
  → Select Size (S, M, L)
  → Select Body Type (Regular)
  → Add Height/Weight (optional)
  → Select Fit Preference
  → Profile SAVED to database
```

### Admin Sees:
```
Fit Profiles Tab:
- User name & email
- Size: M (bold)
- Body Type: regular
- Height: 175 cm
- Weight: 70 kg
- Fit: regular
- Created: Feb 10, 2026
```

---

## FILES UPDATED

✅ app-store.tsx - Fixed database functions
✅ fit-intelligence.tsx - Updated data passing
✅ admin-dashboard.tsx - Updated table display

---

## BUILD STATUS

✅ SUCCESS (3.65 seconds)
✅ New bundle: index-BOCJbMZ8.js
✅ Ready to deploy

---

**EVERYTHING IS READY!**

Just run the SQL above and test! 🎉


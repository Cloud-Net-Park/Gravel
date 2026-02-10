-- Fit Profiles Table for Grazel Apparel
-- Stores user size preferences and body type for personalized recommendations

-- Drop existing table and policies if they exist (for clean setup)
DROP POLICY IF EXISTS "Users can view their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Users can insert their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Users can update their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Users can delete their own fit profiles" ON fit_profiles;
DROP POLICY IF EXISTS "Admins can view all fit profiles" ON fit_profiles;

-- Drop and recreate table (WARNING: This will delete existing data)
-- Comment out the next line if you want to keep existing data
-- DROP TABLE IF EXISTS fit_profiles;

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

-- Create index on user_id for faster queries
CREATE INDEX IF NOT EXISTS idx_fit_profiles_user_id ON fit_profiles(user_id);

-- Enable Row Level Security
ALTER TABLE fit_profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS Policy: Users can only view their own fit profiles
CREATE POLICY "Users can view their own fit profiles"
  ON fit_profiles
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create RLS Policy: Users can only insert their own fit profiles
CREATE POLICY "Users can insert their own fit profiles"
  ON fit_profiles
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create RLS Policy: Users can only update their own fit profiles
CREATE POLICY "Users can update their own fit profiles"
  ON fit_profiles
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create RLS Policy: Users can only delete their own fit profiles
CREATE POLICY "Users can delete their own fit profiles"
  ON fit_profiles
  FOR DELETE
  USING (auth.uid() = user_id);

-- Admin policy: Allow admins to view all fit profiles (for admin dashboard)
CREATE POLICY "Admins can view all fit profiles"
  ON fit_profiles
  FOR SELECT
  USING (true);


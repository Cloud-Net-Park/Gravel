-- Fit Profiles Table for Grazel Apparel
-- Stores user body measurements and size preferences for personalized recommendations

CREATE TABLE IF NOT EXISTS fit_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  height VARCHAR(10) NOT NULL,
  weight VARCHAR(10),
  chest VARCHAR(10),
  waist VARCHAR(10),
  hips VARCHAR(10),
  preferred_fit VARCHAR(20) NOT NULL,
  preferred_size VARCHAR(5) NOT NULL,
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


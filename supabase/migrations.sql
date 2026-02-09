-- Supabase Migration: Add missing product fields and fit profile support
-- Run this SQL in Supabase to update existing database with new features
-- Date: February 9, 2026

-- Add missing columns to products table if they don't exist
ALTER TABLE products
ADD COLUMN IF NOT EXISTS gender TEXT,
ADD COLUMN IF NOT EXISTS is_essential BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS offer_percentage DECIMAL(5, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create indexes for new columns for better query performance
CREATE INDEX IF NOT EXISTS idx_products_gender ON products(gender);
CREATE INDEX IF NOT EXISTS idx_products_is_essential ON products(is_essential);
CREATE INDEX IF NOT EXISTS idx_products_offer_percentage ON products(offer_percentage) WHERE offer_percentage > 0;
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at);

-- Ensure fit_profiles table exists with all fields
CREATE TABLE IF NOT EXISTS fit_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  height TEXT,
  weight TEXT,
  chest TEXT,
  waist TEXT,
  hips TEXT,
  preferred_fit TEXT DEFAULT 'regular' CHECK (preferred_fit IN ('slim', 'regular', 'relaxed')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for fit_profiles
CREATE INDEX IF NOT EXISTS idx_fit_profiles_user_id ON fit_profiles(user_id);

-- Enable RLS on fit_profiles if not already enabled
ALTER TABLE fit_profiles ENABLE ROW LEVEL SECURITY;

-- Set up RLS policies for fit_profiles
DROP POLICY IF EXISTS "Users can read own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can insert own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can update own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can delete own fit profile" ON fit_profiles;

CREATE POLICY "Users can read own fit profile"
  ON fit_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own fit profile"
  ON fit_profiles FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own fit profile"
  ON fit_profiles FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own fit profile"
  ON fit_profiles FOR DELETE
  USING (user_id = auth.uid());

-- Verify the migration
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products'
ORDER BY ordinal_position;

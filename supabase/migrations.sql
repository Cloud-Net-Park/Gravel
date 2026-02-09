-- Supabase Migration: Add missing product fields
-- Run this SQL in Supabase to update existing products table with new fields
-- Date: February 9, 2026

-- Add missing columns to products table if they don't exist
ALTER TABLE products
ADD COLUMN IF NOT EXISTS gender TEXT,
ADD COLUMN IF NOT EXISTS is_essential BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS offer_percentage DECIMAL(5, 2) DEFAULT 0;

-- Create indexes for new columns for better query performance
CREATE INDEX IF NOT EXISTS idx_products_gender ON products(gender);
CREATE INDEX IF NOT EXISTS idx_products_is_essential ON products(is_essential);
CREATE INDEX IF NOT EXISTS idx_products_offer_percentage ON products(offer_percentage) WHERE offer_percentage > 0;

-- Verify the migration
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'products'
ORDER BY ordinal_position;

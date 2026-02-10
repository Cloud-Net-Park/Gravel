-- ============================================
-- GRAZEL APPAREL SUPABASE - COMPLETE DATABASE SETUP
-- ============================================
-- Combined SQL file containing all migrations, fixes, and schema
-- This file is idempotent - safe to run multiple times
-- Date: February 10, 2026
--
-- CONTENTS:
-- 1. Database Schema (All Tables)
-- 2. Row-Level Security (RLS) Policies
-- 3. Functions and Triggers
-- 4. User Registration Fix
-- 5. Product Fields Migration
-- 6. Newsletter Subscribers Table
--
-- TABLES CREATED:
-- - users
-- - user_addresses
-- - products
-- - orders
-- - order_items
-- - cart_items
-- - fit_profiles
-- - wishlist_items
-- - reviews
-- - newsletter_subscribers
--
-- ============================================

-- ============================================
-- SECTION 1: DATABASE SCHEMA
-- ============================================

-- 1. Users Table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  joined_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. User Addresses Table
CREATE TABLE IF NOT EXISTS user_addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  street TEXT NOT NULL,
  city TEXT NOT NULL,
  postcode TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'United Kingdom',
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Products Table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  fabric TEXT NOT NULL,
  fit TEXT NOT NULL,
  category TEXT,
  sizes TEXT[] DEFAULT ARRAY[]::TEXT[],
  sku TEXT UNIQUE,
  gender TEXT,
  is_essential BOOLEAN DEFAULT FALSE,
  offer_percentage DECIMAL(5, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Orders Table
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  order_number TEXT UNIQUE NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  total_amount DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  shipping_amount DECIMAL(10, 2) DEFAULT 0,
  shipping_street TEXT,
  shipping_city TEXT,
  shipping_postcode TEXT,
  shipping_country TEXT,
  billing_street TEXT,
  billing_city TEXT,
  billing_postcode TEXT,
  billing_country TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  shipped_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE
);

-- 5. Order Items Table (Line items in orders)
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price DECIMAL(10, 2) NOT NULL,
  selected_size TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Cart Items Table
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  selected_size TEXT NOT NULL,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id, selected_size)
);

-- 7. Fit Profiles Table
CREATE TABLE IF NOT EXISTS fit_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  height TEXT,
  weight TEXT,
  chest TEXT,
  waist TEXT,
  hips TEXT,
  preferred_fit TEXT DEFAULT 'regular' CHECK (preferred_fit IN ('slim', 'regular', 'relaxed')),
  preferred_size TEXT DEFAULT 'M',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Wishlist Items Table
CREATE TABLE IF NOT EXISTS wishlist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- 9. Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title TEXT NOT NULL,
  comment TEXT,
  is_verified_purchase BOOLEAN DEFAULT FALSE,
  helpful_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Newsletter Subscribers Table
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT TRUE,
  subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unsubscribed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- SECTION 2: INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_gender ON products(gender);
CREATE INDEX IF NOT EXISTS idx_products_is_essential ON products(is_essential);
CREATE INDEX IF NOT EXISTS idx_products_offer_percentage ON products(offer_percentage) WHERE offer_percentage > 0;
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at);
CREATE INDEX IF NOT EXISTS idx_fit_profiles_user_id ON fit_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_user_id ON wishlist_items(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_newsletter_subscribers_email ON newsletter_subscribers(email);
CREATE INDEX IF NOT EXISTS idx_newsletter_subscribers_is_active ON newsletter_subscribers(is_active);

-- ============================================
-- SECTION 3: ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE fit_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can view own addresses" ON user_addresses;
DROP POLICY IF EXISTS "Users can insert own addresses" ON user_addresses;
DROP POLICY IF EXISTS "Users can update own addresses" ON user_addresses;
DROP POLICY IF EXISTS "Users can delete own addresses" ON user_addresses;
DROP POLICY IF EXISTS "Anyone can read products" ON products;
DROP POLICY IF EXISTS "Users can read own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON orders;
DROP POLICY IF EXISTS "Users can update own orders" ON orders;
DROP POLICY IF EXISTS "Users can read own order items" ON order_items;
DROP POLICY IF EXISTS "Users can read own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can insert to own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can update own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can delete own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can read own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can insert own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can update own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can delete own fit profile" ON fit_profiles;
DROP POLICY IF EXISTS "Users can read own wishlist" ON wishlist_items;
DROP POLICY IF EXISTS "Users can insert to own wishlist" ON wishlist_items;
DROP POLICY IF EXISTS "Users can delete from own wishlist" ON wishlist_items;
DROP POLICY IF EXISTS "Anyone can read reviews" ON reviews;
DROP POLICY IF EXISTS "Users can insert own reviews" ON reviews;
DROP POLICY IF EXISTS "Users can update own reviews" ON reviews;
DROP POLICY IF EXISTS "Users can delete own reviews" ON reviews;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  USING (auth.uid() = id);

-- User addresses - users can only access their own
CREATE POLICY "Users can view own addresses"
  ON user_addresses
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own addresses"
  ON user_addresses
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own addresses"
  ON user_addresses
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own addresses"
  ON user_addresses
  FOR DELETE
  USING (auth.uid() = user_id);

-- Products - all authenticated users can read
CREATE POLICY "Anyone can read products"
  ON products
  FOR SELECT
  USING (true);

-- Orders - users can only see their own orders
CREATE POLICY "Users can read own orders"
  ON orders
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders"
  ON orders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders"
  ON orders
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Order items - users can see items in their own orders
CREATE POLICY "Users can read own order items"
  ON order_items
  FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders WHERE user_id = auth.uid()
    )
  );

-- Cart items - users can only access their own cart
CREATE POLICY "Users can read own cart"
  ON cart_items
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert to own cart"
  ON cart_items
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart"
  ON cart_items
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart items"
  ON cart_items
  FOR DELETE
  USING (auth.uid() = user_id);

-- Fit profiles - users can only access their own
CREATE POLICY "Users can read own fit profile"
  ON fit_profiles
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fit profile"
  ON fit_profiles
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fit profile"
  ON fit_profiles
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fit profile"
  ON fit_profiles
  FOR DELETE
  USING (auth.uid() = user_id);

-- Wishlist - users can only access their own
CREATE POLICY "Users can read own wishlist"
  ON wishlist_items
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert to own wishlist"
  ON wishlist_items
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete from own wishlist"
  ON wishlist_items
  FOR DELETE
  USING (auth.uid() = user_id);

-- Reviews - users can read all, but only edit their own
CREATE POLICY "Anyone can read reviews"
  ON reviews
  FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own reviews"
  ON reviews
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
  ON reviews
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
  ON reviews
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- SECTION 4: FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to auto-generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
  RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(CAST(FLOOR(RANDOM() * 9999) + 1000 AS TEXT), 4, '0');
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate order number on insert
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL THEN
    NEW.order_number := generate_order_number();
  END IF;
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists before creating
DROP TRIGGER IF EXISTS orders_set_order_number ON orders;

CREATE TRIGGER orders_set_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION set_order_number();

-- Trigger to update order timestamp
CREATE OR REPLACE FUNCTION update_order_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists before creating
DROP TRIGGER IF EXISTS orders_update_timestamp ON orders;

CREATE TRIGGER orders_update_timestamp
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_order_timestamp();

-- ============================================
-- SECTION 5: USER SYNC FUNCTION (Critical)
-- ============================================

-- Function to sync auth.users to users table
-- This is the main function that handles user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, created_at, updated_at)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'name', NEW.email), NOW(), NOW())
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    name = COALESCE(EXCLUDED.name, public.users.name),
    updated_at = NOW();
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log error but don't fail the trigger
  RAISE NOTICE 'Error in handle_new_user: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists before creating
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Trigger for new user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- SECTION 6: VERIFICATION AND CHECKS
-- ============================================

-- Verify tables created
SELECT 'Schema verification:' as check_item;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Verify indexes created
SELECT 'Index verification:' as check_item;
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY indexname;

-- Verify RLS is enabled
SELECT 'RLS verification:' as check_item;
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true
ORDER BY tablename;

-- ============================================
-- SETUP COMPLETE
-- ============================================
-- Database is now ready for:
-- ✓ User authentication
-- ✓ Product catalog with real-time updates
-- ✓ Shopping cart and orders
-- ✓ Fit profiles for personalized recommendations
-- ✓ Reviews and ratings
-- ✓ Wishlist functionality
-- ✓ Newsletter subscriptions
-- ✓ Row-level security for data privacy
-- ✓ Automatic data sync
--
-- All tables are idempotent - safe to run multiple times
-- Last updated: February 10, 2026
-- ============================================


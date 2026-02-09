# Supabase Database Setup

This directory contains the database schema and migration files for Grazel Apparel.

## Files

- **schema.sql** - Complete database schema with all tables, indexes, and RLS policies
- **migrations.sql** - Migration script to add new columns to existing database

## How to Set Up

### Option 1: Fresh Supabase Project (Recommended)

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to your project
3. Go to **SQL Editor**
4. Click **New Query**
5. Copy the entire contents of `schema.sql`
6. Paste into the SQL editor
7. Click **Run**

This will create all tables, indexes, and security policies from scratch.

### Option 2: Existing Project with Products Table

If you already have a products table without the new fields:

1. Go to **SQL Editor** in Supabase
2. Click **New Query**
3. Copy the contents of `migrations.sql`
4. Paste into the SQL editor
5. Click **Run**

This will add the missing columns to your existing products table:
- `gender` - Product gender (Men, Women, Unisex)
- `is_essential` - Flag for essential products
- `offer_percentage` - Discount percentage

## Database Tables

1. **users** - User profiles (extends Supabase auth)
2. **user_addresses** - Shipping and billing addresses
3. **products** - Product catalog with gender, essentials, and offers
4. **orders** - Order records
5. **order_items** - Order line items
6. **cart_items** - Shopping cart
7. **fit_profiles** - Fit preferences
8. **wishlist_items** - Wishlist
9. **reviews** - Product reviews
10. **newsletter_subscribers** - Email subscribers

## Product Fields

- **gender**: TEXT - 'Men', 'Women', or 'Unisex'
- **is_essential**: BOOLEAN - Flag for essential products (default: false)
- **offer_percentage**: DECIMAL - Discount percentage (default: 0)

## Environment Variables

Make sure your `.env.local` file has:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

Get these from your Supabase project settings.

## Troubleshooting

### Error: "column does not exist"

Run the migrations.sql script to add missing columns:

```sql
ALTER TABLE products
ADD COLUMN IF NOT EXISTS gender TEXT,
ADD COLUMN IF NOT EXISTS is_essential BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS offer_percentage DECIMAL(5, 2) DEFAULT 0;
```

### RLS Policy Issues

If you get permission errors, make sure:
1. RLS is enabled on the table
2. Appropriate policies are in place
3. Run the full schema.sql to reset policies

### Connection Issues

If you get SSL certificate errors in development:
- The app has fallback to mock data
- Check your Supabase credentials in `.env.local`
- Ensure your project is not restricted by IP

## Support

For Supabase documentation: https://supabase.com/docs

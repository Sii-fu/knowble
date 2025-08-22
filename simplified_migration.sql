-- Simplified migration script for admin course management
-- Run this SQL on your Supabase database

-- The courses table already has the is_verified column based on your schema
-- This migration ensures it exists and has the correct constraints

-- Ensure is_verified column exists (should already exist from your screenshot)
-- NULL = pending approval, TRUE = approved, FALSE = rejected
-- ALTER TABLE courses ADD COLUMN IF NOT EXISTS is_verified BOOLEAN;

-- Create index for better performance when filtering by verification status
CREATE INDEX IF NOT EXISTS idx_courses_is_verified ON courses(is_verified);

-- Optional: If you want to add a basic course categories for filtering
-- ALTER TABLE courses ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'General';
-- CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);

-- The existing columns from your schema that are used:
-- - id (uuid, primary key)
-- - instructor_id (uuid, foreign key to users)
-- - title (text)
-- - description (text) 
-- - price (numeric)
-- - is_paid (boolean)
-- - duration_days (integer)
-- - created_at (timestamp)
-- - banner (text)
-- - is_verified (boolean) - This is the key column for admin approval

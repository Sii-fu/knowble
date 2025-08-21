-- Migration script to add required columns for admin course management
-- Run this SQL on your Supabase database

-- Add status column to courses table if it doesn't exist
ALTER TABLE courses ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending';

-- Add category column to courses table if it doesn't exist  
ALTER TABLE courses ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'General';

-- Add rating column to courses table if it doesn't exist
ALTER TABLE courses ADD COLUMN IF NOT EXISTS rating DECIMAL(3,2) DEFAULT 0.0;

-- Add review fields to courses table if they don't exist
ALTER TABLE courses ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS review_reason TEXT;

-- Add estimated_duration column to sections table if it doesn't exist
ALTER TABLE sections ADD COLUMN IF NOT EXISTS estimated_duration INTEGER DEFAULT 30;

-- Add order column to contents table if it doesn't exist
ALTER TABLE contents ADD COLUMN IF NOT EXISTS "order" INTEGER DEFAULT 1;

-- Create course_reports table if it doesn't exist
CREATE TABLE IF NOT EXISTS course_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Create admin_actions table for audit trail if it doesn't exist
CREATE TABLE IF NOT EXISTS admin_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_courses_status ON courses(status);
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX IF NOT EXISTS idx_course_reports_course_id ON course_reports(course_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_course_id ON admin_actions(course_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_admin_id ON admin_actions(admin_id);

-- Update existing courses to have a default status if NULL
UPDATE courses SET status = 'approved' WHERE status IS NULL;

-- Add some sample data constraints
ALTER TABLE courses ADD CONSTRAINT IF NOT EXISTS chk_status 
    CHECK (status IN ('pending', 'approved', 'rejected', 'flagged'));

ALTER TABLE courses ADD CONSTRAINT IF NOT EXISTS chk_rating 
    CHECK (rating >= 0.0 AND rating <= 5.0);

-- Ensure banner column exists (it should from the Course model)
ALTER TABLE courses ADD COLUMN IF NOT EXISTS banner TEXT DEFAULT '';

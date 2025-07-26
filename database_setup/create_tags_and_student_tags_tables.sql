-- SQL queries for creating tags and student_tags tables in Supabase

-- 1. Create tags table (if not already exists)
CREATE TABLE IF NOT EXISTS tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    description TEXT
);

-- 2. Create student_tags table for student-tag relationships
CREATE TABLE IF NOT EXISTS student_tags (
    student_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    PRIMARY KEY (student_id, tag_id),
    FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- 3. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_student_tags_student_id ON student_tags(student_id);
CREATE INDEX IF NOT EXISTS idx_student_tags_tag_id ON student_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_tags_category ON tags(category);

-- 4. Insert sample tags (based on your existing availableInterests)
INSERT INTO tags (name, category) VALUES 
    ('Mathematics', 'STEM'),
    ('Computer Science', 'Technology'),
    ('Physics', 'STEM'),
    ('Chemistry', 'STEM'),
    ('Biology', 'STEM'),
    ('English Literature', 'Language Arts'),
    ('Creative Writing', 'Language Arts'),
    ('History', 'Social Studies'),
    ('Geography', 'Social Studies'),
    ('Psychology', 'Social Studies'),
    ('Art & Design', 'Creative Arts'),
    ('Music Theory', 'Creative Arts'),
    ('Photography', 'Creative Arts'),
    ('Business Studies', 'Business'),
    ('Economics', 'Business'),
    ('Marketing', 'Business'),
    ('Philosophy', 'Humanities'),
    ('Sociology', 'Social Studies'),
    ('Environmental Science', 'STEM'),
    ('Foreign Languages', 'Language Arts'),
    ('Statistics', 'STEM'),
    ('Data Science', 'Technology'),
    ('Web Development', 'Technology'),
    ('Graphic Design', 'Creative Arts')
ON CONFLICT (name) DO NOTHING;

-- 5. Enable Row Level Security (RLS)
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_tags ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS policies for tags table (public read access)
CREATE POLICY "Anyone can view tags" ON tags
    FOR SELECT USING (true);

-- 7. Create RLS policies for student_tags table
CREATE POLICY "Users can view their own interests" ON student_tags
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own interests" ON student_tags
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own interests" ON student_tags
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete their own interests" ON student_tags
    FOR DELETE USING (true);

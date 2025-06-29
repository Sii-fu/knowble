.//SIGNUP ROUTE
app.post('/api/auth/signup', async (req, res) => {
  const { email, password, fullName, role } = req.body;

  if (!email || !password || !fullName || !role) {
    return res.status(400).json({ error: "All fields are required" });
  }
  const { data: authUser, error: signupError } = await supabase.auth.signUp({
    email,
    password
  });

  if (signupError) {
    return res.status(400).json({ error: signupError.message });
  }

  const userId = authUser.user.id;
  const { error: insertError } = await supabase.from('users').insert([
    {
      id: userId,
      full_name: fullName,
      role: role
    }
  ]);

  if (insertError) {
    return res.status(500).json({ error: "Failed to save user metadata" });
  }

  res.status(201).json({ message: "User registered successfully", userId });
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email and password required" });
  }
  const { data: authData, error: signInError } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (signInError) {
    return res.status(401).json({ error: "Invalid email or password" });
  }
  const userId = authData.user.id;
  const { data: userProfile, error: profileError } = await supabase
    .from('users')
    .select('full_name, role')
    .eq('id', userId)
    .single();

  if (profileError) {
    return res.status(500).json({ error: "Failed to fetch user profile" });
  }
  res.json({
    message: "Login successful",
    user: {
      id: userId,
      email: authData.user.email,
      fullName: userProfile.full_name,
      role: userProfile.role
    },
    session: authData.session 
});
})
//STUDENT

app.get('/api/dashboard/student', async (req, res) => {
  const userId = req.user.id; 
  const { data: user, error } = await supabase.from('users').select('role').eq('id', userId).single();
  if (error || user.role !== 'student') {
    return res.status(403).json({ error: 'Unauthorized' });
  }
const { data: courses } = await supabase.from('enrollments').select('course_id, progress, ...').eq('user_id', userId);
const { data: reminders } = await supabase.from('reminders').select('*').eq('user_id', userId);

  res.json({ courses, reminders });
});


app.get('/api/courses', async (req, res) => {
  try {
    const { data: courses, error } = await supabase
      .from('courses')
      .select(`
        id,
        title,
        description,
        price,
        course_tags:course_id(
            tags:tag_id(
              name
            )
          ),
        is_paid,
        duration_days,
        instructor:instructor_id (
          id,
          full_name
        )
      `)
      

    if (error) {
      return res.status(500).json({ error: "Failed to fetch courses" });
    }

    res.json({ courses });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/courses/search', async (req, res) => {
  const query = req.query.q?.toLowerCase();

  if (!query) {
    return res.status(400).json({ error: "Search query (q) is required" });
  }

  try {
    const { data: courses, error } = await supabase
      .from('courses')
      .select(`
        id,
        title,
        description,
        price,
        course_tags:course_id(
            tags:tag_id(
              name
            )
          ),
        duration,
        instructor:instructor_id (
          id,
          full_name
        )
      `)
      .or(`title.ilike.%${query}%,description.ilike.%${query}%,tags.cs.{${query}}`);

    if (error) {
      return res.status(500).json({ error: "Failed to search courses" });
    }

    res.json({ courses });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/courses/:courseId', async (req, res) => {
  const { courseId } = req.params;

  try {
   
    const { data: course, error: courseError } = await supabase
      .from('courses')
      .select(`
        id,
        title,
        description,
        price,
        is_paid,
        course_tags:course_id(
            tags:tag_id(
              name
            )
          ),
        duration_days,
        is_published,
        instructor:instructor_id (
          id,
          full_name
        )
      `)
      .eq('id', courseId)
      .single();

    if (courseError || !course) {
      return res.status(404).json({ error: 'Course not found' });
    }
    const { data: modules, error: modulesError } = await supabase
      .from('modules')
      .select(`
        id,
        title,
        "order",
        sections:sections (
          id,
          title,
          description,
          "order"
        )
      `)
      .eq('course_id', courseId)
      .order('order', { ascending: true });

    if (modulesError) {
      return res.status(500).json({ error: 'Failed to fetch modules' });
    }
    course.modules = modules || [];

     res.json({ course });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/courses/:courseId/enroll', async (req, res) => {
  const { courseId } = req.params;
  const userId = req.user.id;  

  if (!userId) {
    return res.status(401).json({ error: 'Unauthorized: login required' });
  }

  try {
    
    const { data: existingEnrollment, error: checkError } = await supabase
      .from('enrollments')
      .select('*')
      .eq('user_id', userId)
      .eq('course_id', courseId)
      .single();

    if (checkError && checkError.code !== 'PGRST116') {
      // PGRST116 = no rows found (safe to ignore)
      return res.status(500).json({ error: 'Error checking enrollment' });
    }

    if (existingEnrollment) {
      return res.status(400).json({ error: 'User already enrolled in this course' });
    }
    const { data: enrollment, error: insertError } = await supabase
      .from('enrollments')
      .insert([
        {
          user_id: userId,
          course_id: courseId,
          progress: 0,
          enrolled_at: new Date().toISOString(),
        }
      ])
      .single();

    if (insertError) {
      return res.status(500).json({ error: 'Failed to enroll user' });
    }

    res.status(201).json({ message: 'Enrollment successful', enrollment });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/enrollments', async (req, res) => {
  const userId = req.user.id; 

  if (!userId) {
    return res.status(401).json({ error: 'Unauthorized: login required' });
  }

  try {
    
    const { data: enrollments, error } = await supabase
      .from('enrollments')
      .select(`
        progress,
        enrolled_at,
        course:course_id (
          id,
          title,
          description,
          price,
          is_paid
          course_tags:course_id(
            tags:tag_id(
              name
            )
          ),
          duration_days,
          is_published,
          instructor:instructor_id (
            id,
            full_name
          )
        )
      `)
      .eq('user_id', userId);

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch enrollments' });
    }

    res.json({ enrollments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/courses/:courseId/modules', async (req, res) => {
  const { courseId } = req.params;

  try {
    const { data: modules, error } = await supabase
      .from('modules')
      .select(`
        id,
        title,
        "order",
        sections:sections (
          id,
          title,
          description,
          "order"
        )
      `)
      .eq('course_id', courseId)
      .order('order', { ascending: true })
      .order('sections.order', { ascending: true });

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch modules' });
    }

    res.json({ modules });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/modules/:moduleId/sections', async (req, res) => {
  const { moduleId } = req.params;

  try {
    const { data: sections, error } = await supabase
      .from('sections')
      .select('id, title, description, "order"')
      .eq('module_id', moduleId)
      .order('order', { ascending: true });

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch sections' });
    }

    res.json({ sections });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/reminders/student', async (req, res) => {
  const { title, time, course_id } = req.body;
  const userId = req.user.id; 

  if (!userId || !title || !time) {
    return res.status(400).json({ error: 'title and time are required' });
  }

  try {
    const { data, error } = await supabase
      .from('reminders')
      .insert([
        {
          user_id: userId,
          title,
          time,
          course_id: course_id || null,
          created_at: new Date().toISOString()
        }
      ])
      .single();

    if (error) {
      return res.status(500).json({ error: 'Failed to create reminder' });
    }

    res.status(201).json({ message: 'Reminder created successfully', reminder: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Instructor Verification
app.post('/api/instructor/verify', async (req, res) => {
  // Get user_id and certificate details from req.body
  // Insert into 'certificates' table: student_id, course_id (optional), certificate_url, issued_at, cert_number,status='pending'
});

app.get('/api/instructor/verification-status', async (req, res) => {
  // Get user_id from auth/session
  // Fetch 'is_verified' boolean from 'users' table where id = user_id
  // Return is_verified to indicate instructor verification status
});

// Course Creation
//course get is done 
app.post('/api/courses', async (req, res) => {
  // Get course info from req.body: title, description, price, duration_days, is_paid
  // Get instructor_id from session(loggen in user auth.)
  // Insert into 'courses' table
});

app.get('/api/courses/instructor', async (req, res) => {
  // Get instructor_id from session
  // Query 'courses' table where instructor_id = current user
});

app.put('/api/courses/:courseId', async (req, res) => {
  // Update fields in 'courses' table by courseId (from params) using body
});

app.delete('/api/courses/:courseId', async (req, res) => {
  // Delete from 'courses' table where id = courseId
});

// Modular Course Structure
//module insertion(module get is done)
app.post('/api/courses/:courseId/modules', async (req, res) => {
  // Insert module into 'modules' table using courseId and module title, order
});

app.put('/api/modules/:moduleId', async (req, res) => {
  // Update title/order in 'modules' table by moduleId(where id=moduleId)
});

app.delete('/api/modules/:moduleId', async (req, res) => {
  // Delete row from 'modules' table using moduleId
});

app.post('/api/modules/:moduleId/sections', async (req, res) => {
  // Insert into 'sections' table using moduleId, title, description, order where id=module_id
});

app.put('/api/sections/:sectionId', async (req, res) => {
  // Update section info in 'sections' table where id=sectionId
});

app.delete('/api/sections/:sectionId', async (req, res) => {
  // Delete section from 'sections' table where id = sectionId
});

// Instructor Dashboard
app.get('/api/dashboard/instructor', async (req, res) => {
  // Get instructor_id from session(logged in user auth.)
  // collect data from 'courses' and 'enrollments' where instructor_id matches
});

app.get('/api/courses/:courseId/students', async (req, res) => {
  // Join 'enrollments' and 'users' tables where course_id = courseId
});

app.get('/api/courses/:courseId/progress', async (req, res) => {
  // Fetch progress from 'enrollments' table where course_id = courseId
});

// Chat System
app.get('/api/chat/instructor/:courseId', async (req, res) => {
  // Get messages from 'chats' table where course_id = courseId
});

app.post('/api/chat/instructor/:courseId', async (req, res) => {
  // Insert new chat message in 'chats' table: course_id, sender_id, receiver_id, message
});

// Instructor Reminders
app.post('/api/reminders/instructor', async (req, res) => {
  // Insert into 'reminders' table with user_id (instructor), course_id, title, time, created_by = 'instructor'
});

app.get('/api/reminders/instructor/:courseId', async (req, res) => {
  // Get from 'reminders' table where course_id = courseId and created_by = 'instructor'
});

// Student APIs


app.get('/api/reminders/student', async (req, res) => {
  // Get personal + instructor-created reminders for student
});

app.get('/api/chat/student/:courseId', async (req, res) => {
  // Get chat messages between student and instructor wher course_id= courseId from 'chats'
});

app.post('/api/chat/student/:courseId', async (req, res) => {
  // Insert new message in 'chats' table from student to instructor
});

app.post('/api/llm/query', async (req, res) => {
  // Forward question + context to Gemini LLM API and return answer
});

// Admin APIs
app.get('/api/admin/instructor-verifications', async (req, res) => {
  // Fetch unverified instructors from 'users' table where is_verified = false
});

app.post('/api/admin/instructor/:id/approve', async (req, res) => {
  // Update 'users' table: set is_verified = true where id = :id
});

app.post('/api/admin/instructor/:id/reject', async (req, res) => {
  //  Remove certificate or just set is_verified = false
});

app.get('/api/admin/courses', async (req, res) => {
  // Get all courses needing moderation from 'courses' table (e.g. is_paid = false)
});


app.delete('/api/admin/courses/:id', async (req, res) => {
  // Delete course and its linked modules, sections
});

// Assessment System
app.post('/api/modules/:moduleId/quiz', async (req, res) => {
  // Insert new quiz into 'assessments' and related 'questions', 'options'
});

app.get('/api/sections/:sectionId/quiz', async (req, res) => {
  // Fetch quiz data from 'assessments' after 'questions' lastly 'options' linked to sectionId
});

app.post('/api/sections/:sectionId/submit', async (req, res) => {
  // Store responses in 'submissions' table and calculate score
});

app.get('/api/grades/:courseId', async (req, res) => {
  // Fetch student scores(marks_awarded) from 'submissions' table filtered by courseId
});

// Progress
app.get('/api/progress/:courseId', async (req, res) => {
  // Calculate progress from 'enrollments' progress field where course_id = courseId
});

// Uploads
app.post('/api/upload', async (req, res) => {
  // Generate Supabase signed URL and return
});

// Schedule
app.get('/api/courses/:id/schedule', async (req, res) => {
  // Get modules + sections for course and return in order as schedule
});

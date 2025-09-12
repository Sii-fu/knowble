-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.activities (
  id uuid NOT NULL,
  user_id uuid,
  text text NOT NULL,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT activities_pkey PRIMARY KEY (id),
  CONSTRAINT activities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.ai_chat_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  content_id uuid NOT NULL,
  question text NOT NULL,
  answer text NOT NULL,
  timestamp timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT ai_chat_history_pkey PRIMARY KEY (id),
  CONSTRAINT ai_chat_history_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(id),
  CONSTRAINT ai_chat_history_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id)
);
CREATE TABLE public.assessments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text,
  type character varying,
  total_marks integer,
  section_id uuid,
  CONSTRAINT assessments_pkey PRIMARY KEY (id),
  CONSTRAINT assessments_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id)
);
CREATE TABLE public.certificates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid,
  course_id uuid,
  issued_at timestamp without time zone,
  certificate_url text,
  cert_number text UNIQUE,
  status character varying,
  CONSTRAINT certificates_pkey PRIMARY KEY (id),
  CONSTRAINT certificates_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id),
  CONSTRAINT certificates_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.chats (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid,
  sender_id uuid,
  receiver_id uuid,
  message text,
  timestamp timestamp without time zone,
  CONSTRAINT chats_pkey PRIMARY KEY (id),
  CONSTRAINT chats_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id),
  CONSTRAINT chats_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id),
  CONSTRAINT chats_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.contents (
  id uuid NOT NULL,
  section_id uuid,
  type character varying,
  title text,
  url text,
  order integer,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contents_pkey PRIMARY KEY (id),
  CONSTRAINT contents_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id)
);
CREATE TABLE public.course_reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid,
  student_id uuid,
  rating integer,
  review_text text,
  created_at timestamp without time zone,
  is_visible boolean,
  CONSTRAINT course_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT course_reviews_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id),
  CONSTRAINT course_reviews_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.course_tags (
  course_id uuid NOT NULL,
  tag_id uuid NOT NULL,
  primary boolean,
  note text,
  CONSTRAINT course_tags_pkey PRIMARY KEY (course_id, tag_id),
  CONSTRAINT course_tags_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id),
  CONSTRAINT course_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);
CREATE TABLE public.courses (
  id uuid NOT NULL,
  instructor_id uuid,
  title text,
  description text,
  price numeric,
  is_paid boolean,
  duration_days integer,
  created_at timestamp without time zone,
  banner text DEFAULT 'https://picsum.photos/1000/600'::text,
  is_verified boolean,
  CONSTRAINT courses_pkey PRIMARY KEY (id),
  CONSTRAINT courses_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.users(id)
);
CREATE TABLE public.enrollments (
  id uuid NOT NULL,
  student_id uuid,
  course_id uuid,
  enrolled_at timestamp without time zone,
  progress double precision,
  CONSTRAINT enrollments_pkey PRIMARY KEY (id),
  CONSTRAINT enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id),
  CONSTRAINT enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id)
);
CREATE TABLE public.feedback_issues (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  user_role text,
  type text NOT NULL,
  category text,
  message text NOT NULL,
  status text DEFAULT 'pending'::text,
  submitted_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  admin_notes text,
  CONSTRAINT feedback_issues_pkey PRIMARY KEY (id),
  CONSTRAINT feedback_issues_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.instructor_info (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  phone_number character varying NOT NULL,
  education_degree character varying NOT NULL,
  teaching_experience integer NOT NULL CHECK (teaching_experience >= 0 AND teaching_experience <= 50),
  current_location text,
  subject_expertise ARRAY NOT NULL,
  bio text NOT NULL CHECK (char_length(bio) >= 50),
  cv_file_name text NOT NULL,
  cv_file_path text NOT NULL,
  verification_status character varying DEFAULT 'pending'::character varying CHECK (verification_status::text = ANY (ARRAY['pending'::character varying, 'under_review'::character varying, 'verified'::character varying, 'rejected'::character varying]::text[])),
  submitted_at timestamp with time zone DEFAULT now(),
  verified_at timestamp with time zone,
  CONSTRAINT instructor_info_pkey PRIMARY KEY (id),
  CONSTRAINT instructor_info_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.modules (
  id uuid NOT NULL,
  course_id uuid,
  title text,
  order integer,
  CONSTRAINT modules_pkey PRIMARY KEY (id),
  CONSTRAINT modules_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.notification (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL UNIQUE,
  user_id uuid NOT NULL DEFAULT auth.uid(),
  title text DEFAULT ''::text,
  description text,
  priority text,
  alert_time timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  navigate text,
  is_read boolean,
  type text DEFAULT 'general'::text,
  CONSTRAINT notification_pkey PRIMARY KEY (id),
  CONSTRAINT notification_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  question_id uuid,
  option_text text,
  is_correct boolean,
  order integer,
  CONSTRAINT options_pkey PRIMARY KEY (id),
  CONSTRAINT options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id)
);
CREATE TABLE public.questions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  assessment_id uuid,
  question_text text,
  type character varying,
  marks integer,
  CONSTRAINT questions_pkey PRIMARY KEY (id),
  CONSTRAINT questions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id)
);
CREATE TABLE public.quiz_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  assessment_id uuid NOT NULL,
  section_id uuid NOT NULL,
  status text NOT NULL CHECK (status = ANY (ARRAY['pass'::text, 'fail'::text])),
  score integer NOT NULL,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quiz_results_pkey PRIMARY KEY (id),
  CONSTRAINT quiz_results_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id),
  CONSTRAINT quiz_results_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id),
  CONSTRAINT quiz_results_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id)
);
CREATE TABLE public.reminders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  course_id uuid,
  title text,
  time timestamp with time zone,
  created_by character varying,
  description text,
  end_time timestamp with time zone,
  priority text NOT NULL,
  CONSTRAINT reminders_pkey PRIMARY KEY (id),
  CONSTRAINT reminders_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id),
  CONSTRAINT reminders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.sections (
  id uuid NOT NULL,
  module_id uuid,
  title text,
  description text,
  order integer,
  CONSTRAINT sections_pkey PRIMARY KEY (id),
  CONSTRAINT sections_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id)
);
CREATE TABLE public.student_tags (
  student_id uuid NOT NULL,
  tag_id uuid NOT NULL,
  CONSTRAINT student_tags_pkey PRIMARY KEY (student_id, tag_id),
  CONSTRAINT student_tags_student_id_fkey FOREIGN KEY (student_id) REFERENCES auth.users(id),
  CONSTRAINT student_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);
CREATE TABLE public.submissions (
  id uuid NOT NULL,
  student_id uuid,
  question_id uuid,
  selected_option_ids ARRAY,
  is_correct boolean,
  marks_awarded integer,
  CONSTRAINT submissions_pkey PRIMARY KEY (id),
  CONSTRAINT submissions_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id),
  CONSTRAINT submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id)
);
CREATE TABLE public.tags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  description text,
  CONSTRAINT tags_pkey PRIMARY KEY (id)
);
CREATE TABLE public.users (
  id uuid NOT NULL,
  name text,
  email text UNIQUE,
  role character varying,
  profile_pic text,
  bio text,
  is_verified boolean,
  created_at timestamp without time zone,
  user_documents text,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
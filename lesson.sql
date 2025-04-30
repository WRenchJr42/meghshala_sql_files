-- Trigger function: auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function: pull in all the “fetch_from chapter…” fields
CREATE OR REPLACE FUNCTION public.lesson_populate_chapter_fields()
RETURNS TRIGGER AS $$
DECLARE
  ch  RECORD;
BEGIN
  SELECT
    chapter_name,
    chapter_number,
    chapter_id AS chap_id,
    language,
    curriculum,
    grade_number AS grade,
    semester_number AS semester,
    subject,
    subtype,
    color
  INTO ch
  FROM public.chapter
  WHERE id = NEW.chapter;
  IF FOUND THEN
    NEW.chapter_name   := ch.chapter_name;
    NEW.chapter_number := ch.chapter_number;
    NEW.chapter_id     := ch.chap_id;
    NEW.language       := ch.language;
    NEW.curriculum     := ch.curriculum;
    NEW.grade          := ch.grade;
    NEW.semester       := ch.semester;
    NEW.subject        := ch.subject;
    NEW.subtype        := ch.subtype;
    NEW.color          := ch.color;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- lesson table
CREATE TABLE public.lesson (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter uuid NOT NULL REFERENCES public.chapter(id) ON DELETE RESTRICT,
  chapter_name text NOT NULL, -- fetch_from chapter.chapter_name
  chapter_number integer NOT NULL,-- fetch_from chapter.chapter_number
  chapter_id text NOT NULL, -- fetch_from chapter.chapter_id
  
  lesson_name text NOT NULL,
  lesson_number integer NOT NULL,
  lesson_id text NOT NULL UNIQUE,
  
  is_published boolean NOT NULL DEFAULT FALSE,
  is_broken boolean NOT NULL DEFAULT FALSE,
  
  google_slides_link text,
  google_slides_id text,
  
  normal_pdf text,-- path or URL
  encrypted_pdf text,-- path or URL
  
  password text,
  
  tags text,
  slide_order text,
  
  -- Redundant snapshot fields (fetched from chapter)
  language text NOT NULL,
  curriculum text NOT NULL,
  grade text NOT NULL,
  semester text NOT NULL,
  subject text NOT NULL,
  subtype text,
  color text NOT NULL,
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: populate chapter fields BEFORE INSERT OR UPDATE
CREATE TRIGGER lesson_populate_chapter
  BEFORE INSERT OR UPDATE ON public.lesson
  FOR EACH ROW
  EXECUTE FUNCTION public.lesson_populate_chapter_fields();

-- Trigger: auto-update updated_at BEFORE UPDATE
CREATE TRIGGER lesson_set_updated_at
  BEFORE UPDATE ON public.lesson
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

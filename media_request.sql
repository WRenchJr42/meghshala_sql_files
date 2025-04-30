-- Sequence for the autoname suffix (##)
CREATE  SEQUENCE public.media_request_seq
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

-- Trigger function to auto‐update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to pull in fetch_from lesson fields and generate
--    name = 'MR-' || lesson_id || lpad(seq::text, 2, '0')
CREATE OR REPLACE FUNCTION public.media_request_before_insert()
RETURNS TRIGGER AS $$
DECLARE
  ln RECORD;
BEGIN
  -- populate all the fetch_from columns from the lesson row
  SELECT
    lesson_id,
    lesson_name,
    lesson_number,
    chapter_name,
    chapter_number,
    language,
    curriculum,
    grade,
    semester
  INTO ln
  FROM public.lesson
  WHERE id = NEW.lesson;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lesson % not found', NEW.lesson;
  END IF;

  NEW.lesson_id      := ln.lesson_id;
  NEW.lesson_name    := ln.lesson_name;
  NEW.lesson_number  := ln.lesson_number;
  NEW.chapter_name   := ln.chapter_name;
  NEW.chapter_number := ln.chapter_number;
  NEW.language       := ln.language;
  NEW.curriculum     := ln.curriculum;
  NEW.grade          := ln.grade;
  NEW.semester       := ln.semester;

  -- assign seq if not set (will pull nextval)
  IF NEW.seq IS NULL THEN
    NEW.seq := nextval('public.media_request_seq');
  END IF;

  -- build the autoname
  NEW.name := format('MR-%s%02s', NEW.lesson_id, NEW.seq);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- media_request table
CREATE TABLE public.media_request (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- autoname field
  name text NOT NULL UNIQUE,

  lesson uuid NOT NULL REFERENCES public.lesson(id) ON DELETE RESTRICT,
  lesson_id text NOT NULL,  -- fetched from lesson.lesson_id
  lesson_name text NOT NULL,
  lesson_number integer NOT NULL,

  chapter_name text NOT NULL,
  chapter_number integer NOT NULL,

  requested_by uuid NOT NULL REFERENCES auth.users(id),
  request_date  date,

  completed_by uuid REFERENCES auth.users(id),
  completion_date date,

  status public.media_request_status NOT NULL DEFAULT 'NEW',
  requirement text,

  language text NOT NULL,
  curriculum text NOT NULL,
  grade text NOT NULL,
  semester text NOT NULL,

  -- internal sequence for autoname suffix
  seq integer NOT NULL,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: pull in lesson fields & set name/seq BEFORE INSERT
CREATE TRIGGER media_request_before_insert_tr
  BEFORE INSERT ON public.media_request
  FOR EACH ROW
  EXECUTE FUNCTION public.media_request_before_insert();

-- Trigger: auto-update updated_at BEFORE UPDATE
CREATE TRIGGER media_request_set_updated_at
  BEFORE UPDATE ON public.media_request
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

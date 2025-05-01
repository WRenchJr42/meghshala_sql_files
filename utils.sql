---------------------------------------------------------------------------------------------------------
-- generic
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-set created_by and updated_by using auth.uid()
CREATE OR REPLACE FUNCTION public.set_user_ids()
RETURNS TRIGGER AS $$
BEGIN
  -- Set created_by only on INSERT
  IF TG_OP = 'INSERT' AND NEW.created_by IS NULL THEN
    NEW.created_by := auth.uid();
  END IF;

  -- Set updated_by on INSERT and UPDATE
  NEW.updated_by := auth.uid();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------
--public.chapter_lessons
---------------------------------------------------------------------------------------------------------
-- Trigger function to populate lesson_number & lesson_name from the lesson table
CREATE OR REPLACE FUNCTION public.chapter_lesson_populate_details()
RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN
  -- Assume there is a "lesson" table with columns: id, lesson_number, lesson_name
  SELECT lesson_number, lesson_name
    INTO rec
    FROM public.lesson
   WHERE id = NEW.lesson;
  IF FOUND THEN
    NEW.lesson_number := rec.lesson_number;
    NEW.lesson_name := rec.lesson_name;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------------------------------------------
--public.media_links
---------------------------------------------------------------------------------------------------------
-- Trigger function to populate title, image, and video from the media table
CREATE OR REPLACE FUNCTION public.media_link_populate_details()
RETURNS TRIGGER AS $$
DECLARE
  m RECORD;
BEGIN
  SELECT title, image, video
    INTO m
    FROM public.media
   WHERE id = NEW.media;
  IF FOUND THEN
    NEW.title := m.title;
    NEW.image := m.image;
    NEW.video := m.video;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------
--public.media_links
---------------------------------------------------------------------------------------------------------
-- Trigger function to populate media_title from the media table
CREATE OR REPLACE FUNCTION public.media_request_slide_populate_media_title()
RETURNS TRIGGER AS $$
DECLARE
  m_rec RECORD;
BEGIN
  SELECT title
    INTO m_rec
    FROM public.media
   WHERE id = NEW.media;
  IF FOUND THEN
    NEW.media_title := m_rec.title;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------
--public.media_requests
---------------------------------------------------------------------------------------------------------
-- Sequence for the autoname suffix (##)
--CREATE  SEQUENCE public.media_request_seq
--  START WITH 1
--  INCREMENT BY 1
--  NO MINVALUE
--  NO MAXVALUE
--  CACHE 1;

---------------------------------------------------------------------------------------------------------
--public.semesters
---------------------------------------------------------------------------------------------------------
  -- Trigger function to set the 'name' field
CREATE OR REPLACE FUNCTION public.semester_set_name()
RETURNS TRIGGER AS $$
BEGIN
  NEW.name := 'S' || NEW.number::text;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------
--public.web_usage
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_created_and_updated_metadata()
RETURNS TRIGGER AS $$
DECLARE
  v_uid uuid := 'ADMINISTRATOR';
BEGIN
  BEGIN
    v_uid := auth.uid();  -- Supabase helper
  EXCEPTION WHEN OTHERS THEN
    -- Keep default ADMINISTRATOR
  END;

  IF TG_OP = 'INSERT' THEN
    IF NEW.created_by IS NULL THEN
      NEW.created_by := v_uid;
    END IF;
    IF NEW.created_at IS NULL THEN
      NEW.created_at := now();
    END IF;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    NEW.updated_at := now();
    NEW.updated_by := v_uid;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger function to keep updated_at in sync (idempotent)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- chapter_lesson table (child of chapter)
CREATE TABLE public.chapter_lesson (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id uuid NOT NULL REFERENCES public.chapter(id) ON DELETE CASCADE,
  lesson uuid NOT NULL REFERENCES public.lesson(id),
  lesson_number text NOT NULL,
  lesson_name text NOT NULL,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: populate lesson_number & lesson_name on INSERT or UPDATE
CREATE TRIGGER chapter_lesson_populate
  BEFORE INSERT OR UPDATE ON public.chapter_lesson
  FOR EACH ROW
  EXECUTE FUNCTION public.chapter_lesson_populate_details();

-- 5) Trigger: auto-update updated_at on any UPDATE
CREATE TRIGGER chapter_lesson_set_updated_at
  BEFORE UPDATE ON public.chapter_lesson
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

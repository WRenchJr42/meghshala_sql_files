-- Trigger function to auto-update updated_at (if you haven’t already created it)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- lesson_feedback table
CREATE TABLE public.lesson_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson uuid NOT NULL REFERENCES public.lesson(id),
  "user" uuid NOT NULL REFERENCES auth.users(id),
  
  could_complete boolean NOT NULL DEFAULT FALSE,
  liked_teacher_instructions boolean NOT NULL DEFAULT FALSE,
  liked_concept_explanations boolean NOT NULL DEFAULT FALSE,
  liked_activities boolean NOT NULL DEFAULT FALSE,
  liked_language_simplicity boolean NOT NULL DEFAULT FALSE,
  liked_practice_questions boolean NOT NULL DEFAULT FALSE,
  will_recommend boolean NOT NULL DEFAULT FALSE,
  
  feedback_note text,
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 

);

-- Trigger to auto-update updated_at on any UPDATE
CREATE TRIGGER lesson_feedback_set_updated_at
  BEFORE UPDATE ON public.lesson_feedback
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

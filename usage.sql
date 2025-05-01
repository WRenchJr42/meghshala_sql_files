
CREATE TABLE public.usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id uuid references auth.users(id),

  lesson_id uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,

  seconds integer NOT NULL,
  page_id text NOT NULL,
  mode modes NOT NULL,
  language_id uuid REFERENCES public.languages(id),
  curriculum_id uuid REFERENCES public.curricula(id),
  grade_id uuid REFERENCES public.grades(id),
  semester_id uuid REFERENCES public.semesters(id),
  subject_id uuid REFERENCES public.subjects(id),
  chapter_id uuid REFERENCES public.chapters(id),

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger for INSERT (for created_by)
CREATE TRIGGER usage_set_user_ids_insert
  BEFORE INSERT ON public.usage
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_by)
CREATE TRIGGER usage_set_user_ids_update
  BEFORE UPDATE ON public.usage
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_at)
CREATE TRIGGER usage_set_updated_at
  BEFORE UPDATE ON public.usage
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  user_id uuid references auth.users(id),

  lesson uuid NOT NULL REFERENCES public.lesson(id) ON DELETE CASCADE,

  seconds integer NOT NULL,
  page_id text NOT NULL,
  mode modes NOT NULL,
  
  -- Auto-fetched fields (read-only, denormalized copies)
  phone text,
  first_name text,
  last_name text,
  school text,
  dise text,
  state text,
  district text,
  pincode text,

  language text,
  curriculum text,
  grade text,
  semester text,
  subject text,

  chapter_number text,
  chapter_name text,
  lesson_number text,
  lesson_name text,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);


CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TRIGGER usage_set_updated_at
  BEFORE UPDATE ON public.usage
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

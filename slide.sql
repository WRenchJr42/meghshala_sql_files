-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- slide child table
CREATE TABLE public.slide (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES public.lesson(id) ON DELETE CASCADE,
  
  page_id text, -- read‐only in the app
  type public.slide_types NOT NULL,
  attachment text, -- storage path or URL
  video_id text, -- read‐only in the app
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: auto-update updated_at on any UPDATE
CREATE TRIGGER slide_set_updated_at
  BEFORE UPDATE ON public.slide
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

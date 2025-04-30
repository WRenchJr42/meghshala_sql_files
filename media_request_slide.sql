-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- media_request_slide child table
CREATE TABLE public.media_request_slide (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  media_request_id uuid NOT NULL REFERENCES public.media_request(id) ON DELETE CASCADE,
  
  slide_number text,
  slide_url text,  -- storage path or URL
  
  request_type public.media_request_slide_request_type_enum NOT NULL,
  media uuid NOT NULL REFERENCES public.media(id) ON DELETE RESTRICT,
  media_title text NOT NULL,
  needs_voiceover boolean NOT NULL DEFAULT FALSE,
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: populate media_title before insert or update
CREATE TRIGGER media_request_slide_populate
  BEFORE INSERT OR UPDATE ON public.media_request_slide
  FOR EACH ROW
  EXECUTE FUNCTION public.media_request_slide_populate_media_title();

-- Trigger: auto-update updated_at before update
CREATE TRIGGER media_request_slide_set_updated_at
  BEFORE UPDATE ON public.media_request_slide
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

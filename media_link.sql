-- Trigger function to keep updated_at in sync (idempotent)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- media_link child table
CREATE TABLE public.media_link (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  media uuid NOT NULL REFERENCES public.media(id) ON DELETE CASCADE,
  
  title text NOT NULL,
  image text NOT NULL,
  video text NOT NULL,
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: populate title, image, video before insert or update
CREATE TRIGGER media_link_populate
  BEFORE INSERT OR UPDATE ON public.media_link
  FOR EACH ROW
  EXECUTE FUNCTION public.media_link_populate_details();

-- Trigger: auto-update updated_at before any update
CREATE TRIGGER media_link_set_updated_at
  BEFORE UPDATE ON public.media_link
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

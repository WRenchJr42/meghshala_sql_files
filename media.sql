-- media table

CREATE TABLE public.media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),                  -- ID
  title text NOT NULL,
  image text,                                                     -- storage path or URL to the image file
  video text,                                                     -- storage path or URL to the video file
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);


-- Trigger for INSERT (for created_by)

CREATE TRIGGER media_set_user_ids_insert
  BEFORE INSERT ON public.media
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_by)

CREATE TRIGGER media_set_user_ids_update
  BEFORE UPDATE ON public.media
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_at)

CREATE TRIGGER media_set_updated_at
  BEFORE UPDATE ON public.media
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

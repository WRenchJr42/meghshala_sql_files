-- media_link child table

CREATE TABLE public.media_links (
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


-- Trigger for INSERT (for created_by)

CREATE TRIGGER media_links_set_user_ids_insert
  BEFORE INSERT ON public.media_links
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_by)

CREATE TRIGGER media_links_set_user_ids_update
  BEFORE UPDATE ON public.media_links
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_at)

CREATE TRIGGER media_links_set_updated_at
  BEFORE UPDATE ON public.media_links
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

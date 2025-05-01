-- media_request_slides child table

CREATE TABLE public.media_request_slides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),                                                -- ID
  media_request_id uuid NOT NULL REFERENCES public.media_requests(id) ON DELETE CASCADE,
  
  slide_number integer,
  slide_url text,                                                                               -- storage path or URL
  
  --request_type public.media_request_slides_request_types NOT NULL,
  media uuid NOT NULL REFERENCES public.media(id) ON DELETE RESTRICT,
  media_title text NOT NULL,
  needs_voiceover boolean NOT NULL DEFAULT FALSE,
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);


-- Trigger for INSERT (for created_by)

CREATE TRIGGER media_request_slides_set_user_ids_insert
  BEFORE INSERT ON public.media_request_slides
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_by)

CREATE TRIGGER media_request_slides_set_user_ids_update
  BEFORE UPDATE ON public.media_request_slides
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();
  

-- Trigger for UPDATE (for updated_at)

CREATE TRIGGER media_request_slides_set_updated_at
  BEFORE UPDATE ON public.media_request_slides
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

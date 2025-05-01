-- media_requests table

CREATE TABLE public.media_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- autoname field
  -- name text NOT NULL UNIQUE,

  lesson uuid NOT NULL REFERENCES public.lessons(id) ON DELETE RESTRICT,
  lesson_id text NOT NULL,                                                     -- fetched from lesson.lesson_id
  lesson_name text NOT NULL,
  lesson_number integer NOT NULL,

  chapter_name text NOT NULL,
  chapter_number integer NOT NULL,

  requested_by uuid NOT NULL REFERENCES auth.users(id),
  request_date  date,

  completed_by uuid REFERENCES auth.users(id),
  completion_date date,

  status public.media_request_status NOT NULL DEFAULT 'NEW',
  requirement text,

  language text NOT NULL,
  curriculum text NOT NULL,
  grade text NOT NULL,
  semester text NOT NULL,

  -- internal sequence for autoname suffix
  seq integer NOT NULL,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);



-- Trigger for INSERT (for created_by)
CREATE TRIGGER media_requests_set_user_ids_insert
  BEFORE INSERT ON public.media_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_by)
CREATE TRIGGER media_requests_set_user_ids_update
  BEFORE UPDATE ON public.media_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_at)
CREATE TRIGGER media_requests_set_updated_at
  BEFORE UPDATE ON public.media_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

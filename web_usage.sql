CREATE TABLE public.web_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Fields defined in the DocType
  user_ID UUID references auth.users(id),  -- corresponds to `Data` with "User" option
  lesson text NOT NULL,            -- corresponds to `Link` to "Lesson"
  type content_types NOT NULL,

  -- Meta fields
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid references auth.users(id) ,
	created_by uuid references auth.users(id)
);

-- Trigger for INSERT (for created_by)
CREATE TRIGGER web_usage_set_user_ids_insert
  BEFORE INSERT ON public.web_usage
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_by)
CREATE TRIGGER web_usage_set_user_ids_update
  BEFORE UPDATE ON public.web_usage
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_at)
CREATE TRIGGER web_usage_set_updated_at
  BEFORE UPDATE ON public.web_usage
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();


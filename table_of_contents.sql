-- table_of_contents table
CREATE TABLE public.table_of_contents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger to auto-update `updated_at`
CREATE TRIGGER table_of_contents_set_updated_at
  BEFORE UPDATE ON public.table_of_contents
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

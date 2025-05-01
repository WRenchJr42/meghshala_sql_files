CREATE TABLE public.usage_exports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Fields from the DocType
  timestamp timestamp with time zone NOT NULL DEFAULT now(),
  csv_file text,

  -- Meta fields
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id)
);
-- Trigger for INSERT (for created_by)
CREATE TRIGGER usage_exports_set_user_ids_insert
  BEFORE INSERT ON public.usage_exports
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_by)
CREATE TRIGGER usage_exports_set_user_ids_update
  BEFORE UPDATE ON public.usage_exports
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();

-- Trigger for UPDATE (for updated_at)
CREATE TRIGGER usage_exports_set_updated_at
  BEFORE UPDATE ON public.usage_exports
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

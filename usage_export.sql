CREATE TABLE public.usage_export (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Fields from the DocType
  timestamp timestamp with time zone NOT NULL DEFAULT now(),
  csv_file text,

  -- Meta fields
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid references auth.users(id) DEFAULT 'ADMINISTRATOR',
  created_by uuid references auth.users(id) DEFAULT 'ADMINISTRATOR'
);
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_usage_export_set_updated_at
  BEFORE UPDATE ON public.usage_export
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

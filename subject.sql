-- Trigger function to keep updated_at in sync (idempotent)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE public.subject (
  id text PRIMARY KEY, --subject name , not uuid
  title text NOT NULL,
  color text NOT NULL,
  
  created_at  timestamp with time zone NOT NULL DEFAULT now(),
  updated_at  timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
  created_by uuid references auth.users(id)
);

-- Trigger: auto-update updated_at on any UPDATE
CREATE TRIGGER subject_set_updated_at
  BEFORE UPDATE ON public.subject
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

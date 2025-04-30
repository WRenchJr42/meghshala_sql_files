-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to set the 'name' field
CREATE OR REPLACE FUNCTION public.semester_set_name()
RETURNS TRIGGER AS $$
BEGIN
  NEW.name := 'S' || NEW.number::text;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- semester table
CREATE TABLE public.semester (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  number public.semester_numbers NOT NULL UNIQUE,
  name text NOT NULL UNIQUE,
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
  created_by uuid references auth.users(id)
);

-- Trigger: generate 'name' before insert or update
CREATE TRIGGER semester_generate_name
  BEFORE INSERT OR UPDATE ON public.semester
  FOR EACH ROW
  EXECUTE FUNCTION public.semester_set_name();

-- Trigger: auto-update updated_at on any UPDATE
CREATE TRIGGER semester_set_updated_at
  BEFORE UPDATE ON public.semester
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

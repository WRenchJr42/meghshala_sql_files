-- Trigger function to keep updated_at in sync (idempotent)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to populate ISO 3166 code from the linked country
CREATE OR REPLACE FUNCTION public.country_code_populate_code()
RETURNS TRIGGER AS $$
DECLARE
  c_rec RECORD;
BEGIN
  SELECT code
    INTO c_rec
    FROM public.country
   WHERE id = NEW.country_id;
  IF FOUND THEN
    NEW.code := c_rec.code;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- country_code table
CREATE TABLE public.country_code (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  country_id uuid NOT NULL REFERENCES public.country(id) ON DELETE RESTRICT,
  
  isd_code integer NOT NULL,
  digits integer NOT NULL,
  flag text NOT NULL,
  
  code text NOT NULL,  -- fetched from country.code
  
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: populate code before insert or update
CREATE TRIGGER country_code_populate
  BEFORE INSERT OR UPDATE ON public.country_code
  FOR EACH ROW
  EXECUTE FUNCTION public.country_code_populate_code();

-- Trigger: auto-update updated_at before any UPDATE
CREATE TRIGGER country_code_set_updated_at
  BEFORE UPDATE ON public.country_code
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

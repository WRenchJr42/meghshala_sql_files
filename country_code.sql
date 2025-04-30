DROP TRIGGER IF EXISTS country_code_populate ON public.country_code;
DROP FUNCTION IF EXISTS public.country_code_populate_code;

-- New table using the countries enum directly
CREATE TABLE public.country_code (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  country countries NOT NULL,  -- enum

  isd_code integer NOT NULL,
  digits integer NOT NULL,
  flag text NOT NULL,          -- e.g., a URL or emoji

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
  created_by uuid references auth.users(id)
);

-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to set updated_at on update
CREATE TRIGGER country_code_set_updated_at
  BEFORE UPDATE ON public.country_code
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

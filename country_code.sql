
--DROP FUNCTION IF EXISTS public.country_code_populate_code;

--DROP TABLE IF EXISTS public.country_code;

-- Create the table using countries enum
CREATE TABLE public.country_code (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  country countries NOT NULL,  -- enum

  isd_code integer NOT NULL,
  digits integer NOT NULL,
  flag text NOT NULL,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
  created_by uuid references auth.users(id)
);

-- Create trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Now that the table exists, create the trigger
CREATE TRIGGER country_code_set_updated_at
  BEFORE UPDATE ON public.country_code
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

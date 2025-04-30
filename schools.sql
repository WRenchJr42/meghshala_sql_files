-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- school table
CREATE TABLE public.schools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  school_code text UNIQUE,  -- optional short code
  school_type school_types NOT NULL DEFAULT 'GOVERNMENT',
  address text,
  city text,
  state states,
  zip varchar(10),
  district text,
  phone varchar(20),
  email text,
  website text,
  established_date date,
  principal_name text,
  number_of_students integer DEFAULT 0,

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
  created_by uuid references auth.users(id)
);

-- Trigger: auto-update updated_at on row changes
CREATE TRIGGER school_set_updated_at
  BEFORE UPDATE ON public.schools
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

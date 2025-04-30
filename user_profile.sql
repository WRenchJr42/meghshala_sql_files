-- Trigger function to keep updated_at in sync
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- user_profile table
CREATE TABLE public.user_profile (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- denormalized from auth.users
  phone text NOT NULL,
  first_name text NOT NULL,
  last_name text,

  user_type user_types NOT NULL,
  qualification qualifications,
  experience experiences,
  assessment_enabled boolean NOT NULL DEFAULT FALSE,

  cluster text,
  school text,
  school_type school_types,
  dise text,

  state text NOT NULL,
  district text NOT NULL,
  pincode  text,

  dob date,
  gender genders,
  preferred_language uuid REFERENCES public.curriculum_language(id),

  block text,
  first_login first_logins NOT NULL DEFAULT 'MOBILE',

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Trigger: auto-update updated_at on any UPDATE
CREATE TRIGGER trg_user_profile_updated_at
  BEFORE UPDATE ON public.user_profile
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

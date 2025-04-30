CREATE TABLE public.web_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Fields defined in the DocType
  user_ID UUID references auth.users(id),              -- corresponds to `Data` with "User" option
  lesson text NOT NULL,            -- corresponds to `Link` to "Lesson"
  type types NOT NULL,

  -- Meta fields
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid references auth.users(id) DEFAULT 'ADMINISTRATOR',
  created_by uuid references auth.users(id) DEFAULT 'ADMINISTRATOR'
);
CREATE OR REPLACE FUNCTION public.update_web_usage_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_web_usage_updated_at
BEFORE UPDATE ON public.web_usage
FOR EACH ROW
EXECUTE FUNCTION public.update_web_usage_updated_at();

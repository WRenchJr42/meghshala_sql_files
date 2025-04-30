-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- meghshala_notification table
CREATE TABLE public.meghshala_notification (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  image text,  -- stores file path or URL

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger: auto-update updated_at on UPDATE
CREATE TRIGGER meghshala_notification_set_updated_at
  BEFORE UPDATE ON public.meghshala_notification
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

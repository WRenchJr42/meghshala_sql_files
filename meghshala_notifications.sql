-- meghshala_notifications table

CREATE TABLE public.meghshala_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),                        -- ID
  title text NOT NULL,                                                  -- name
  description text,
  image text,                                                           -- stores file path or URL

  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);


-- Trigger for INSERT (for created_by)

CREATE TRIGGER meghshala_notifications_set_user_ids_insert
  BEFORE INSERT ON public.meghshala_notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_by)

CREATE TRIGGER meghshala_notifications_set_user_ids_update
  BEFORE UPDATE ON public.meghshala_notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_ids();


-- Trigger for UPDATE (for updated_at)

CREATE TRIGGER meghshala_notifications_set_updated_at
  BEFORE UPDATE ON public.meghshala_notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

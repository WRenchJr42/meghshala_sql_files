--function to auto-update "updated_at"
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- table
create table public.chapter (
  id uuid primary key default gen_random_uuid(),
  chapter_name text not null,
  chapter_number integer not null,
  is_published boolean not null default false,
  chapter_id text unique,
  
  language uuid not null references public.curriculum_language(id),
  curriculum uuid not null references public.curriculum(id),
  grade uuid not null references public.grade(id),
  semester uuid not null references public.semester(id),
  subject text not null references public.subject(id),
  --subtype text references public.subtype(id),
  
  grade_number text not null,
  semester_number text not null,
  subject_name text,
  color text not null,
  
  unit_plan_created boolean not null default false,
  unit_plan_reviewed boolean not null default false,
  unit_plan_finalised boolean not null default false,
  
  copy_written boolean not null default false,
  layout_created boolean not null default false,
  illustrations_created boolean not null default false,
  videos_created boolean not null default false,
  google_slides_created boolean not null default false,
  
  review_1_completed boolean not null default false,
  review_2_completed boolean not null default false,
  final_review_completed boolean not null default false,
  
  editing_status editing_status,   -- URL or storage path for the attachment
  
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  updated_by uuid references auth.users(id),
	created_by uuid references auth.users(id) 
);

-- Trigger to keep updated_at current
create trigger set_updated_at
  before update on public.chapter
  for each row
  execute function update_updated_at_column();


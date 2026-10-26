
BEGIN;

-- 1. Allow the three C.A.P.S. application roles.
ALTER TABLE public.users
    DROP CONSTRAINT IF EXISTS users_role_check;

ALTER TABLE public.users
    ADD CONSTRAINT users_role_check
    CHECK (role IN ('student', 'tpc', 'tpo'));

-- 2. Link application users to Supabase Auth identities.
-- Account deletion must follow a controlled process.
ALTER TABLE public.users
    ADD CONSTRAINT users_auth_user_fk
    FOREIGN KEY (id)
    REFERENCES auth.users(id)
    ON DELETE RESTRICT;

-- 3. Provision new Auth users as students.
-- Never assign TPC or TPO privileges from signup metadata.
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    IF NEW.email IS NULL OR btrim(NEW.email) = '' THEN
        RAISE EXCEPTION
            'C.A.P.S. requires an email address for every user.';
    END IF;

    INSERT INTO public.users (
        id,
        email,
        role,
        is_active
    )
    VALUES (
        NEW.id,
        NEW.email,
        'student',
        true
    )
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$;

-- 4. Provision application records for new Auth users.
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_auth_user();

-- 5. Provision existing Auth users as students.
-- Existing public.users records are not overwritten.
INSERT INTO public.users (
    id,
    email,
    role,
    is_active
)
SELECT
    id,
    email,
    'student',
    true
FROM auth.users
WHERE email IS NOT NULL
  AND btrim(email) <> ''
ON CONFLICT (id) DO NOTHING;

-- 6. Prevent API roles from invoking the trigger function directly.
REVOKE ALL ON FUNCTION public.handle_new_auth_user()
    FROM PUBLIC, anon, authenticated, service_role;

COMMIT;

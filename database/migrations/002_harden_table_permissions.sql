
BEGIN;

-- Remove unnecessary structural privileges from API roles.
REVOKE REFERENCES, TRIGGER, TRUNCATE
ON ALL TABLES IN SCHEMA public
FROM anon, authenticated, service_role;

COMMIT;

-- Bootstrap one database per Postgres-backed service on first init.
-- (The postgres image only creates $POSTGRES_DB, so add the rest here.)
CREATE DATABASE acc_db;
CREATE DATABASE grit_jira;

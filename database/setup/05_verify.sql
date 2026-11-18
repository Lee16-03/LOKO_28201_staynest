-- ============================================================
-- Name       : LOKO EZONSOU Eldad
-- Student ID : 28201
-- Group      : I
-- Project    : StayNest
-- Script     : 05_verify.sql  (Task 6: verification - 11g Adapted)
-- Run as     : SYS AS SYSDBA
-- ============================================================
-- Take one screenshot per numbered query. Each result shows the database/schema, the user and the time.
-- The output is also saved as text in 05_verify_output.txt (SPOOL).
-- ============================================================
SET DEFINE ON
SET VERIFY OFF
DEFINE project_schema = grpI_28201_eldad_staynest_db
SPOOL 05_verify_output.txt

-- ---------------- PART A: database instance level ----------------

-- 1. Who, where and when
SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV','DB_NAME') AS database_name,
       TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') AS run_time
FROM dual;

-- 2. Database instance status & project schema existence (11g equivalent of PDB status)
SELECT instance_name, status AS db_status, database_status
FROM v$instance;

SELECT username AS project_schema, account_status, default_tablespace
FROM dba_users
WHERE username = UPPER('&project_schema');

-- 3. Archive log mode of the database
SELECT name AS database_name, log_mode FROM v$database;

-- ---------------- PART B: project admin & tablespace verification ----------------

-- 4. Who, where and when (session context)
SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV','DB_NAME') AS database_name,
       SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS current_schema,
       TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') AS run_time
FROM dual;

-- 5. Admin user: default and temporary tablespaces
SELECT username, default_tablespace, temporary_tablespace
FROM dba_users WHERE username = 'ELDAD_ADMIN';

-- 6. Admin user: DBA role and quotas (-1 means unlimited)
SELECT grantee, granted_role FROM dba_role_privs WHERE grantee = 'ELDAD_ADMIN';
SELECT username, tablespace_name,
       DECODE(max_bytes, -1, 'UNLIMITED', TO_CHAR(max_bytes)) AS quota
FROM dba_ts_quotas WHERE username = 'ELDAD_ADMIN';

-- 7. Tablespaces: size, autoextend setting and maximum size (MB)
SELECT f.tablespace_name,
       ROUND(f.bytes / 1048576)                         AS size_mb,
       f.autoextensible                                 AS autoextend,
       ROUND(f.increment_by * t.block_size / 1048576)   AS next_mb,
       ROUND(f.maxbytes / 1048576)                      AS max_mb
FROM dba_data_files f
JOIN dba_tablespaces t ON t.tablespace_name = f.tablespace_name
WHERE f.tablespace_name IN ('STAYNEST_DATA','STAYNEST_IDX')
UNION ALL
SELECT f.tablespace_name,
       ROUND(f.bytes / 1048576),
       f.autoextensible,
       ROUND(f.increment_by * t.block_size / 1048576),
       ROUND(f.maxbytes / 1048576)
FROM dba_temp_files f
JOIN dba_tablespaces t ON t.tablespace_name = f.tablespace_name
WHERE f.tablespace_name = 'STAYNEST_TEMP'
ORDER BY 1;

SPOOL OFF
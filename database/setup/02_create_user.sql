-- ============================================================
-- Name       : LOKO EZONSOU Eldad
-- Student ID : 28201
-- Group      : I
-- Project    : StayNest
-- Script     : 02_create_user.sql  (Oracle 11g Adapted Version)
-- Run as     : SYS AS SYSDBA
-- ============================================================
SET DEFINE ON
SET VERIFY OFF

-- Remove the existing user from the previous run so it recreates cleanly
DROP USER eldad_admin CASCADE;

-- Create the admin user directly in the 11g database instance
CREATE USER eldad_admin IDENTIFIED BY eldad;
GRANT DBA TO eldad_admin;

-- Evidence: the user exists and has the DBA role
SELECT username, account_status FROM dba_users WHERE username = 'ELDAD_ADMIN';
SELECT grantee, granted_role FROM dba_role_privs WHERE grantee = 'ELDAD_ADMIN';
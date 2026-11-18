-- ============================================================
-- Name       : LOKO EZONSOU Eldad
-- Student ID : 28201
-- Group      : I
-- Project    : StayNest
-- Script     : 01_create_schema_11g.sql (Oracle 11g Equivalent)
-- Run as     : SYS AS SYSDBA
-- ============================================================
SET SERVEROUTPUT ON

-- 1. Create a dedicated tablespace for your project data
CREATE TABLESPACE staynest_tbs
  DATAFILE 'staynest_tbs01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- 2. Create the project user/schema (replaces the PDB container)
CREATE USER grpI_28201_eldad_staynest_db IDENTIFIED BY pdb_boot_pw1
  DEFAULT TABLESPACE staynest_tbs
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON staynest_tbs;

-- 3. Grant necessary privileges to build and run the project
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE SYNONYM TO grpI_28201_eldad_staynest_db;

-- 4. Evidence for screenshot: verify tablespace and user exist
SELECT tablespace_name, status FROM dba_tablespaces WHERE tablespace_name = 'STAYNEST_TBS';
SELECT username, account_status, default_tablespace FROM dba_users WHERE username = UPPER('grpI_28201_eldad_staynest_db');
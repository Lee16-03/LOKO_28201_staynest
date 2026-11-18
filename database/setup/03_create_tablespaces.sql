-- ============================================================
-- Name       : LOKO EZONSOU Eldad
-- Student ID : 28201
-- Group      : I
-- Project    : StayNest
-- Script     : 03_tablespaces.sql  (Task 3: configure tablespaces - 11g Adapted)
-- Run as     : SYS AS SYSDBA
-- ============================================================
-- staynest_data : 100M, AUTOEXTEND ON NEXT 10M MAXSIZE 1G
-- staynest_idx  :  50M, AUTOEXTEND ON NEXT 10M MAXSIZE 500M
-- staynest_temp :  50M, AUTOEXTEND ON NEXT 10M MAXSIZE 500M (temporary)
-- ============================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON

-- The files are placed in the same folder as the database's SYSTEM datafile
DECLARE
  v_file VARCHAR2(500);
  v_sep  VARCHAR2(1);
  v_dir  VARCHAR2(500);
BEGIN
  SELECT MIN(file_name) INTO v_file FROM dba_data_files WHERE tablespace_name = 'SYSTEM';
  v_sep := CASE WHEN INSTR(v_file, '\') > 0 THEN '\' ELSE '/' END;
  v_dir := SUBSTR(v_file, 1, INSTR(v_file, v_sep, -1));

  EXECUTE IMMEDIATE 'CREATE TABLESPACE staynest_data DATAFILE ''' || v_dir ||
    'staynest_data01.dbf'' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1G';

  EXECUTE IMMEDIATE 'CREATE TABLESPACE staynest_idx DATAFILE ''' || v_dir ||
    'staynest_idx01.dbf'' SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M';

  EXECUTE IMMEDIATE 'CREATE TEMPORARY TABLESPACE staynest_temp TEMPFILE ''' || v_dir ||
    'staynest_temp01.dbf'' SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M';

  DBMS_OUTPUT.PUT_LINE('Tablespaces created in ' || v_dir);
END;
/

-- The admin user works in these tablespaces by default
ALTER USER eldad_admin
  DEFAULT TABLESPACE staynest_data
  TEMPORARY TABLESPACE staynest_temp
  QUOTA UNLIMITED ON staynest_data
  QUOTA UNLIMITED ON staynest_idx;

-- Evidence: verify the three tablespaces exist and are online
SELECT tablespace_name, contents, status FROM dba_tablespaces
WHERE tablespace_name LIKE 'STAYNEST%' ORDER BY tablespace_name;
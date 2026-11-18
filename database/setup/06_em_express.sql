-- ============================================================
-- Name       : LOKO EZONSOU Eldad
-- Student ID : 28201
-- Group      : I
-- Project    : StayNest
-- Script     : 06_em_express.sql  (Task 5: Database Control / DBA View - 11g Adapted)
-- Run as     : SYS AS SYSDBA
-- ============================================================
-- Port = 55xx, where xx is the last two digits of the student ID (28201 -> 01) -> 5501
-- Note: Oracle 11g does not have EM Express (DBMS_XDB_CONFIG is 12c+). 
--       11g uses DBMS_XDB for HTTP port configuration or SQL Developer's DBA view.
-- ============================================================
SET DEFINE ON
SET VERIFY OFF

-- Configure the 11g XML DB HTTP port (equivalent to setting the web console port)
EXEC DBMS_XDB.SETHTTPPORT(5501);

-- Verify the configured HTTP port
SELECT DBMS_XDB.GETHTTPPORT AS http_port FROM dual;

-- ============================================================
-- HOW TO TAKE YOUR SCREENSHOT IN ORACLE 11g:
-- Because EM Express (https://localhost:5501/em) is only available in Oracle 12c–21c,
-- use the SQL Developer DBA panel fallback mentioned in the instructions:
--   1. In SQL Developer, click: View > DBA
--   2. In the DBA panel on the left, click the green '+' icon and select your 'eldad_admin' connection.
--   3. Expand: eldad_admin > Storage > Tablespaces.
--   4. Screenshot the screen showing your 'eldad_admin' connection and the STAYNEST tablespaces.
-- ============================================================
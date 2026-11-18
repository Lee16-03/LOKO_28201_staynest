-- ============================================================
-- Name       : LOKO EZONSOU Eldad
-- Student ID : 28201
-- Group      : I
-- Project    : StayNest
-- Script     : 04_archive_log.sql  (Task 4: archive logging - 11g Adapted)
-- Run as     : SYS AS SYSDBA
-- ============================================================
-- WHY ARCHIVELOG MODE IS A GLOBAL DATABASE SETTING
-- Archive logging is a database-wide setting in Oracle 11g. All datafiles 
-- share the same set of online redo logs and control files. Changing the 
-- database to ARCHIVELOG mode requires a database restart in MOUNT mode, 
-- meaning it affects the entire database instance globally rather than 
-- just an individual user or schema.
-- ============================================================
SET DEFINE ON
SET VERIFY OFF

-- Check and show the current archive log mode (this part is safe on any server)
SELECT name, log_mode FROM v$database;
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') AS run_time FROM dual;

-- ============================================================
-- LOCAL INSTALLATION ONLY. DO NOT RUN ON A SHARED LAB SERVER.
-- Run these steps in SQL*Plus or SQL Developer on your own laptop instance 
-- connected as SYS AS SYSDBA:
-- ============================================================
-- SHUTDOWN IMMEDIATE;
-- STARTUP MOUNT;
-- ALTER DATABASE ARCHIVELOG;
-- ALTER DATABASE OPEN;
-- ARCHIVE LOG LIST;
-- SELECT name, log_mode FROM v$database;
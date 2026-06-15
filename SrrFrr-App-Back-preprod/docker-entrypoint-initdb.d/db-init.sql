-- ========================================
-- init-db.sql - Database Initialization Script
-- ========================================
-- This script creates users and grants permissions
-- Schema creation is handled by Liquibase migrations

-- ========================================
-- 1. CREATE LIQUIBASE USER
-- ========================================
CREATE USER liquibase_user WITH PASSWORD '123';

-- ========================================
-- 2. GRANT DATABASE-LEVEL PERMISSIONS TO LIQUIBASE
-- ========================================
-- Allow connection to database
GRANT CONNECT ON DATABASE srrfrrdb TO liquibase_user;

-- Allow creating schemas, tables, and other objects
GRANT CREATE ON DATABASE srrfrrdb TO liquibase_user;

-- ========================================
-- 3. GRANT PUBLIC SCHEMA PERMISSIONS
-- ========================================
-- Liquibase needs to create tracking tables in public schema
GRANT USAGE ON SCHEMA public TO liquibase_user;
GRANT CREATE ON SCHEMA public TO liquibase_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO liquibase_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO liquibase_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO liquibase_user;

-- ========================================
-- 4. GRANT DEFAULT PRIVILEGES FOR FUTURE OBJECTS IN PUBLIC
-- ========================================
-- This ensures Liquibase can manage its own tracking tables
ALTER DEFAULT PRIVILEGES FOR USER liquibase_user IN SCHEMA public 
    GRANT ALL PRIVILEGES ON TABLES TO liquibase_user;
ALTER DEFAULT PRIVILEGES FOR USER liquibase_user IN SCHEMA public 
    GRANT ALL PRIVILEGES ON SEQUENCES TO liquibase_user;
ALTER DEFAULT PRIVILEGES FOR USER liquibase_user IN SCHEMA public 
    GRANT ALL PRIVILEGES ON FUNCTIONS TO liquibase_user;

-- ========================================
-- 5. GRANT PERMISSIONS TO db_admin
-- ========================================
-- Allow db_admin to connect
GRANT CONNECT ON DATABASE srrfrrdb TO db_admin;

-- Grant usage on public schema
GRANT USAGE ON SCHEMA public TO db_admin;

-- ========================================
-- 6. GRANT DEFAULT PRIVILEGES FOR db_admin
-- ========================================
-- When liquibase_user creates tables in ANY schema, grant access to db_admin
ALTER DEFAULT PRIVILEGES FOR USER liquibase_user 
    GRANT ALL PRIVILEGES ON TABLES TO db_admin;
ALTER DEFAULT PRIVILEGES FOR USER liquibase_user 
    GRANT ALL PRIVILEGES ON SEQUENCES TO db_admin;
ALTER DEFAULT PRIVILEGES FOR USER liquibase_user 
    GRANT ALL PRIVILEGES ON FUNCTIONS TO db_admin;

-- ========================================
-- 7. ENABLE REQUIRED EXTENSIONS
-- ========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
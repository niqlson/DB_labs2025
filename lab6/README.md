# Lab 6 – Schema Migrations with Liquibase (SQL)

This lab follows the Prisma migration brief but replaces Prisma-specific tooling with Liquibase + pure SQL change logs, per the assignment requirements. The schema starts with the normalized model from lab5 and evolves through additive, modifying, and destructive migrations.

## Prerequisites
- Java 17+ (already installed system-wide)
- Liquibase CLI (bundled under `lab6/tools/liquibase-4.30.0/`)
- PostgreSQL JDBC driver (already copied to `lab6/liquibase/lib/postgresql-42.7.3.jar`)
- Running PostgreSQL from the project `docker-compose.yaml` (`admin/masterkey@localhost:1212/myDB`)

Bring up the database if Docker Desktop is running:
```powershell
cd C:/Users/Admin/Desktop/DB_labs2025
docker compose up -d db    # or: docker-compose up -d db
```

## Project layout
```
lab6/
  liquibase/
    changelog/
      changelog-master.xml
      migrations/
        001-baseline-schema.sql
        002-create-product-media.sql
        003-add-allow-preorder.sql
        004-migrate-image-url.sql
        005-refresh-order-totals-view.sql
    lib/
      postgresql-42.7.3.jar
    liquibase.properties
  tools/
    liquibase-4.30.0/
      liquibase.bat
  scripts/
    verify-product-media.sql
  migration-notes.md
```

## Running the migrations
### Option A — direct CLI
From `lab6/liquibase/` execute the bundled CLI:
```powershell ..\\tools\\liquibase-4.30.0\\liquibase.bat --defaultsFile=liquibase.properties update```
This will apply the baseline plus each incremental change set in order. Use `liquibase status` to confirm what has executed, and `liquibase rollbackCount 1` (etc.) if you need to revert.


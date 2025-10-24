# Project Files Overview

This document describes all files in the project and their purposes.

## Core Files

### `docker-compose.yml`
Docker Compose configuration for PostgreSQL database.
- **Purpose**: Defines the database container, ports, volumes, and health checks
- **Usage**: `docker-compose up -d` to start, `docker-compose down` to stop

### `README.md`
Main project documentation.
- **Purpose**: Comprehensive guide covering database schema, setup, queries, and features
- **Audience**: All users, especially those integrating with the database

### `QUICKSTART.md`
Step-by-step getting started guide.
- **Purpose**: Quick setup and common usage scenarios for new users
- **Audience**: New users who want to start quickly without reading full docs

## Database Schema & Initialization

### `init-db/init.sql`
Database schema initialization script.
- **Purpose**: Creates tables, triggers, indexes, and basic sample data
- **Auto-runs**: Automatically executed when database first starts
- **Contains**:
  - `ReportTemplate` table definition
  - `Task` table definition
  - `TaskResult` table definition
  - Triggers for automatic timestamp updates
  - Indexes for performance
  - Basic sample data (3 templates, 3 tasks)

### `init-db/seed_test_data.sql`
Comprehensive test data population script.
- **Purpose**: Populates database with realistic test data for development
- **Manual run**: Use `./seed-database.sh` or run directly with psql
- **Contains**:
  - 15 report templates (various periods and types)
  - 30+ tasks (completed, failed, running, pending, scheduled)
  - Realistic task results with JSONB data
  - Error scenarios and edge cases
- **Warning**: Clears existing data before inserting

## Shell Scripts (Utilities)

### `seed-database.sh`
Interactive script to populate database with test data.
- **Purpose**: User-friendly way to load test data with confirmation
- **Usage**: `./seed-database.sh`
- **Features**:
  - Checks if database is running
  - Asks for confirmation before clearing data
  - Runs `seed_test_data.sql`
  - Shows summary statistics
  - Color-coded output

### `verify-data.sh`
Database state verification and summary script.
- **Purpose**: Quickly view current database state and statistics
- **Usage**: `./verify-data.sh`
- **Shows**:
  - All report templates
  - Task status distribution
  - Recent tasks (last 10)
  - Task results summary
  - Table sizes
  - Upcoming scheduled tasks
- **Use cases**: 
  - Verify seeding worked
  - Check database state
  - Monitor data growth

### `quick-query.sh`
Interactive menu for running common queries.
- **Purpose**: Easy access to frequently used queries without writing SQL
- **Usage**: `./quick-query.sh`
- **Menu options**:
  1. List all report templates
  2. Show task status summary
  3. Show recent tasks
  4. Show pending tasks
  5. Show failed tasks with errors
  6. Show task execution statistics
  7. Show upcoming tasks (next 24h)
  8. Show running tasks
  9. Show successful task results
  10. Custom SQL query
- **Audience**: Developers, QA testers, database admins

## SQL Query Collections

### `query-examples.sql`
Comprehensive collection of SQL queries organized by category.
- **Purpose**: Reference guide and learning resource for database queries
- **Categories**:
  1. Report Templates queries
  2. Task queries (by status, scheduling, etc.)
  3. Task Results queries (success, errors, performance)
  4. Statistics & Analytics queries
  5. Cleanup & Maintenance queries
  6. Administrative queries (sizes, indexes)
- **Usage**:
  - Copy queries to use in your application
  - Learn JSONB querying techniques
  - Reference for complex JOINs and aggregations
  - Run entire file: `docker exec -i reporting-db psql -U reporting_user -d reporting < query-examples.sql`

## Configuration Files

### `.gitignore`
Git ignore rules.
- **Purpose**: Prevents committing temporary files, backups, and local configs
- **Ignores**:
  - Database backups (*.sql.backup, backup_*.sql)
  - CSV exports
  - Log files
  - OS files (.DS_Store, Thumbs.db)
  - IDE files (.vscode/, .idea/)
  - Environment files (.env)
  - Temporary files

## File Usage Guide

### For New Users
1. Read `QUICKSTART.md`
2. Run `./seed-database.sh`
3. Use `./verify-data.sh` to confirm
4. Explore with `./quick-query.sh`

### For Developers
1. Review `README.md` for schema and API
2. Study `query-examples.sql` for query patterns
3. Use `seed_test_data.sql` to understand test scenarios
4. Reference `init-db/init.sql` for table structure

### For Testing
1. Run `./seed-database.sh` to reset test data
2. Use `./quick-query.sh` to verify scenarios
3. Run `./verify-data.sh` to check state
4. Reference `query-examples.sql` for test queries

### For Database Administration
1. Monitor with `./verify-data.sh`
2. Use queries from `query-examples.sql` (section 6)
3. Check `docker-compose.yml` for configuration
4. Review logs: `docker-compose logs -f postgres`

## File Relationships

```
PROJECT ROOT
│
├── Docker Infrastructure
│   └── docker-compose.yml ─────────> Starts database
│                                      ↓
├── Database Initialization            
│   └── init-db/
│       ├── init.sql ───────────────> Auto-creates schema on first start
│       └── seed_test_data.sql ─────> Manually populate test data
│                                      ↑
├── Utility Scripts                    │
│   ├── seed-database.sh ──────────────┘ (Runs seed_test_data.sql)
│   ├── verify-data.sh ────────────────> Queries database for summary
│   └── quick-query.sh ────────────────> Runs predefined queries
│
├── Documentation & Examples
│   ├── README.md ─────────────────────> Main documentation
│   ├── QUICKSTART.md ─────────────────> Getting started guide
│   ├── query-examples.sql ────────────> SQL query reference
│   └── PROJECT_FILES.md ──────────────> This file
│
└── Configuration
    └── .gitignore ────────────────────> Git exclusions
```

## Workflow Examples

### Scenario 1: First Time Setup
```bash
docker-compose up -d          # 1. Start database (runs init.sql)
./seed-database.sh            # 2. Load test data
./verify-data.sh              # 3. Verify everything worked
```

### Scenario 2: Daily Development
```bash
./quick-query.sh              # Query data interactively
./verify-data.sh              # Check current state
# ... develop your application ...
./seed-database.sh            # Reset to clean state
```

### Scenario 3: Learning the Database
```bash
# Read documentation
cat README.md
cat QUICKSTART.md

# Study schema
cat init-db/init.sql

# Learn query patterns
cat query-examples.sql

# Practice with real data
./seed-database.sh
./quick-query.sh
```

### Scenario 4: Troubleshooting
```bash
docker-compose logs postgres  # Check logs
./verify-data.sh              # Check data state
docker-compose restart        # Restart if needed
./seed-database.sh            # Reset data if corrupted
```

## Modification Guide

### To Add More Test Data
Edit: `init-db/seed_test_data.sql`
- Add more INSERT statements
- Modify existing data
- Run `./seed-database.sh` to apply

### To Add New Queries
Edit: `query-examples.sql`
- Add to appropriate section
- Test with psql first
- Consider adding to `quick-query.sh` if commonly used

### To Add New Utility Script
1. Create script: `my-script.sh`
2. Make executable: `chmod +x my-script.sh`
3. Follow pattern from existing scripts
4. Document in this file
5. Add to README.md if user-facing

### To Modify Database Schema
Edit: `init-db/init.sql`
- Requires database reset to apply
- Run: `docker-compose down -v && docker-compose up -d`
- Then: `./seed-database.sh`

## Best Practices

### Version Control
- Commit all `.sql`, `.sh`, `.md`, `.yml` files
- Don't commit backups or exports (covered by .gitignore)
- Document significant changes in README.md

### Script Maintenance
- Keep scripts in sync with schema changes
- Update seed data when adding new fields
- Test scripts after schema modifications

### Documentation
- Update README.md when adding features
- Keep QUICKSTART.md simple and focused
- Document complex queries in query-examples.sql

### Testing
- Always run `./verify-data.sh` after seeding
- Test scripts on clean database
- Verify error handling in scripts


# Reporting Database

PostgreSQL database for managing report templates, scheduled tasks, and task results.

## Quick Start

**New to this project?** Check out [QUICKSTART.md](QUICKSTART.md) for a step-by-step guide to get up and running quickly.

### Using Make (Recommended)

If you have `make` installed, you can use convenient shortcuts:

```bash
make start          # Start database
make seed           # Populate with test data
make verify         # Verify data
make query          # Interactive queries
make connect        # Connect with psql
make help           # Show all commands
```

### Manual Setup

See the detailed instructions in the [Setup Instructions](#setup-instructions) section below.

## Database Schema

### ReportTemplate
Stores report template definitions with SQL queries and scheduling periods.

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| name | VARCHAR(255) | Report template name |
| sql | TEXT | SQL query for the report |
| period | VARCHAR(100) | Execution period (daily, weekly, monthly, etc.) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### Task
Manages scheduled report execution tasks.

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| report_template_id | INTEGER | Foreign key to ReportTemplate |
| scheduled_at | TIMESTAMP | When the task is scheduled to run |
| status | VARCHAR(50) | Task status (pending, running, completed, failed) |
| finished_at | TIMESTAMP | When the task finished execution |
| result_code | VARCHAR(50) | Result code (success, error, etc.) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### TaskResult
Stores the results of executed tasks.

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| task_id | INTEGER | Foreign key to Task |
| result | JSONB | Task execution result in JSON format |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

## Setup Instructions

### Start the Database

```bash
docker-compose up -d
```

This will:
- Pull the PostgreSQL 16 Alpine image
- Create and start the container
- Initialize the database schema automatically
- Insert basic sample data for testing

### Populate with Test Data

To populate the database with comprehensive test data for development:

```bash
chmod +x seed-database.sh
./seed-database.sh
```

This will:
- Clear all existing data
- Insert 15 report templates (daily, weekly, monthly, hourly, etc.)
- Create 30+ tasks with various statuses (pending, running, completed, failed)
- Generate realistic task results with JSONB data
- Display a summary of inserted data

**Note:** The seeding script will ask for confirmation before deleting existing data.

Alternatively, you can run the SQL script directly:

```bash
docker exec -i reporting-db psql -U reporting_user -d reporting < init-db/seed_test_data.sql
```

### Stop the Database

```bash
docker-compose down
```

### Stop and Remove All Data

```bash
docker-compose down -v
```

## Connection Details

- **Host**: localhost
- **Port**: 5432
- **Database**: reporting
- **User**: reporting_user
- **Password**: reporting_password

### Connection String

```
postgresql://reporting_user:reporting_password@localhost:5432/reporting
```

### Connect with psql

```bash
docker exec -it reporting-db psql -U reporting_user -d reporting
```

Or from your local machine (if psql is installed):

```bash
psql -h localhost -p 5432 -U reporting_user -d reporting
```

## Utility Scripts

The project includes several utility scripts to help with database management and testing:

### 1. Seed Database (`seed-database.sh`)

Populates the database with comprehensive test data:

```bash
./seed-database.sh
```

Features:
- Asks for confirmation before clearing data
- Inserts 15 report templates
- Creates 30+ tasks with various statuses
- Generates realistic results with JSONB data
- Displays summary statistics

### 2. Verify Data (`verify-data.sh`)

Shows a comprehensive summary of the current database state:

```bash
./verify-data.sh
```

Displays:
- Report templates list
- Task status distribution
- Recent tasks
- Task results statistics
- Table sizes
- Upcoming scheduled tasks

### 3. Quick Query (`quick-query.sh`)

Interactive menu for running common queries:

```bash
./quick-query.sh
```

Options include:
- List report templates
- Show task status summary
- View recent/pending/failed tasks
- Show execution statistics
- View upcoming tasks
- Run custom SQL queries

### 4. Query Examples (`query-examples.sql`)

Collection of useful SQL queries organized by category:
- Report template queries
- Task queries (by status, period, etc.)
- Task result queries
- Statistics and analytics
- Cleanup and maintenance
- Administrative queries

Use it as a reference or run specific queries:

```bash
docker exec -i reporting-db psql -U reporting_user -d reporting < query-examples.sql
```

## Example Queries

### Create a New Report Template

```sql
INSERT INTO ReportTemplate (name, sql, period)
VALUES ('Custom Report', 'SELECT * FROM my_table', 'daily');
```

### Schedule a Task

```sql
INSERT INTO Task (report_template_id, scheduled_at, status)
VALUES (1, CURRENT_TIMESTAMP + INTERVAL '1 hour', 'pending');
```

### Update Task Status

```sql
UPDATE Task
SET status = 'completed',
    finished_at = CURRENT_TIMESTAMP,
    result_code = 'success'
WHERE id = 1;
```

### Store Task Result

```sql
INSERT INTO TaskResult (task_id, result)
VALUES (1, '{"rows": 100, "execution_time": "1.5s", "data": []}');
```

### Query Tasks with Template Information

```sql
SELECT
    t.id,
    rt.name AS template_name,
    t.scheduled_at,
    t.status,
    t.finished_at,
    t.result_code
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
ORDER BY t.scheduled_at DESC;
```

### Query Task Results

```sql
SELECT
    tr.id,
    t.id AS task_id,
    rt.name AS template_name,
    tr.result,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
ORDER BY tr.created_at DESC;
```

### Get Pending Tasks

```sql
SELECT
    t.*,
    rt.name AS template_name,
    rt.sql AS query
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.status = 'pending'
  AND t.scheduled_at <= CURRENT_TIMESTAMP
ORDER BY t.scheduled_at;
```

## Test Data

The `seed_test_data.sql` script provides comprehensive test data including:

- **15 Report Templates**: 
  - Daily reports (sales, users, errors)
  - Weekly reports (revenue, engagement, performance)
  - Monthly reports (financial, customer growth, system health)
  - Hourly reports (traffic, transactions)
  - Custom period reports (quarterly, annual, real-time)

- **30+ Tasks** with realistic scenarios:
  - Completed tasks (with execution results)
  - Failed tasks (with error details)
  - Running tasks (currently executing)
  - Pending tasks (scheduled for future)

- **Task Results** with JSONB data:
  - Successful execution results
  - Error results with detailed error information
  - Performance metrics (execution time, rows returned)
  - Metadata (query plans, cache hits, etc.)

## Features

- **Automatic Timestamps**: All tables have `created_at` and `updated_at` fields that are automatically managed
- **Foreign Key Constraints**: Ensures referential integrity between tables
- **Cascade Deletes**: Deleting a report template or task will automatically delete related records
- **Indexes**: Optimized for common query patterns
- **JSONB Support**: TaskResult uses JSONB for flexible result storage with efficient querying

## Monitoring

### Check Database Health

```bash
docker-compose ps
```

### View Logs

```bash
docker-compose logs -f postgres
```

### Database Size

```sql
SELECT pg_size_pretty(pg_database_size('reporting'));
```

### Table Sizes

```sql
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

# reports

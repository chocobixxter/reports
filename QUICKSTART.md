# Quick Start Guide

This guide will help you quickly set up and start working with the reporting database.

## Initial Setup

### Step 1: Start the Database

```bash
docker-compose up -d
```

Wait a few seconds for the database to initialize.

### Step 2: Verify Database is Running

```bash
docker-compose ps
```

You should see the `reporting-db` container with status "Up".

### Step 3: Populate with Test Data

```bash
./seed-database.sh
```

Type `yes` when prompted to confirm. This will:
- Clear any existing data
- Insert 15 report templates
- Create 30+ tasks with various statuses
- Generate realistic results
- Display a summary

## Verify Everything is Working

### Option 1: Using the Verification Script

```bash
./verify-data.sh
```

This will show you:
- All report templates
- Task status distribution
- Recent tasks
- Statistics
- Table sizes

### Option 2: Using psql Directly

```bash
docker exec -it reporting-db psql -U reporting_user -d reporting
```

Then run:

```sql
SELECT COUNT(*) FROM ReportTemplate;
SELECT COUNT(*) FROM Task;
SELECT COUNT(*) FROM TaskResult;
```

Type `\q` to exit psql.

## Exploring the Data

### Interactive Query Menu

```bash
./quick-query.sh
```

This provides a menu with common queries:
1. List all report templates
2. Show task status summary
3. Show recent tasks
4. Show pending tasks
5. Show failed tasks with errors
6. Show task execution statistics
7. Show upcoming tasks
8. Show running tasks
9. Show successful results
10. Custom SQL query

### View All Report Templates

```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
SELECT id, name, period FROM ReportTemplate ORDER BY period, id;
"
```

### View Tasks by Status

**Completed Tasks:**
```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
SELECT t.id, rt.name, t.status, t.finished_at 
FROM Task t 
JOIN ReportTemplate rt ON t.report_template_id = rt.id 
WHERE t.status = 'completed' 
ORDER BY t.finished_at DESC 
LIMIT 5;
"
```

**Pending Tasks:**
```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
SELECT t.id, rt.name, t.scheduled_at, t.status 
FROM Task t 
JOIN ReportTemplate rt ON t.report_template_id = rt.id 
WHERE t.status = 'pending' 
ORDER BY t.scheduled_at;
"
```

**Failed Tasks:**
```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
SELECT t.id, rt.name, t.result_code, t.finished_at 
FROM Task t 
JOIN ReportTemplate rt ON t.report_template_id = rt.id 
WHERE t.status = 'failed' 
ORDER BY t.finished_at DESC;
"
```

### View Task Results

**Latest Successful Results:**
```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    rt.name as template,
    tr.result->>'execution_time_ms' as exec_time_ms,
    tr.result->>'rows_returned' as rows,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE tr.result->>'status' = 'success'
ORDER BY tr.created_at DESC
LIMIT 5;
"
```

**Error Details:**
```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    rt.name as template,
    tr.result->'error'->>'code' as error_code,
    tr.result->'error'->>'message' as error_message,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE tr.result->>'status' = 'error'
ORDER BY tr.created_at DESC;
"
```

## Common Use Cases

### Use Case 1: Schedule a New Task

```bash
docker exec -it reporting-db psql -U reporting_user -d reporting
```

```sql
-- Schedule a daily sales report for tomorrow
INSERT INTO Task (report_template_id, scheduled_at, status)
VALUES (1, CURRENT_TIMESTAMP + INTERVAL '1 day', 'pending');
```

### Use Case 2: Mark a Task as Completed

```sql
UPDATE Task
SET 
    status = 'completed',
    finished_at = CURRENT_TIMESTAMP,
    result_code = 'success'
WHERE id = 1;
```

### Use Case 3: Store Task Result

```sql
INSERT INTO TaskResult (task_id, result)
VALUES (1, '{
    "execution_time_ms": 1500,
    "rows_returned": 150,
    "status": "success",
    "data": {
        "total_sales": 500,
        "revenue": 75000.00
    }
}');
```

### Use Case 4: Find Tasks Ready to Run

```sql
SELECT 
    t.id,
    rt.name,
    t.scheduled_at
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.status = 'pending'
  AND t.scheduled_at <= CURRENT_TIMESTAMP
ORDER BY t.scheduled_at;
```

### Use Case 5: Get Performance Statistics

```sql
SELECT 
    rt.name as template,
    rt.period,
    COUNT(tr.id) as executions,
    ROUND(AVG((tr.result->>'execution_time_ms')::numeric), 2) as avg_ms,
    ROUND(MAX((tr.result->>'execution_time_ms')::numeric), 2) as max_ms
FROM ReportTemplate rt
JOIN Task t ON rt.id = t.report_template_id
JOIN TaskResult tr ON t.id = tr.task_id
WHERE tr.result->>'status' = 'success'
GROUP BY rt.id, rt.name, rt.period
ORDER BY avg_ms DESC;
```

## Testing Your Application

### Scenario 1: Test Task Scheduling

1. Check pending tasks:
   ```bash
   ./quick-query.sh
   # Select option 4 (pending tasks)
   ```

2. Schedule a new task:
   ```sql
   INSERT INTO Task (report_template_id, scheduled_at, status)
   VALUES (10, CURRENT_TIMESTAMP + INTERVAL '1 hour', 'pending');
   ```

3. Verify it was created:
   ```bash
   ./verify-data.sh
   ```

### Scenario 2: Test Error Handling

1. View existing failed tasks:
   ```bash
   ./quick-query.sh
   # Select option 5 (failed tasks)
   ```

2. Study the error patterns in the results

3. Create a new failed task:
   ```sql
   INSERT INTO Task (report_template_id, scheduled_at, status, finished_at, result_code)
   VALUES (3, CURRENT_TIMESTAMP, 'failed', CURRENT_TIMESTAMP, 'error_custom');
   
   INSERT INTO TaskResult (task_id, result)
   VALUES (CURRVAL('task_id_seq'), '{
       "status": "error",
       "error": {
           "code": "CUSTOM_ERROR",
           "message": "This is a test error"
       }
   }');
   ```

### Scenario 3: Test Reporting

1. Run statistics query:
   ```bash
   ./quick-query.sh
   # Select option 6 (execution statistics)
   ```

2. Get task distribution:
   ```bash
   ./quick-query.sh
   # Select option 2 (task status summary)
   ```

## Cleanup and Reset

### Reset Test Data (Keep Database)

```bash
./seed-database.sh
```

Type `yes` to confirm. This will reset all data back to the initial test state.

### Complete Reset (Remove Everything)

```bash
docker-compose down -v
docker-compose up -d
./seed-database.sh
```

This will:
1. Stop and remove the container
2. Delete all database volumes
3. Recreate the database from scratch
4. Populate with fresh test data

## Advanced Usage

### Export Query Results to CSV

```bash
docker exec -it reporting-db psql -U reporting_user -d reporting -c "
COPY (
    SELECT 
        rt.name,
        t.status,
        COUNT(*) as count
    FROM Task t
    JOIN ReportTemplate rt ON t.report_template_id = rt.id
    GROUP BY rt.name, t.status
    ORDER BY rt.name, t.status
) TO STDOUT WITH CSV HEADER;" > task_statistics.csv
```

### Run Multiple Queries from File

Create a file `my_queries.sql`:

```sql
SELECT COUNT(*) as total_templates FROM ReportTemplate;
SELECT status, COUNT(*) FROM Task GROUP BY status;
```

Run it:

```bash
docker exec -i reporting-db psql -U reporting_user -d reporting < my_queries.sql
```

### Monitor Database Activity

```bash
docker-compose logs -f postgres
```

Press `Ctrl+C` to stop.

### Backup Database

```bash
docker exec reporting-db pg_dump -U reporting_user reporting > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore from Backup

```bash
cat backup_20251024_120000.sql | docker exec -i reporting-db psql -U reporting_user -d reporting
```

## Troubleshooting

### Database Container Won't Start

```bash
# Check logs
docker-compose logs postgres

# Remove and recreate
docker-compose down -v
docker-compose up -d
```

### Cannot Connect to Database

```bash
# Check if container is running
docker ps | grep reporting-db

# Check database health
docker exec reporting-db pg_isready -U reporting_user -d reporting

# Restart container
docker-compose restart
```

### Permission Denied on Scripts

```bash
chmod +x seed-database.sh verify-data.sh quick-query.sh
```

### Out of Disk Space

```bash
# Check database size
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT pg_size_pretty(pg_database_size('reporting'));
"

# Clean up old Docker resources
docker system prune -a
```

## Next Steps

- Explore the `query-examples.sql` file for more query patterns
- Modify `seed_test_data.sql` to add your own test scenarios
- Build your application using the connection details in README.md
- Use the test data to develop and test your reporting features

## Getting Help

- Check README.md for detailed documentation
- Review query-examples.sql for query patterns
- Examine seed_test_data.sql to understand the data structure
- Use `./verify-data.sh` to inspect current database state


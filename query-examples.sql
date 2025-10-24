-- ====================================
-- Example Queries for Test Data
-- ====================================
-- Collection of useful queries for working with the reporting database
-- ====================================

-- ====================================
-- 1. REPORT TEMPLATES QUERIES
-- ====================================

-- Get all report templates with summary
SELECT 
    id,
    name,
    period,
    LENGTH(sql) as sql_length,
    created_at,
    updated_at
FROM ReportTemplate
ORDER BY period, name;

-- Find templates by period
SELECT name, period 
FROM ReportTemplate 
WHERE period = 'daily'
ORDER BY name;

-- Get most recently updated templates
SELECT 
    name,
    period,
    updated_at
FROM ReportTemplate
ORDER BY updated_at DESC
LIMIT 5;

-- ====================================
-- 2. TASK QUERIES
-- ====================================

-- Get all tasks with template information
SELECT 
    t.id,
    rt.name as template_name,
    rt.period,
    t.scheduled_at,
    t.status,
    t.finished_at,
    t.result_code,
    CASE 
        WHEN t.finished_at IS NOT NULL AND t.scheduled_at IS NOT NULL 
        THEN EXTRACT(EPOCH FROM (t.finished_at - t.scheduled_at))
        ELSE NULL 
    END as execution_seconds
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
ORDER BY t.scheduled_at DESC;

-- Get tasks by status
SELECT 
    t.id,
    rt.name as template_name,
    t.scheduled_at,
    t.status,
    t.result_code
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.status = 'completed'
ORDER BY t.finished_at DESC;

-- Get failed tasks with details
SELECT 
    t.id,
    rt.name as template_name,
    t.scheduled_at,
    t.finished_at,
    t.result_code,
    tr.result->'error'->>'message' as error_message
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
LEFT JOIN TaskResult tr ON t.id = tr.task_id
WHERE t.status = 'failed'
ORDER BY t.scheduled_at DESC;

-- Get pending tasks due to run
SELECT 
    t.id,
    rt.name as template_name,
    rt.period,
    t.scheduled_at,
    t.status,
    CASE 
        WHEN t.scheduled_at <= CURRENT_TIMESTAMP 
        THEN 'Overdue' 
        ELSE 'Scheduled' 
    END as run_status
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.status = 'pending'
ORDER BY t.scheduled_at;

-- Get tasks scheduled for next 7 days
SELECT 
    t.id,
    rt.name as template_name,
    rt.period,
    t.scheduled_at::date as scheduled_date,
    t.scheduled_at::time as scheduled_time,
    t.status
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.scheduled_at BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '7 days'
ORDER BY t.scheduled_at;

-- Get running tasks
SELECT 
    t.id,
    rt.name as template_name,
    t.scheduled_at,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - t.scheduled_at)) as running_seconds
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.status = 'running'
ORDER BY t.scheduled_at;

-- ====================================
-- 3. TASK RESULTS QUERIES
-- ====================================

-- Get all task results with task information
SELECT 
    tr.id,
    t.id as task_id,
    rt.name as template_name,
    t.status as task_status,
    tr.result->>'status' as result_status,
    (tr.result->>'execution_time_ms')::numeric as execution_time_ms,
    (tr.result->>'rows_returned')::numeric as rows_returned,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
ORDER BY tr.created_at DESC;

-- Get successful task results with performance metrics
SELECT 
    rt.name as template_name,
    rt.period,
    (tr.result->>'execution_time_ms')::numeric as execution_time_ms,
    (tr.result->>'rows_returned')::numeric as rows_returned,
    tr.result->'metadata'->>'query_plan' as query_plan,
    tr.result->'metadata'->>'cache_hit' as cache_hit,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE tr.result->>'status' = 'success'
ORDER BY (tr.result->>'execution_time_ms')::numeric DESC;

-- Get error results with details
SELECT 
    rt.name as template_name,
    tr.result->'error'->>'code' as error_code,
    tr.result->'error'->>'message' as error_message,
    tr.result->'error'->>'details' as error_details,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE tr.result->>'status' = 'error'
ORDER BY tr.created_at DESC;

-- Get specific result data (example: sales report)
SELECT 
    rt.name as template_name,
    tr.result->'data'->>'total_sales' as total_sales,
    tr.result->'data'->>'revenue' as revenue,
    tr.result->'data'->>'date' as report_date,
    tr.created_at
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE rt.name = 'Daily Sales Summary'
  AND tr.result->>'status' = 'success'
ORDER BY tr.created_at DESC;

-- ====================================
-- 4. STATISTICS & ANALYTICS QUERIES
-- ====================================

-- Task status distribution
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM Task
GROUP BY status
ORDER BY count DESC;

-- Tasks by report template
SELECT 
    rt.name as template_name,
    rt.period,
    COUNT(t.id) as total_tasks,
    COUNT(*) FILTER (WHERE t.status = 'completed') as completed,
    COUNT(*) FILTER (WHERE t.status = 'failed') as failed,
    COUNT(*) FILTER (WHERE t.status = 'pending') as pending,
    COUNT(*) FILTER (WHERE t.status = 'running') as running
FROM ReportTemplate rt
LEFT JOIN Task t ON rt.id = t.report_template_id
GROUP BY rt.id, rt.name, rt.period
ORDER BY total_tasks DESC;

-- Average execution time by template
SELECT 
    rt.name as template_name,
    rt.period,
    COUNT(tr.id) as executions,
    ROUND(AVG((tr.result->>'execution_time_ms')::numeric), 2) as avg_execution_ms,
    ROUND(MIN((tr.result->>'execution_time_ms')::numeric), 2) as min_execution_ms,
    ROUND(MAX((tr.result->>'execution_time_ms')::numeric), 2) as max_execution_ms
FROM ReportTemplate rt
JOIN Task t ON rt.id = t.report_template_id
JOIN TaskResult tr ON t.id = tr.task_id
WHERE tr.result->>'status' = 'success'
GROUP BY rt.id, rt.name, rt.period
HAVING COUNT(tr.id) > 0
ORDER BY avg_execution_ms DESC;

-- Success rate by template
SELECT 
    rt.name as template_name,
    COUNT(t.id) as total_tasks,
    COUNT(*) FILTER (WHERE t.status = 'completed') as completed_tasks,
    COUNT(*) FILTER (WHERE t.status = 'failed') as failed_tasks,
    ROUND(
        COUNT(*) FILTER (WHERE t.status = 'completed') * 100.0 / 
        NULLIF(COUNT(*) FILTER (WHERE t.status IN ('completed', 'failed')), 0),
        2
    ) as success_rate_percentage
FROM ReportTemplate rt
JOIN Task t ON rt.id = t.report_template_id
WHERE t.status IN ('completed', 'failed')
GROUP BY rt.id, rt.name
ORDER BY success_rate_percentage DESC;

-- Task execution timeline (last 7 days)
SELECT 
    DATE(t.scheduled_at) as date,
    COUNT(*) as total_tasks,
    COUNT(*) FILTER (WHERE t.status = 'completed') as completed,
    COUNT(*) FILTER (WHERE t.status = 'failed') as failed
FROM Task t
WHERE t.scheduled_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(t.scheduled_at)
ORDER BY date DESC;

-- Most recent activity
SELECT 
    'Task' as activity_type,
    t.id as record_id,
    rt.name as description,
    t.status,
    t.updated_at as timestamp
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
UNION ALL
SELECT 
    'Result' as activity_type,
    tr.id as record_id,
    rt.name as description,
    tr.result->>'status' as status,
    tr.created_at as timestamp
FROM TaskResult tr
JOIN Task t ON tr.task_id = t.id
JOIN ReportTemplate rt ON t.report_template_id = rt.id
ORDER BY timestamp DESC
LIMIT 20;

-- ====================================
-- 5. CLEANUP & MAINTENANCE QUERIES
-- ====================================

-- Find old completed tasks (older than 30 days)
SELECT 
    t.id,
    rt.name as template_name,
    t.finished_at,
    AGE(CURRENT_TIMESTAMP, t.finished_at) as age
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.status = 'completed'
  AND t.finished_at < CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY t.finished_at;

-- Find tasks without results
SELECT 
    t.id,
    rt.name as template_name,
    t.status,
    t.scheduled_at,
    t.finished_at
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
LEFT JOIN TaskResult tr ON t.id = tr.task_id
WHERE t.status IN ('completed', 'failed')
  AND tr.id IS NULL
ORDER BY t.finished_at DESC;

-- Count records per table
SELECT 'ReportTemplate' as table_name, COUNT(*) as row_count FROM ReportTemplate
UNION ALL
SELECT 'Task', COUNT(*) FROM Task
UNION ALL
SELECT 'TaskResult', COUNT(*) FROM TaskResult;

-- ====================================
-- 6. USEFUL ADMINISTRATIVE QUERIES
-- ====================================

-- Database size
SELECT pg_size_pretty(pg_database_size('reporting')) as database_size;

-- Table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;


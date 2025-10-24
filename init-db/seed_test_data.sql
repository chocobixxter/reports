-- ====================================
-- Test Data Seeding Script
-- ====================================
-- This script populates the database with comprehensive test data
-- for development and testing purposes
-- ====================================

-- Clear existing data (if any)
TRUNCATE TABLE TaskResult CASCADE;
TRUNCATE TABLE Task CASCADE;
TRUNCATE TABLE ReportTemplate CASCADE;
ALTER SEQUENCE reporttemplate_id_seq RESTART WITH 1;
ALTER SEQUENCE task_id_seq RESTART WITH 1;
ALTER SEQUENCE taskresult_id_seq RESTART WITH 1;

-- ====================================
-- Insert Report Templates
-- ====================================

INSERT INTO ReportTemplate (name, sql, period, created_at, updated_at) VALUES
-- Daily Reports
('Daily Sales Summary', 
 'SELECT DATE(created_at) as date, COUNT(*) as total_sales, SUM(amount) as revenue FROM sales WHERE created_at >= CURRENT_DATE GROUP BY DATE(created_at)', 
 'daily',
 CURRENT_TIMESTAMP - INTERVAL '30 days',
 CURRENT_TIMESTAMP - INTERVAL '5 days'),

('Daily Active Users',
 'SELECT DATE(login_time) as date, COUNT(DISTINCT user_id) as active_users FROM user_sessions WHERE login_time >= CURRENT_DATE GROUP BY DATE(login_time)',
 'daily',
 CURRENT_TIMESTAMP - INTERVAL '25 days',
 CURRENT_TIMESTAMP - INTERVAL '3 days'),

('Daily Error Log',
 'SELECT DATE(occurred_at) as date, error_type, COUNT(*) as count FROM error_logs WHERE occurred_at >= CURRENT_DATE GROUP BY DATE(occurred_at), error_type ORDER BY count DESC',
 'daily',
 CURRENT_TIMESTAMP - INTERVAL '20 days',
 CURRENT_TIMESTAMP - INTERVAL '2 days'),

-- Weekly Reports
('Weekly Revenue Report',
 'SELECT DATE_TRUNC(''week'', created_at) as week, department, SUM(amount) as total_revenue FROM sales WHERE created_at >= DATE_TRUNC(''week'', CURRENT_DATE) - INTERVAL ''4 weeks'' GROUP BY week, department ORDER BY week DESC',
 'weekly',
 CURRENT_TIMESTAMP - INTERVAL '60 days',
 CURRENT_TIMESTAMP - INTERVAL '7 days'),

('Weekly User Engagement',
 'SELECT DATE_TRUNC(''week'', action_time) as week, action_type, COUNT(*) as actions FROM user_actions WHERE action_time >= DATE_TRUNC(''week'', CURRENT_DATE) - INTERVAL ''4 weeks'' GROUP BY week, action_type',
 'weekly',
 CURRENT_TIMESTAMP - INTERVAL '45 days',
 CURRENT_TIMESTAMP - INTERVAL '10 days'),

('Weekly Performance Metrics',
 'SELECT DATE_TRUNC(''week'', timestamp) as week, AVG(response_time) as avg_response_time, MAX(response_time) as max_response_time FROM api_logs WHERE timestamp >= DATE_TRUNC(''week'', CURRENT_DATE) - INTERVAL ''4 weeks'' GROUP BY week',
 'weekly',
 CURRENT_TIMESTAMP - INTERVAL '50 days',
 CURRENT_TIMESTAMP - INTERVAL '8 days'),

-- Monthly Reports
('Monthly Financial Summary',
 'SELECT DATE_TRUNC(''month'', transaction_date) as month, category, SUM(amount) as total, COUNT(*) as transaction_count FROM transactions WHERE transaction_date >= DATE_TRUNC(''month'', CURRENT_DATE) - INTERVAL ''6 months'' GROUP BY month, category ORDER BY month DESC',
 'monthly',
 CURRENT_TIMESTAMP - INTERVAL '180 days',
 CURRENT_TIMESTAMP - INTERVAL '15 days'),

('Monthly Customer Growth',
 'SELECT DATE_TRUNC(''month'', registration_date) as month, COUNT(*) as new_customers, COUNT(*) FILTER (WHERE subscription_type = ''premium'') as premium_customers FROM customers WHERE registration_date >= DATE_TRUNC(''month'', CURRENT_DATE) - INTERVAL ''12 months'' GROUP BY month ORDER BY month DESC',
 'monthly',
 CURRENT_TIMESTAMP - INTERVAL '150 days',
 CURRENT_TIMESTAMP - INTERVAL '20 days'),

('Monthly System Health',
 'SELECT DATE_TRUNC(''month'', check_time) as month, AVG(cpu_usage) as avg_cpu, AVG(memory_usage) as avg_memory, AVG(disk_usage) as avg_disk FROM system_metrics WHERE check_time >= DATE_TRUNC(''month'', CURRENT_DATE) - INTERVAL ''6 months'' GROUP BY month',
 'monthly',
 CURRENT_TIMESTAMP - INTERVAL '120 days',
 CURRENT_TIMESTAMP - INTERVAL '25 days'),

-- Hourly Reports
('Hourly Traffic Monitor',
 'SELECT DATE_TRUNC(''hour'', request_time) as hour, COUNT(*) as request_count, COUNT(DISTINCT ip_address) as unique_visitors FROM access_logs WHERE request_time >= CURRENT_TIMESTAMP - INTERVAL ''24 hours'' GROUP BY hour ORDER BY hour DESC',
 'hourly',
 CURRENT_TIMESTAMP - INTERVAL '10 days',
 CURRENT_TIMESTAMP - INTERVAL '1 day'),

('Hourly Transaction Volume',
 'SELECT DATE_TRUNC(''hour'', created_at) as hour, COUNT(*) as transaction_count, SUM(amount) as volume FROM transactions WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL ''24 hours'' GROUP BY hour ORDER BY hour DESC',
 'hourly',
 CURRENT_TIMESTAMP - INTERVAL '8 days',
 CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- Custom Period Reports
('Quarterly Business Review',
 'SELECT DATE_TRUNC(''quarter'', order_date) as quarter, product_category, SUM(revenue) as total_revenue, COUNT(*) as order_count FROM orders WHERE order_date >= DATE_TRUNC(''quarter'', CURRENT_DATE) - INTERVAL ''2 years'' GROUP BY quarter, product_category ORDER BY quarter DESC, total_revenue DESC',
 'quarterly',
 CURRENT_TIMESTAMP - INTERVAL '200 days',
 CURRENT_TIMESTAMP - INTERVAL '30 days'),

('Annual Performance Report',
 'SELECT DATE_TRUNC(''year'', fiscal_date) as year, department, SUM(budget_spent) as spent, SUM(budget_allocated) as allocated, (SUM(budget_allocated) - SUM(budget_spent)) as remaining FROM budget_data WHERE fiscal_date >= DATE_TRUNC(''year'', CURRENT_DATE) - INTERVAL ''3 years'' GROUP BY year, department ORDER BY year DESC',
 'yearly',
 CURRENT_TIMESTAMP - INTERVAL '365 days',
 CURRENT_TIMESTAMP - INTERVAL '60 days'),

-- Real-time Reports
('Real-time System Status',
 'SELECT service_name, status, last_heartbeat, response_time_ms FROM service_health WHERE last_heartbeat >= CURRENT_TIMESTAMP - INTERVAL ''5 minutes'' ORDER BY service_name',
 'real-time',
 CURRENT_TIMESTAMP - INTERVAL '5 days',
 CURRENT_TIMESTAMP),

('Real-time Alert Monitor',
 'SELECT severity, alert_type, COUNT(*) as count FROM alerts WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL ''15 minutes'' AND status = ''active'' GROUP BY severity, alert_type ORDER BY severity DESC',
 'real-time',
 CURRENT_TIMESTAMP - INTERVAL '3 days',
 CURRENT_TIMESTAMP);

-- ====================================
-- Insert Tasks with Various Statuses
-- ====================================

-- Completed tasks (past)
INSERT INTO Task (report_template_id, scheduled_at, status, finished_at, result_code, created_at, updated_at) VALUES
(1, CURRENT_TIMESTAMP - INTERVAL '5 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '2 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '2 minutes'),
(1, CURRENT_TIMESTAMP - INTERVAL '4 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '1 minute', 'success', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '1 minute'),
(1, CURRENT_TIMESTAMP - INTERVAL '3 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '3 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '3 minutes'),
(2, CURRENT_TIMESTAMP - INTERVAL '5 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '5 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '5 minutes'),
(2, CURRENT_TIMESTAMP - INTERVAL '4 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '4 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '4 minutes'),
(3, CURRENT_TIMESTAMP - INTERVAL '6 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '6 days', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 minutes'),

-- Weekly reports completed
(4, CURRENT_TIMESTAMP - INTERVAL '14 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '10 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '14 days', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '10 minutes'),
(4, CURRENT_TIMESTAMP - INTERVAL '7 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '8 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '8 minutes'),
(5, CURRENT_TIMESTAMP - INTERVAL '7 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '6 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '6 minutes'),

-- Monthly reports completed
(7, CURRENT_TIMESTAMP - INTERVAL '60 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '60 days' + INTERVAL '15 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_TIMESTAMP - INTERVAL '60 days' + INTERVAL '15 minutes'),
(7, CURRENT_TIMESTAMP - INTERVAL '30 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '12 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '12 minutes'),
(8, CURRENT_TIMESTAMP - INTERVAL '30 days', 'completed', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '20 minutes', 'success', CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '20 minutes'),

-- Failed tasks
(1, CURRENT_TIMESTAMP - INTERVAL '2 days', 'failed', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '30 seconds', 'error_timeout', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '30 seconds'),
(3, CURRENT_TIMESTAMP - INTERVAL '1 day', 'failed', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '5 seconds', 'error_database_connection', CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '5 seconds'),
(10, CURRENT_TIMESTAMP - INTERVAL '12 hours', 'failed', CURRENT_TIMESTAMP - INTERVAL '12 hours' + INTERVAL '10 seconds', 'error_invalid_query', CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP - INTERVAL '12 hours' + INTERVAL '10 seconds'),

-- Running tasks
(10, CURRENT_TIMESTAMP - INTERVAL '5 minutes', 'running', NULL, NULL, CURRENT_TIMESTAMP - INTERVAL '5 minutes', CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
(14, CURRENT_TIMESTAMP - INTERVAL '2 minutes', 'running', NULL, NULL, CURRENT_TIMESTAMP - INTERVAL '2 minutes', CURRENT_TIMESTAMP - INTERVAL '2 minutes'),

-- Pending tasks (scheduled for future)
(1, CURRENT_TIMESTAMP + INTERVAL '1 hour', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, CURRENT_TIMESTAMP + INTERVAL '2 hours', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, CURRENT_TIMESTAMP + INTERVAL '3 hours', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, CURRENT_TIMESTAMP + INTERVAL '1 day', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, CURRENT_TIMESTAMP + INTERVAL '2 days', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, CURRENT_TIMESTAMP + INTERVAL '3 days', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, CURRENT_TIMESTAMP + INTERVAL '7 days', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, CURRENT_TIMESTAMP + INTERVAL '14 days', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(10, CURRENT_TIMESTAMP + INTERVAL '30 minutes', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(11, CURRENT_TIMESTAMP + INTERVAL '45 minutes', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(14, CURRENT_TIMESTAMP + INTERVAL '5 minutes', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(15, CURRENT_TIMESTAMP + INTERVAL '10 minutes', 'pending', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Scheduled tasks (future, explicitly marked as scheduled)
(12, CURRENT_TIMESTAMP + INTERVAL '90 days', 'scheduled', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(13, CURRENT_TIMESTAMP + INTERVAL '365 days', 'scheduled', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ====================================
-- Insert Task Results for Completed Tasks
-- ====================================

-- Daily Sales Summary results
INSERT INTO TaskResult (task_id, result, created_at, updated_at) VALUES
(1, '{
  "execution_time_ms": 1245,
  "rows_returned": 1,
  "status": "success",
  "data": {
    "total_sales": 342,
    "revenue": 45678.90,
    "date": "2025-10-19"
  },
  "metadata": {
    "query_plan": "Index Scan",
    "cache_hit": false
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '2 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '2 minutes'),

(2, '{
  "execution_time_ms": 987,
  "rows_returned": 1,
  "status": "success",
  "data": {
    "total_sales": 389,
    "revenue": 52341.20,
    "date": "2025-10-20"
  },
  "metadata": {
    "query_plan": "Index Scan",
    "cache_hit": true
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '1 minute', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '1 minute'),

(3, '{
  "execution_time_ms": 1102,
  "rows_returned": 1,
  "status": "success",
  "data": {
    "total_sales": 401,
    "revenue": 58923.45,
    "date": "2025-10-21"
  },
  "metadata": {
    "query_plan": "Index Scan",
    "cache_hit": false
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '3 minutes', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '3 minutes'),

-- Daily Active Users results
(4, '{
  "execution_time_ms": 2341,
  "rows_returned": 1,
  "status": "success",
  "data": {
    "active_users": 1523,
    "date": "2025-10-19"
  },
  "metadata": {
    "query_plan": "Hash Aggregate",
    "cache_hit": false,
    "peak_users_hour": "14:00"
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '5 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '5 minutes'),

(5, '{
  "execution_time_ms": 2156,
  "rows_returned": 1,
  "status": "success",
  "data": {
    "active_users": 1678,
    "date": "2025-10-20"
  },
  "metadata": {
    "query_plan": "Hash Aggregate",
    "cache_hit": true,
    "peak_users_hour": "15:00"
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '4 minutes', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '4 minutes'),

-- Daily Error Log results
(6, '{
  "execution_time_ms": 876,
  "rows_returned": 5,
  "status": "success",
  "data": [
    {"error_type": "HTTP_500", "count": 23, "date": "2025-10-18"},
    {"error_type": "HTTP_404", "count": 145, "date": "2025-10-18"},
    {"error_type": "DATABASE_TIMEOUT", "count": 8, "date": "2025-10-18"},
    {"error_type": "AUTH_FAILED", "count": 34, "date": "2025-10-18"},
    {"error_type": "VALIDATION_ERROR", "count": 67, "date": "2025-10-18"}
  ],
  "metadata": {
    "total_errors": 277,
    "critical_errors": 31
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 minutes', CURRENT_TIMESTAMP - INTERVAL '6 days' + INTERVAL '2 minutes'),

-- Weekly Revenue Report results
(7, '{
  "execution_time_ms": 5432,
  "rows_returned": 12,
  "status": "success",
  "data": [
    {"week": "2025-10-06", "department": "Sales", "total_revenue": 234567.89},
    {"week": "2025-10-06", "department": "Marketing", "total_revenue": 89234.56},
    {"week": "2025-10-06", "department": "Engineering", "total_revenue": 45678.90},
    {"week": "2025-10-06", "department": "Support", "total_revenue": 23456.78}
  ],
  "metadata": {
    "total_revenue": 393938.13,
    "departments_count": 4,
    "growth_percentage": 12.5
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '10 minutes', CURRENT_TIMESTAMP - INTERVAL '14 days' + INTERVAL '10 minutes'),

(8, '{
  "execution_time_ms": 4987,
  "rows_returned": 12,
  "status": "success",
  "data": [
    {"week": "2025-10-13", "department": "Sales", "total_revenue": 267890.12},
    {"week": "2025-10-13", "department": "Marketing", "total_revenue": 95432.10},
    {"week": "2025-10-13", "department": "Engineering", "total_revenue": 52341.67},
    {"week": "2025-10-13", "department": "Support", "total_revenue": 28934.56}
  ],
  "metadata": {
    "total_revenue": 444598.45,
    "departments_count": 4,
    "growth_percentage": 15.8
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '8 minutes', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '8 minutes'),

-- Weekly User Engagement results
(9, '{
  "execution_time_ms": 3456,
  "rows_returned": 8,
  "status": "success",
  "data": [
    {"week": "2025-10-13", "action_type": "login", "actions": 8934},
    {"week": "2025-10-13", "action_type": "page_view", "actions": 45678},
    {"week": "2025-10-13", "action_type": "purchase", "actions": 1234},
    {"week": "2025-10-13", "action_type": "share", "actions": 567},
    {"week": "2025-10-13", "action_type": "comment", "actions": 2345},
    {"week": "2025-10-13", "action_type": "like", "actions": 12345}
  ],
  "metadata": {
    "total_actions": 71103,
    "unique_users": 5678,
    "avg_actions_per_user": 12.5
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '6 minutes', CURRENT_TIMESTAMP - INTERVAL '7 days' + INTERVAL '6 minutes'),

-- Monthly Financial Summary results
(10, '{
  "execution_time_ms": 8765,
  "rows_returned": 18,
  "status": "success",
  "data": [
    {"month": "2025-08-01", "category": "Revenue", "total": 1234567.89, "transaction_count": 5432},
    {"month": "2025-08-01", "category": "Expenses", "total": 876543.21, "transaction_count": 3210},
    {"month": "2025-08-01", "category": "Investments", "total": 234567.89, "transaction_count": 123}
  ],
  "metadata": {
    "net_profit": 357024.68,
    "profit_margin": 28.9,
    "categories_count": 3
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '60 days' + INTERVAL '15 minutes', CURRENT_TIMESTAMP - INTERVAL '60 days' + INTERVAL '15 minutes'),

(11, '{
  "execution_time_ms": 9234,
  "rows_returned": 18,
  "status": "success",
  "data": [
    {"month": "2025-09-01", "category": "Revenue", "total": 1456789.12, "transaction_count": 6234},
    {"month": "2025-09-01", "category": "Expenses", "total": 923456.78, "transaction_count": 3567},
    {"month": "2025-09-01", "category": "Investments", "total": 345678.90, "transaction_count": 156}
  ],
  "metadata": {
    "net_profit": 533332.34,
    "profit_margin": 36.6,
    "categories_count": 3
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '12 minutes', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '12 minutes'),

-- Monthly Customer Growth results
(12, '{
  "execution_time_ms": 4321,
  "rows_returned": 1,
  "status": "success",
  "data": {
    "month": "2025-09-01",
    "new_customers": 1234,
    "premium_customers": 456,
    "conversion_rate": 36.95
  },
  "metadata": {
    "total_customers": 45678,
    "growth_percentage": 2.78,
    "churn_rate": 1.2
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '20 minutes', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '20 minutes');

-- Failed task results (partial/error results)
INSERT INTO TaskResult (task_id, result, created_at, updated_at) VALUES
(13, '{
  "execution_time_ms": 30000,
  "rows_returned": 0,
  "status": "error",
  "error": {
    "code": "TIMEOUT",
    "message": "Query execution exceeded 30 second timeout",
    "timestamp": "2025-10-22T10:15:30Z"
  },
  "metadata": {
    "retry_count": 3,
    "last_retry": "2025-10-22T10:15:00Z"
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '30 seconds', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '30 seconds'),

(14, '{
  "execution_time_ms": 5000,
  "rows_returned": 0,
  "status": "error",
  "error": {
    "code": "DATABASE_CONNECTION_ERROR",
    "message": "Could not establish connection to database",
    "details": "Connection timeout after 5 seconds",
    "timestamp": "2025-10-23T14:22:05Z"
  },
  "metadata": {
    "retry_count": 1,
    "connection_pool_status": "exhausted"
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '5 seconds', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '5 seconds'),

(15, '{
  "execution_time_ms": 100,
  "rows_returned": 0,
  "status": "error",
  "error": {
    "code": "INVALID_QUERY",
    "message": "Syntax error in SQL query",
    "details": "ERROR: column \"invalid_column\" does not exist",
    "line": 1,
    "position": 45,
    "timestamp": "2025-10-24T02:10:10Z"
  }
}'::jsonb, CURRENT_TIMESTAMP - INTERVAL '12 hours' + INTERVAL '10 seconds', CURRENT_TIMESTAMP - INTERVAL '12 hours' + INTERVAL '10 seconds');

-- ====================================
-- Summary Information
-- ====================================

DO $$
DECLARE
    template_count INTEGER;
    task_count INTEGER;
    result_count INTEGER;
    completed_tasks INTEGER;
    failed_tasks INTEGER;
    pending_tasks INTEGER;
    running_tasks INTEGER;
BEGIN
    SELECT COUNT(*) INTO template_count FROM ReportTemplate;
    SELECT COUNT(*) INTO task_count FROM Task;
    SELECT COUNT(*) INTO result_count FROM TaskResult;
    SELECT COUNT(*) INTO completed_tasks FROM Task WHERE status = 'completed';
    SELECT COUNT(*) INTO failed_tasks FROM Task WHERE status = 'failed';
    SELECT COUNT(*) INTO pending_tasks FROM Task WHERE status = 'pending';
    SELECT COUNT(*) INTO running_tasks FROM Task WHERE status = 'running';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Data Seeding Complete!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Report Templates: %', template_count;
    RAISE NOTICE 'Total Tasks: %', task_count;
    RAISE NOTICE '  - Completed: %', completed_tasks;
    RAISE NOTICE '  - Failed: %', failed_tasks;
    RAISE NOTICE '  - Running: %', running_tasks;
    RAISE NOTICE '  - Pending: %', pending_tasks;
    RAISE NOTICE 'Task Results: %', result_count;
    RAISE NOTICE '========================================';
END $$;


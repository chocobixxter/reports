#!/bin/bash

# ====================================
# Database Data Verification Script
# ====================================
# This script displays summary information about the database contents
# ====================================

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Database Data Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Docker container is running
if ! docker ps | grep -q "reporting-db"; then
    echo -e "${RED}Error: Database container 'reporting-db' is not running${NC}"
    echo -e "${YELLOW}Please start the database first with: docker-compose up -d${NC}"
    exit 1
fi

# Display report templates
echo -e "${BLUE}Report Templates:${NC}"
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    id,
    name,
    period,
    LENGTH(sql) as sql_length,
    created_at::date as created
FROM ReportTemplate 
ORDER BY id;" | head -20

echo ""

# Display task status summary
echo -e "${BLUE}Task Status Summary:${NC}"
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    status,
    COUNT(*) as count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage
FROM Task 
GROUP BY status 
ORDER BY count DESC;"

echo ""

# Display recent tasks
echo -e "${BLUE}Recent Tasks (Last 10):${NC}"
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    t.id,
    rt.name as template,
    t.status,
    t.scheduled_at::timestamp(0) as scheduled,
    t.result_code
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
ORDER BY t.created_at DESC
LIMIT 10;"

echo ""

# Display task results summary
echo -e "${BLUE}Task Results Summary:${NC}"
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    COUNT(*) as total_results,
    COUNT(*) FILTER (WHERE result->>'status' = 'success') as successful,
    COUNT(*) FILTER (WHERE result->>'status' = 'error') as errors,
    AVG((result->>'execution_time_ms')::numeric) as avg_execution_time_ms
FROM TaskResult;"

echo ""

# Display table sizes
echo -e "${BLUE}Table Sizes:${NC}"
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('public.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size('public.'||tablename) DESC;"

echo ""

# Display scheduled tasks for next 24 hours
echo -e "${BLUE}Upcoming Tasks (Next 24 hours):${NC}"
docker exec reporting-db psql -U reporting_user -d reporting -c "
SELECT 
    t.id,
    rt.name as template,
    rt.period,
    t.scheduled_at::timestamp(0) as scheduled,
    t.status
FROM Task t
JOIN ReportTemplate rt ON t.report_template_id = rt.id
WHERE t.scheduled_at BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '24 hours'
ORDER BY t.scheduled_at
LIMIT 10;"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Verification Complete${NC}"
echo -e "${GREEN}========================================${NC}"


#!/bin/bash

# ====================================
# Quick Query Script
# ====================================
# Run predefined queries quickly
# ====================================

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker container is running
if ! docker ps | grep -q "reporting-db"; then
    echo -e "${RED}Error: Database container 'reporting-db' is not running${NC}"
    echo -e "${YELLOW}Please start the database first with: docker-compose up -d${NC}"
    exit 1
fi

# Menu
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Quick Query Menu${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "1) List all report templates"
echo "2) Show task status summary"
echo "3) Show recent tasks (last 10)"
echo "4) Show pending tasks"
echo "5) Show failed tasks with errors"
echo "6) Show task execution statistics"
echo "7) Show upcoming tasks (next 24h)"
echo "8) Show running tasks"
echo "9) Show successful task results"
echo "10) Custom SQL query"
echo "0) Exit"
echo ""

read -p "Select option (0-10): " choice

case $choice in
    1)
        echo -e "${BLUE}Report Templates:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT id, name, period, created_at::date 
            FROM ReportTemplate 
            ORDER BY id;"
        ;;
    2)
        echo -e "${BLUE}Task Status Summary:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                status,
                COUNT(*) as count,
                ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
            FROM Task 
            GROUP BY status 
            ORDER BY count DESC;"
        ;;
    3)
        echo -e "${BLUE}Recent Tasks:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                t.id,
                rt.name as template,
                t.status,
                t.scheduled_at::timestamp(0),
                t.result_code
            FROM Task t
            JOIN ReportTemplate rt ON t.report_template_id = rt.id
            ORDER BY t.created_at DESC
            LIMIT 10;"
        ;;
    4)
        echo -e "${BLUE}Pending Tasks:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                t.id,
                rt.name as template,
                rt.period,
                t.scheduled_at::timestamp(0),
                CASE 
                    WHEN t.scheduled_at <= CURRENT_TIMESTAMP 
                    THEN 'OVERDUE' 
                    ELSE 'SCHEDULED' 
                END as status
            FROM Task t
            JOIN ReportTemplate rt ON t.report_template_id = rt.id
            WHERE t.status = 'pending'
            ORDER BY t.scheduled_at;"
        ;;
    5)
        echo -e "${BLUE}Failed Tasks:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                t.id,
                rt.name as template,
                t.result_code,
                tr.result->'error'->>'message' as error_message,
                t.finished_at::timestamp(0)
            FROM Task t
            JOIN ReportTemplate rt ON t.report_template_id = rt.id
            LEFT JOIN TaskResult tr ON t.id = tr.task_id
            WHERE t.status = 'failed'
            ORDER BY t.finished_at DESC;"
        ;;
    6)
        echo -e "${BLUE}Task Execution Statistics:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                rt.name as template,
                COUNT(tr.id) as executions,
                ROUND(AVG((tr.result->>'execution_time_ms')::numeric), 2) as avg_ms,
                ROUND(MIN((tr.result->>'execution_time_ms')::numeric), 2) as min_ms,
                ROUND(MAX((tr.result->>'execution_time_ms')::numeric), 2) as max_ms
            FROM ReportTemplate rt
            JOIN Task t ON rt.id = t.report_template_id
            JOIN TaskResult tr ON t.id = tr.task_id
            WHERE tr.result->>'status' = 'success'
            GROUP BY rt.name
            ORDER BY avg_ms DESC;"
        ;;
    7)
        echo -e "${BLUE}Upcoming Tasks (Next 24 hours):${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                t.id,
                rt.name as template,
                rt.period,
                t.scheduled_at::timestamp(0),
                t.status
            FROM Task t
            JOIN ReportTemplate rt ON t.report_template_id = rt.id
            WHERE t.scheduled_at BETWEEN CURRENT_TIMESTAMP 
                AND CURRENT_TIMESTAMP + INTERVAL '24 hours'
            ORDER BY t.scheduled_at;"
        ;;
    8)
        echo -e "${BLUE}Running Tasks:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                t.id,
                rt.name as template,
                t.scheduled_at::timestamp(0),
                ROUND(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - t.scheduled_at)), 2) as running_seconds
            FROM Task t
            JOIN ReportTemplate rt ON t.report_template_id = rt.id
            WHERE t.status = 'running'
            ORDER BY t.scheduled_at;"
        ;;
    9)
        echo -e "${BLUE}Successful Task Results:${NC}"
        docker exec reporting-db psql -U reporting_user -d reporting -c "
            SELECT 
                rt.name as template,
                (tr.result->>'execution_time_ms')::numeric as exec_ms,
                (tr.result->>'rows_returned')::numeric as rows,
                tr.created_at::timestamp(0)
            FROM TaskResult tr
            JOIN Task t ON tr.task_id = t.id
            JOIN ReportTemplate rt ON t.report_template_id = rt.id
            WHERE tr.result->>'status' = 'success'
            ORDER BY tr.created_at DESC
            LIMIT 10;"
        ;;
    10)
        echo -e "${YELLOW}Enter your SQL query (end with semicolon):${NC}"
        read -p "> " sql_query
        docker exec -it reporting-db psql -U reporting_user -d reporting -c "$sql_query"
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac


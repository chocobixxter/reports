#!/bin/bash

# ====================================
# Database Seeding Script
# ====================================
# This script populates the reporting database with test data
# ====================================

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Database Seeding Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Docker container is running
if ! docker ps | grep -q "reporting-db"; then
    echo -e "${RED}Error: Database container 'reporting-db' is not running${NC}"
    echo -e "${YELLOW}Please start the database first with: docker-compose up -d${NC}"
    exit 1
fi

# Check database connection
echo -e "${YELLOW}Checking database connection...${NC}"
if ! docker exec reporting-db pg_isready -U reporting_user -d reporting > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to database${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Database connection OK${NC}"
echo ""

# Ask for confirmation
echo -e "${YELLOW}WARNING: This will delete all existing data and populate with test data!${NC}"
read -p "Do you want to continue? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

# Run the seeding script
echo -e "${YELLOW}Seeding database with test data...${NC}"
docker exec -i reporting-db psql -U reporting_user -d reporting < init-db/seed_test_data.sql

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Database seeded successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}You can now connect to the database:${NC}"
    echo "  docker exec -it reporting-db psql -U reporting_user -d reporting"
    echo ""
    echo -e "${YELLOW}Or query the data:${NC}"
    echo "  SELECT COUNT(*) FROM ReportTemplate;"
    echo "  SELECT COUNT(*) FROM Task;"
    echo "  SELECT COUNT(*) FROM TaskResult;"
else
    echo -e "${RED}Error: Failed to seed database${NC}"
    exit 1
fi


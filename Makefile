.PHONY: help start stop restart clean seed verify query connect logs status backup

# Default target
help:
	@echo "Reporting Database - Available Commands"
	@echo "========================================"
	@echo ""
	@echo "Database Management:"
	@echo "  make start      - Start the database container"
	@echo "  make stop       - Stop the database container"
	@echo "  make restart    - Restart the database container"
	@echo "  make clean      - Stop and remove all data (destructive!)"
	@echo "  make status     - Show container status"
	@echo "  make logs       - Show database logs (Ctrl+C to exit)"
	@echo ""
	@echo "Data Management:"
	@echo "  make seed       - Populate database with test data"
	@echo "  make verify     - Show database summary"
	@echo "  make query      - Interactive query menu"
	@echo ""
	@echo "Database Access:"
	@echo "  make connect    - Connect to database with psql"
	@echo "  make backup     - Create database backup"
	@echo ""
	@echo "Quick Start:"
	@echo "  make start seed verify"
	@echo ""

# Start the database
start:
	@echo "Starting database..."
	docker-compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 3
	@docker exec reporting-db pg_isready -U reporting_user -d reporting || true
	@echo "Database started!"

# Stop the database
stop:
	@echo "Stopping database..."
	docker-compose down
	@echo "Database stopped!"

# Restart the database
restart:
	@echo "Restarting database..."
	docker-compose restart
	@sleep 2
	@docker exec reporting-db pg_isready -U reporting_user -d reporting
	@echo "Database restarted!"

# Clean everything (WARNING: destroys all data)
clean:
	@echo "WARNING: This will delete ALL database data!"
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "Stopping and removing all data..."; \
		docker-compose down -v; \
		echo "All data removed!"; \
	else \
		echo "Cancelled."; \
	fi

# Show container status
status:
	@echo "Container Status:"
	@docker-compose ps
	@echo ""
	@echo "Database Health:"
	@docker exec reporting-db pg_isready -U reporting_user -d reporting 2>/dev/null && echo "✓ Database is ready" || echo "✗ Database is not ready"

# Show logs
logs:
	docker-compose logs -f postgres

# Seed database with test data
seed:
	@echo "Seeding database with test data..."
	./seed-database.sh

# Verify database contents
verify:
	@echo "Verifying database contents..."
	./verify-data.sh

# Interactive query menu
query:
	./quick-query.sh

# Connect to database with psql
connect:
	@echo "Connecting to database..."
	@echo "Type \\q to exit"
	@echo ""
	docker exec -it reporting-db psql -U reporting_user -d reporting

# Create backup
backup:
	@echo "Creating database backup..."
	@mkdir -p backups
	@filename="backups/backup_$$(date +%Y%m%d_%H%M%S).sql"; \
	docker exec reporting-db pg_dump -U reporting_user reporting > $$filename; \
	echo "Backup created: $$filename"


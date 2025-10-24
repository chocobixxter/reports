-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create ReportTemplate table
CREATE TABLE ReportTemplate (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sql TEXT NOT NULL,
    period VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger for ReportTemplate
CREATE TRIGGER update_reporttemplate_updated_at
    BEFORE UPDATE ON ReportTemplate
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create Task table
CREATE TABLE Task (
    id SERIAL PRIMARY KEY,
    report_template_id INTEGER NOT NULL,
    scheduled_at TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    finished_at TIMESTAMP,
    result_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_report_template
        FOREIGN KEY (report_template_id)
        REFERENCES ReportTemplate(id)
        ON DELETE CASCADE
);

-- Create trigger for Task
CREATE TRIGGER update_task_updated_at
    BEFORE UPDATE ON Task
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create TaskResult table
CREATE TABLE TaskResult (
    id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL,
    result JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_task
        FOREIGN KEY (task_id)
        REFERENCES Task(id)
        ON DELETE CASCADE
);

-- Create trigger for TaskResult
CREATE TRIGGER update_taskresult_updated_at
    BEFORE UPDATE ON TaskResult
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for better query performance
CREATE INDEX idx_task_report_template_id ON Task(report_template_id);
CREATE INDEX idx_task_status ON Task(status);
CREATE INDEX idx_task_scheduled_at ON Task(scheduled_at);
CREATE INDEX idx_taskresult_task_id ON TaskResult(task_id);

-- Insert sample data (optional, for testing)
INSERT INTO ReportTemplate (name, sql, period) VALUES
    ('Daily Sales Report', 'SELECT * FROM sales WHERE date = CURRENT_DATE', 'daily'),
    ('Weekly User Activity', 'SELECT user_id, COUNT(*) FROM activities WHERE week = DATE_TRUNC(''week'', CURRENT_DATE) GROUP BY user_id', 'weekly'),
    ('Monthly Revenue', 'SELECT SUM(amount) FROM transactions WHERE month = DATE_TRUNC(''month'', CURRENT_DATE)', 'monthly');

INSERT INTO Task (report_template_id, scheduled_at, status) VALUES
    (1, CURRENT_TIMESTAMP, 'pending'),
    (2, CURRENT_TIMESTAMP + INTERVAL '1 hour', 'pending'),
    (3, CURRENT_TIMESTAMP + INTERVAL '1 day', 'scheduled');


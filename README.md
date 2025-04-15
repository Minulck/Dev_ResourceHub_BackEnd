# Resource_Hub

## Configuration for `backend.resourcehubservices`

Configure the application using environment variables. Create a `Config.toml` file in the "Ballerina\Config.toml" directory or set the variables directly in your environment.

```dotenv
[backend.resourcehubservices]

# Database configuration
USER="your_database_user"
PASSWORD="your_database_password"
HOST="localhost"
PORT="your_database_port" # e.g., 5432 for PostgreSQL
DATABASE="your_database_name"

# SMTP server configuration
SMTP_HOST="your_smtp_host"
SMTP_PORT="your_smtp_port" # e.g., 587
SMTP_USER="your_smtp_username"
SMTP_PASSWORD="your_smtp_password"

# API keys
PDFSHIFT_API_KEY="your_pdfshift_api_key"
```
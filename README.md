# Resource Hub – Backend

The **Resource Hub Backend** is a Ballerina-based API service that manages organizational resources including meals, assets, maintenance requests, and user management. It serves as the backend for the Resource Hub application and provides secure, role-based functionality for both Admins and Users.

---

## Features

* **Authentication & Authorization**

  * JWT-based user login and access control for Admin/User roles
* **Meal Management**

  * APIs for managing meal types, meal times, and user meal requests
* **Asset Management**

  * Asset request, tracking, and CRUD operations by Admins
* **Maintenance Management**

  * Submit and manage maintenance tasks with priority and status tracking
* **User Management**

  * User profile management and admin-level user control
* **Dashboard Analytics**

  * Data endpoints for both Admin and User dashboards
* **Email Notifications**

  * SMTP-based notifications (e.g., password reset, updates)
* **Reporting Support**

  * API-level hooks for PDF or CSV report generation

---

## Tech Stack

* **Language:** Ballerina
* **Runtime:** Ballerina HTTP module
* **Database:** MySQL
* **Config Management:** Ballerina `Config.toml`
* **Email:** SMTP (via `smtpconnect.bal`)
* **Testing:** Ballerina built-in test framework
* **Docs:** OpenAPI (auto-generated if enabled)

---

## Project Structure

```
/resource_hub_backend/
├── Ballerina.toml
├── main.bal
├── Config.toml
└── modules/
    └── resourcehubservices/
        ├── assetrequestingservice.bal
        ├── assetservice.bal
        ├── calanderservice.bal
        ├── dashboardadminservice.bal
        ├── dashboarduserservice.bal
        ├── dbconnect.bal
        ├── emailservice.bal
        ├── login.bal
        ├── maintenanceservice.bal
        ├── mealtimeservice.bal
        ├── mealtypeservice.bal
        ├── profilesettingsservice.bal
        ├── smtpconnect.bal
        └── userservice.bal
```

---

## Setup and Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/FiveStackDev/Resource_Hub_Backend.git
   cd Resource_Hub_Backend
   ```

2. **Configure the application**

   * Create or edit the `Config.toml` file inside the root directory with the following content:

   ```toml
   [backend.resourcehubservices]

   # Database configuration
   USER = "your_database_user"
   PASSWORD = "your_database_password"
   HOST = "localhost"
   PORT = "3306"  # MySQL default port
   DATABASE = "your_database_name"

   # SMTP server configuration
   SMTP_HOST = "your_smtp_host"
   SMTP_PORT = "587"
   SMTP_USER = "your_smtp_username"
   SMTP_PASSWORD = "your_smtp_password"

   # API keys
   PDFSHIFT_API_KEY = "your_pdfshift_api_key"
   ```

3. **Set up the database**

   * add this ti the Ballerina.toml file

     ```bash
     [[platform.java11.dependency]]
      groupId = "mysql"
      artifactId = "mysql-connector-java"
      version = "8.0.26"
     ```

---

## Running the Project

Run the application using Ballerina:

```bash
bal run
```

The service will be available at:
`http://localhost:9090`

---

---

## Building for Production

```bash
bal build
```

---

## Testing

```bash
bal test
```

---

## Database Schema

The following diagram illustrates the database schema used in Resource Hub:

![Database Schema](https://github.com/user-attachments/assets/e088cbaa-932e-4030-a9ce-941d1d92ca4c)

---

Would you like this saved as a `README.md` file or need help generating `init.sql` based on this schema?

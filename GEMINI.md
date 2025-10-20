# Project: Mangroves

## Project Overview

This is a Ruby on Rails 8.0 application designed as a multi-tenant SaaS platform. It utilizes a PostgreSQL database and incorporates user authentication and management through the Devise gem. The front-end is built with Stimulus, Turbo, and Tailwind CSS. The application appears to follow standard Rails conventions and includes a robust testing suite with RSpec and Capybara.

### Key Technologies:

*   **Backend:** Ruby on Rails 8.0
*   **Database:** PostgreSQL
*   **Authentication:** Devise
*   **Frontend:** Stimulus, Turbo, Tailwind CSS
*   **Testing:** RSpec, Capybara, FactoryBot
*   **Linting:** Rubocop
*   **Deployment:** Kamal

### Architecture:

The application follows a multi-tenancy model with the following hierarchy:

*   **Accounts:** The top-level entity, likely representing a customer or organization.
*   **Workspaces:** Each account can have multiple workspaces.
*   **Teams:** Each workspace can have multiple teams.
*   **Users:** Users can be members of accounts, workspaces, and teams with different roles.

## Building and Running

### Prerequisites:

*   Ruby (see `.ruby-version`)
*   PostgreSQL

### Getting Started:

1.  **Install dependencies and set up the database:**
    ```bash
    bin/setup
    ```
2.  **Run the application:**
    ```bash
    bin/dev
    ```
    The application will be available at http://localhost:3000.

### Testing:

*   **Run all tests and linters:**
    ```bash
    bin/rake
    ```
*   **Run tests and linters in parallel (faster):**
    ```bash
    bin/rake -m
    ```
*   **Auto-correct lint issues:**
    ```bash
    bin/rake fix
    ```

## Development Conventions

*   **Code Style:** Enforced by Rubocop. Refer to the `.rubocop.yml` file for specific rules.
*   **Testing:** The project uses RSpec for testing. Tests are located in the `spec` directory. FactoryBot is used for creating test data.
*   **Database Migrations:** Use `bin/rails generate migration` to create new database migrations.
*   **Dependencies:** Manage Ruby dependencies with Bundler (`Gemfile`) and JavaScript dependencies with import maps (`config/importmap.rb`).

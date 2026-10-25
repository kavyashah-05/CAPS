# C.A.P.S. — Development Setup Guide

## 1. Project Overview

C.A.P.S. (Campus Placement & Academic System) is a full-stack web application designed to help college Training and Placement Cells manage recruitment activities, student records, company drives, and placement rounds.

## 2. Technology Stack

| Component | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Database Platform | Supabase |
| Document Storage | Supabase Storage |
| Version Control | Git and GitHub |
| Code Editor | Visual Studio Code |

## 3. Prerequisites

Install or configure the following tools before starting development:

- Visual Studio Code
- Git
- Node.js and npm
- PostgreSQL and pgAdmin (optional for local database administration)
- A GitHub account

Node.js and npm versions must be verified before backend development begins.

## 4. Repository Setup

Clone the repository:

```bash
git clone https://github.com/kavyashah-05/CAPS.git
cd CAPS
```

Check the current Git branch:

```bash
git branch --show-current
```

Check the repository status:

```bash
git status
```

## 5. Verify Node.js and npm

Run these commands in the terminal:

```bash
node -v
npm -v
```

Both commands should display installed version numbers. If either command fails, install or repair the relevant installation before proceeding.

## Backend Setup

### 1. Install Dependencies

From the project root, run:

```bash
npm install
```

### 2. Start the Backend

For normal execution:

```bash
npm start
```

For development with automatic restarts:

```bash
npm run dev
```

### 3. Test the API

Open the following URLs in a browser while the server is running:

- `http://localhost:3000/` — API welcome message.
- `http://localhost:3000/api/health` — API health-check response.

### 4. Stop the Server

Press `Ctrl + C` in the terminal running the server.

### 5. Installed Dependencies

- Express.js — handles HTTP requests and API routes.
- Nodemon — automatically restarts the server during development.

Nodemon is a development dependency and is not required to run the application using `npm start`.

## 6. Environment Variables and Secrets

Sensitive configuration values must be stored in a local `.env` file.

- Never commit `.env` files or credentials to GitHub.
- Use `.env.example` to document the required variable names without real secrets.
- Keep uploaded documents and private student data out of the Git repository.

## 7. Development Workflow

1. Create or select a GitHub Issue describing the task.
2. Create a dedicated feature branch.
3. Implement and test the change.
4. Update relevant documentation.
5. Commit changes with a descriptive message.
6. Push the branch and open a Pull Request.
7. Review the changes and merge after verification.

## 8. Current Development Status

- GitHub repository initialized and connected.
- Project overview and development roadmap documented.
- Node.js and npm installation verified.
- Development environment setup guide added.
- Backend dependencies and application structure are not yet configured.


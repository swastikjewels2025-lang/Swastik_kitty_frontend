# Kitty App — Project Tracking & Coordination Guide

This folder contains the permanent, single-source-of-truth tracking documentation for the **Kitty App (Swastik Jewellers Digital Gold Savings)** project.

---

## 👥 Team Responsibilities

| Role | Responsibility | Working Directory |
| :--- | :--- | :--- |
| **Frontend Developer** | Flutter Mobile App (Android / iOS / Web) | `Swastik_kitty_frontend/kitty_app` |
| **Backend Developer** | Node.js / Express API, MongoDB Atlas, Services | `Swastik_kitty_backend` |

---

## 📁 Tracking Files Manifest

1. **[`CHANGELOG.md`](./CHANGELOG.md)**
   - The master chronological record of all code and UI changes.
   - Every completed development task must append a new entry formatted according to the project standard.
   - Historical entries must be preserved indefinitely; never overwrite or truncate past logs.

2. **[`DAILY_LOG.md`](./DAILY_LOG.md)**
   - Day-by-day record of work completed, session times, modified files, encountered issues, test results, and next steps.
   - Organized chronologically by date.

3. **[`FRONTEND_BACKEND_COORDINATION.md`](./FRONTEND_BACKEND_COORDINATION.md)**
   - Live integration registry between the Flutter app and Node.js backend.
   - Details API endpoints, request/response payloads, authentication tokens, validation rules, contract changes, and active blockers.

---

## 🕒 Standards & Rules

- **Reporting Timezone**: All timestamps must be recorded in **`Asia/Kolkata` (IST)**.
- **Factual Documentation**: Do not invent test results, timestamps, or file paths. Record actual commands run and real outputs observed.
- **Non-Destructive Logging**: Always append new log entries. Never delete or replace existing history.
- **Coordination Updates**: Whenever an API route, payload, or validation contract is modified or requested, update `FRONTEND_BACKEND_COORDINATION.md` immediately with the responsible developer noted.

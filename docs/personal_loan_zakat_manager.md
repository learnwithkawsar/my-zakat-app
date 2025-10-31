# 🕌 Personal Loan & Zakat Manager (Interest-Free Flutter App)

## 📘 Overview
A privacy-first, interest-free personal finance app that helps users manage:
- Loans they give (Receivables)
- Liabilities they owe (Payables)
- Assets they own
- Zakat calculation and yearly tracking

The app ensures **secure local data storage**, **PIN/Biometric protection**, and **offline-first** functionality.

---

## 🧩 Core Modules

| Module | Description |
|---------|-------------|
| AuthModule | Manages app PIN, biometric lock, and security. |
| DashboardModule | Shows summary of assets, loans, liabilities, and zakat. |
| BorrowerModule | Manages borrower contacts and profiles. |
| LoanModule | Handles interest-free loans (Qard Hasan). |
| PaymentModule | Tracks repayments of loans. |
| AssetModule | Records zakatable assets. |
| LiabilityModule | Manages debts owed by user (liabilities). |
| BeneficiaryModule | Tracks zakat beneficiaries and distribution planning. |
| ZakatModule | Calculates zakat with full breakdown and deductions. |
| SnapshotModule | Saves yearly zakat snapshots with rollover. |
| ReportModule | Generates summaries and exports data. |
| SettingsModule | Configures currency, zakat rate, nisab, and preferences. |
| BackupModule | Exports/imports encrypted data backups. |
| NotificationModule | Sends reminders for zakat, due loans, and liabilities. |

---

## 🔐 Security Features
- Local-only data storage (Hive / SQLCipher)
- App-level PIN / Biometric authentication
- Auto-lock after inactivity
- Encrypted JSON backup
- Optional cloud backup (Phase 2)

---

## 🏠 Dashboard
- Total Assets 💰  
- Total Loans Given 🤝  
- Total Liabilities 💸  
- Estimated Zakat 🕌  
- Quick actions: Add Loan / Asset / Liability / Calculate Zakat  
- Reminder for Zakat day  
- Visual summary chart (Assets vs Liabilities vs Receivables)

---

## 👥 Borrower Management
- Add borrower (Name, Contact, Notes)
- List with total outstanding loans
- Borrower details screen:
  - Loans given
  - Payment history
  - Remaining balance
- Edit/Delete borrower

---

## 💵 Loan Management
- Add new loan:
  - Borrower, Amount, Date, Optional Due Date, Notes
- Loan details:
  - Principal, Paid, Remaining, Status
- Add/Edit/Delete repayments
- Mark as Closed/Reopen
- Include/Exclude in zakat calculation

---

## 💰 Payment Management
- Add repayment entry:
  - Amount, Date, Payment Type, Notes
- History per borrower or loan
- Auto-calculate outstanding balance

---

## 🪙 Asset Management
- Add zakatable assets:
  - Type: Cash, Bank, Gold, Silver, Investment, Property, Business, Other
  - Value, Currency, Valuation date
  - Notes
- Edit/Delete assets
- Total assets by category (pie chart)

---

## 💼 Liabilities Management
> Manage debts and dues owed to others for proper zakat deduction.

- Add liability:
  - Creditor Name
  - Description / Note
  - Amount, Currency
  - Due Date (optional)
  - Type: Short-term / Long-term
- Edit/Delete liability
- View total liabilities
- Filter by type or due date
- Include/Exclude in zakat calculation
- Due date alerts via NotificationModule

---

## 👳‍♂️ Beneficiary Management
- Add zakat beneficiaries:
  - Name, Contact, Notes
  - Percentage Share (optional)
- List / Edit / Delete beneficiaries
- Used for zakat distribution planning

---

## 🧮 Zakat Calculation
- Configurable:
  - Zakat rate (default: 2.5%)
  - Nisab threshold (manual or auto)
- Formula:
  ```
  Zakat = (Assets + Receivables - Liabilities) × 2.5%
  ```
- Breakdown view:
  - Assets total
  - Receivables (Active loans)
  - Liabilities total
  - Net zakatable amount
  - Zakat due
- Save yearly zakat record
- Export zakat report (PDF/CSV/JSON)

---

## 🗓️ Zakat Year Snapshot
- Save yearly snapshot (Assets + Loans + Liabilities + Zakat)
- Label (e.g., “Zakat 1446H / 2025”)
- Copy snapshot to next year
- Compare past zakat records

---

## 📊 Reports & Analytics
- Loan Summary (Total given, Paid, Due)
- Asset Distribution (Pie/Bar chart)
- Liability Summary
- Zakat History
- Export JSON / CSV reports

---

## ⚙️ Settings
- Default currency  
- Zakat rate  
- Nisab value  
- Reminder date  
- Enable biometric login  
- Data export/import  
- Factory reset with confirmation  

---

## 🔔 Notifications
- Zakat date reminder  
- Loan due alerts  
- Liability due alerts  
- Backup reminder  

---

## ☁️ Backup & Restore
- Export encrypted JSON backup  
- Import restore file  
- Optional cloud integration (Google Drive / Dropbox - Phase 2)

---

## 🌍 Future Enhancements (Phase 2)
- Real-time gold/silver price sync for nisab
- Multi-language support (English, Bangla, Arabic)
- Firebase sync for multi-device access
- Voice commands for adding entries
- Light/Dark theme

---

## 🧱 Entity Definitions

| Entity | Fields |
|--------|--------|
| **Borrower** | id, name, phone, email, notes |
| **Loan** | id, borrowerId, amount, date, dueDate, currency, status, notes, includeInZakat |
| **Payment** | id, loanId, amount, date, type, notes |
| **Asset** | id, name, type, value, currency, valuationDate, notes |
| **Liability** | id, creditorName, description, amount, currency, dueDate, type, includeInZakat |
| **Beneficiary** | id, name, contact, percentage, notes |
| **ZakatRecord** | id, date, assetsTotal, receivablesTotal, liabilitiesTotal, zakatDue, notes |
| **Snapshot** | id, year, summaryJson, createdAt |
| **Settings** | id, currency, zakatRate, nisab, reminderDate, useBiometric |

---

## 🧠 AI Vibe Coding Hints
- Suggested folder structure:
  ```
  lib/
   ├── modules/
   │   ├── auth/
   │   ├── dashboard/
   │   ├── borrower/
   │   ├── loan/
   │   ├── payment/
   │   ├── asset/
   │   ├── liability/
   │   ├── beneficiary/
   │   ├── zakat/
   │   ├── snapshot/
   │   ├── report/
   │   ├── settings/
   │   └── backup/
   ├── common/
   │   ├── widgets/
   │   ├── utils/
   │   └── theme/
   ├── services/
   │   ├── local_db_service.dart
   │   ├── encryption_service.dart
   │   └── notification_service.dart
   ├── main.dart
  ```
- Use `Hive` or `Drift` for offline DB.
- Use `GetX` or `Riverpod` for state management.
- Target **Flutter 3.24+ (Dart 3)**.

---

## 🧾 Example Zakat Calculation Scenario

| Category | Amount (BDT) |
|-----------|--------------|
| Assets | 500,000 |
| Receivables (Loan Given) | 100,000 |
| Liabilities | 50,000 |
| **Net Zakatable** | **550,000** |
| **Zakat (2.5%)** | **13,750** |

---

**Author:** Kawsar Ahmed  
**Version:** 1.0  
**Date:** 2025-10-27  
**Purpose:** Context document for AI-based app scaffolding and code generation (AI Vibe Coding compatible)

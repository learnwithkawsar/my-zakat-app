# 🗺️ Personal Loan & Zakat Manager - Implementation Plan

## 📋 Overview

This document outlines the complete implementation plan for building the Personal Loan & Zakat Manager Flutter app based on the requirements.

---

## 🎯 Phase 1: Foundation & Core Infrastructure (Week 1-2)

### 1.1 Database Setup

- [ ] **Install Dependencies**

  - `hive` / `hive_flutter` - Local database
  - `path_provider` - File system access
  - `encrypt` / `crypto` - Data encryption
  - `local_auth` - Biometric authentication
  - `permission_handler` - Permissions
  - `intl` - Currency formatting
  - `pdf` / `csv` - Export functionality

- [ ] **Database Models** (`lib/models/`)

  - [ ] `borrower_model.dart` - Borrower entity
  - [ ] `loan_model.dart` - Loan entity
  - [ ] `payment_model.dart` - Payment/Repayment entity
  - [ ] `asset_model.dart` - Asset entity
  - [ ] `liability_model.dart` - Liability entity
  - [ ] `beneficiary_model.dart` - Beneficiary entity
  - [ ] `zakat_record_model.dart` - Zakat calculation record
  - [ ] `snapshot_model.dart` - Yearly snapshot
  - [ ] `settings_model.dart` - App settings

- [ ] **Database Service** (`lib/services/`)
  - [ ] Initialize Hive boxes
  - [ ] CRUD operations for all entities
  - [ ] Data migration strategy
  - [ ] Encryption wrapper

### 1.2 Security Module

- [ ] **Auth Controller** (`lib/modules/auth/`)

  - [ ] PIN setup/validation
  - [ ] Biometric setup/authentication
  - [ ] Auto-lock functionality
  - [ ] Session management

- [ ] **Auth Screens**
  - [ ] PIN setup screen
  - [ ] PIN entry screen
  - [ ] Biometric prompt screen
  - [ ] Security settings screen

### 1.3 Common Infrastructure

- [ ] **Utils** (`lib/common/utils/`)

  - [ ] Currency formatter
  - [ ] Date formatter
  - [ ] Validators
  - [ ] Constants

- [ ] **Widgets** (`lib/common/widgets/`)

  - [ ] Custom text fields
  - [ ] Custom buttons
  - [ ] Loading indicators
  - [ ] Empty state widgets
  - [ ] Charts widgets

- [ ] **Theme** (`lib/common/theme/`)
  - [ ] App theme configuration
  - [ ] Color schemes
  - [ ] Typography

---

## 🎯 Phase 2: Core Modules - Part 1 (Week 3-4)

### 2.1 Borrower Module

- [ ] **Borrower Controller** (`lib/modules/borrower/`)

  - [ ] GetX controller with CRUD operations
  - [ ] List, add, edit, delete borrowers
  - [ ] Search/filter functionality

- [ ] **Borrower Screens**
  - [ ] Borrower list screen
  - [ ] Add/Edit borrower screen
  - [ ] Borrower detail screen
    - [ ] Loan history
    - [ ] Payment history
    - [ ] Outstanding balance

### 2.2 Loan Module

- [ ] **Loan Controller** (`lib/modules/loan/`)

  - [ ] CRUD operations for loans
  - [ ] Calculate outstanding balance
  - [ ] Loan status management (Active/Closed)
  - [ ] Include/exclude from zakat toggle

- [ ] **Loan Screens**
  - [ ] Loan list screen
  - [ ] Add/Edit loan screen
  - [ ] Loan detail screen
    - [ ] Payment history
    - [ ] Outstanding balance
    - [ ] Add payment button

### 2.3 Payment Module

- [ ] **Payment Controller** (`lib/modules/payment/`)

  - [ ] Add repayment entry
  - [ ] Edit/Delete payments
  - [ ] Payment history per loan

- [ ] **Payment Screens**
  - [ ] Add payment screen
  - [ ] Payment history screen

---

## 🎯 Phase 3: Core Modules - Part 2 (Week 5-6)

### 3.1 Asset Module

- [ ] **Asset Controller** (`lib/modules/asset/`)

  - [ ] CRUD operations for assets
  - [ ] Asset types: Cash, Bank, Gold, Silver, Investment, Property, Business, Other
  - [ ] Calculate total assets by category
  - [ ] Asset valuation tracking

- [ ] **Asset Screens**
  - [ ] Asset list screen
  - [ ] Add/Edit asset screen
  - [ ] Asset summary with charts

### 3.2 Liability Module

- [ ] **Liability Controller** (`lib/modules/liability/`)

  - [ ] CRUD operations for liabilities
  - [ ] Short-term / Long-term classification
  - [ ] Include/exclude from zakat toggle
  - [ ] Due date tracking

- [ ] **Liability Screens**
  - [ ] Liability list screen
  - [ ] Add/Edit liability screen
  - [ ] Liability summary

### 3.3 Beneficiary Module

- [ ] **Beneficiary Controller** (`lib/modules/beneficiary/`)

  - [ ] CRUD operations for beneficiaries
  - [ ] Percentage share management

- [ ] **Beneficiary Screens**
  - [ ] Beneficiary list screen
  - [ ] Add/Edit beneficiary screen

---

## 🎯 Phase 4: Zakat Calculation & Snapshots (Week 7)

### 4.1 Zakat Module

- [ ] **Zakat Controller** (`lib/modules/zakat/`)

  - [ ] Zakat calculation logic:
    ```
    Zakat = (TotalAssets + TotalReceivables - TotalLiabilities) × ZakatRate
    ```
  - [ ] Nisab validation
  - [ ] Detailed breakdown view
  - [ ] Configurable zakat rate (default 2.5%)
  - [ ] Save zakat records

- [ ] **Zakat Screens**
  - [ ] Zakat calculator screen
    - [ ] Assets summary
    - [ ] Receivables summary
    - [ ] Liabilities summary
    - [ ] Net zakatable amount
    - [ ] Zakat due calculation
  - [ ] Zakat history screen
  - [ ] Zakat detail/view screen

### 4.2 Snapshot Module

- [ ] **Snapshot Controller** (`lib/modules/snapshot/`)

  - [ ] Save yearly zakat snapshot
  - [ ] Label snapshots (e.g., "Zakat 1446H / 2025")
  - [ ] Copy snapshot to next year
  - [ ] Compare past records

- [ ] **Snapshot Screens**
  - [ ] Snapshot list screen
  - [ ] Create snapshot screen
  - [ ] Snapshot detail/comparison screen

---

## 🎯 Phase 5: Dashboard & Reports (Week 8)

### 5.1 Enhanced Dashboard

- [ ] **Dashboard Controller** (`lib/modules/dashboard/`)

  - [ ] Calculate summary statistics:
    - Total Assets
    - Total Loans Given
    - Total Outstanding Receivables
    - Total Liabilities
    - Estimated Zakat
  - [ ] Quick actions
  - [ ] Reminders for zakat date

- [ ] **Dashboard Screen Enhancements**
  - [ ] Summary cards with icons
  - [ ] Visual charts (Assets vs Liabilities vs Receivables)
  - [ ] Quick action buttons
  - [ ] Recent activity section
  - [ ] Zakat reminder banner

### 5.2 Reports Module

- [ ] **Report Controller** (`lib/modules/report/`)

  - [ ] Loan summary report
  - [ ] Asset distribution report
  - [ ] Liability summary report
  - [ ] Zakat history report
  - [ ] Export to JSON/CSV/PDF

- [ ] **Report Screens**
  - [ ] Report list/selection screen
  - [ ] Report view screen
  - [ ] Export options screen

---

## 🎯 Phase 6: Settings & Backup (Week 9)

### 6.1 Settings Module

- [ ] **Settings Controller** (`lib/modules/settings/`)

  - [ ] Default currency management
  - [ ] Zakat rate configuration
  - [ ] Nisab value configuration
  - [ ] Zakat reminder date
  - [ ] Biometric toggle
  - [ ] Theme settings (if applicable)
  - [ ] Factory reset

- [ ] **Settings Screen**
  - [ ] Settings list with categories
  - [ ] Currency selector
  - [ ] Zakat configuration
  - [ ] Security settings
  - [ ] Data management (export/import)

### 6.2 Backup Module

- [ ] **Backup Controller** (`lib/modules/backup/`)

  - [ ] Export encrypted JSON backup
  - [ ] Import restore from file
  - [ ] Backup validation
  - [ ] Data integrity checks

- [ ] **Backup Screen**
  - [ ] Backup options
  - [ ] Export backup
  - [ ] Import/restore backup
  - [ ] Backup history (if storing locally)

---

## 🎯 Phase 7: Notifications & Polish (Week 10)

### 7.1 Notification Module

- [ ] **Notification Service** (`lib/services/`)

  - [ ] Zakat date reminder
  - [ ] Loan due alerts
  - [ ] Liability due alerts
  - [ ] Backup reminder
  - [ ] Local notifications setup

- [ ] **Notification Controller**
  - [ ] Schedule notifications
  - [ ] Cancel notifications
  - [ ] Notification preferences

### 7.2 UI/UX Polish

- [ ] **Polish & Refinements**
  - [ ] Loading states
  - [ ] Error handling & messages
  - [ ] Empty states
  - [ ] Form validations
  - [ ] Animations & transitions
  - [ ] Responsive design
  - [ ] Accessibility improvements

### 7.3 Testing & Bug Fixes

- [ ] Unit tests for controllers
- [ ] Widget tests
- [ ] Integration tests
- [ ] Bug fixes
- [ ] Performance optimization

---

## 📊 Database Schema Summary

### Core Entities:

1. **Borrower**

   - id (UUID), name, contactInfo, address, notes

2. **Loan**

   - id (UUID), borrowerId, amount, date, dueDate, currency, status, notes, includeInZakat

3. **Payment**

   - id (UUID), loanId, amount, date, type, notes

4. **Asset**

   - id (UUID), name, type, value, currency, valuationDate, notes

5. **Liability**

   - id (UUID), creditorName, description, amount, currency, dueDate, type, includeInZakat

6. **Beneficiary**

   - id (UUID), name, contact, percentage, notes

7. **ZakatRecord**

   - id (UUID), date, assetsTotal, receivablesTotal, liabilitiesTotal, netZakatable, zakatDue, notes

8. **Snapshot**

   - id (UUID), year, label, summaryJson, createdAt

9. **Settings**
   - currency, zakatRate, nisab, reminderDate, useBiometric

---

## 🛠️ Technology Stack

### Core:

- **Flutter** 3.24+ (Dart 3)
- **GetX** - State management (already added)
- **Hive** - Local database
- **Path Provider** - File system

### Security:

- **Local Auth** - Biometric authentication
- **Encrypt** - Data encryption
- **Hive Secure Storage** - Encrypted storage

### UI:

- **Material Design 3** (already configured)
- **Flutter Charts** - For visualizations
- **Intl** - Currency/date formatting

### Export:

- **PDF** / **PDF Export** - PDF generation
- **CSV** - CSV export

### Notifications:

- **Flutter Local Notifications** - Local reminders

---

## 📁 Recommended Folder Structure

```
lib/
├── main.dart
├── modules/
│   ├── auth/
│   │   ├── controllers/
│   │   ├── screens/
│   │   └── models/
│   ├── dashboard/
│   │   ├── controllers/
│   │   └── screens/
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
├── models/
│   └── [all model files]
├── services/
│   ├── database_service.dart
│   ├── encryption_service.dart
│   ├── notification_service.dart
│   └── backup_service.dart
├── common/
│   ├── widgets/
│   │   ├── custom_text_field.dart
│   │   ├── custom_button.dart
│   │   ├── empty_state.dart
│   │   └── loading_indicator.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   ├── validators.dart
│   │   └── constants.dart
│   └── theme/
│       └── app_theme.dart
└── routes/
    └── app_routes.dart
```

---

## 🚀 Implementation Priority

### High Priority (MVP):

1. Database setup & models
2. Borrower & Loan modules
3. Asset & Liability modules
4. Zakat calculation
5. Dashboard with summaries
6. Basic settings

### Medium Priority:

7. Payment tracking
8. Beneficiary management
9. Snapshot module
10. Reports & exports

### Low Priority (Enhancements):

11. Advanced notifications
12. Backup/restore
13. UI polish & animations
14. Multi-language (Phase 2)
15. Cloud sync (Phase 2)

---

## 📝 Notes

- Start with Phase 1 to establish foundation
- Each phase builds on the previous one
- Test thoroughly after each module
- Keep security in mind throughout (encryption, PIN protection)
- Follow GetX patterns consistently
- Use Material Design 3 components
- Maintain offline-first approach

---

## ✅ Current Status

- ✅ Basic login screen
- ✅ Dashboard navigation structure
- ✅ GetX integration
- ⏳ Need to implement all modules as per plan

---

**Last Updated:** 2025-01-27  
**Next Steps:** Begin Phase 1 - Database Setup

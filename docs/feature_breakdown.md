# 📱 Feature Breakdown - Personal Loan & Zakat Manager

## 🎯 Quick Feature Overview

### ✅ Currently Implemented
- [x] Login screen with preset credentials
- [x] Dashboard navigation structure
- [x] Bottom navigation bar
- [x] Drawer menu
- [x] GetX state management setup

### 🔨 To Be Implemented

## 1. 🔐 Authentication & Security Module

### Features:
- **PIN Setup & Login**
  - Set 4-6 digit PIN on first launch
  - PIN entry screen
  - PIN change functionality
  
- **Biometric Authentication**
  - Fingerprint/Face ID support
  - Toggle on/off in settings
  - Fallback to PIN
  
- **Auto-Lock**
  - Lock app after inactivity (configurable timeout)
  - Background lock

### Screens Needed:
1. PIN Setup Screen (first time)
2. PIN Entry Screen
3. Security Settings Screen

---

## 2. 👥 Borrower Management

### Features:
- Add borrower (Name, Contact Info, Address, Notes)
- List all borrowers with total outstanding
- View borrower details:
  - All loans given to this borrower
  - Payment history
  - Remaining balance per loan
  - Total outstanding
- Edit/Delete borrower
- Search borrowers

### Screens Needed:
1. Borrower List Screen
2. Add/Edit Borrower Screen
3. Borrower Detail Screen

### Data Fields:
- Name (required)
- Contact Info (phone/email)
- Address (optional)
- Notes (optional)

---

## 3. 💵 Loan Management (Qard Hasan - Interest-Free)

### Features:
- Add new loan:
  - Select borrower
  - Amount
  - Date
  - Optional due date
  - Notes
- Loan list with status (Active/Closed)
- Loan details:
  - Principal amount
  - Total paid
  - Remaining balance
  - Payment history
  - Status
- Add/Edit/Delete repayments
- Mark loan as Closed/Reopen
- Include/Exclude from zakat calculation (toggle)
- Filter loans by status, borrower, date

### Screens Needed:
1. Loan List Screen
2. Add/Edit Loan Screen
3. Loan Detail Screen

### Data Fields:
- Borrower (required)
- Amount (required)
- Transaction Date (required)
- Due Date (optional)
- Currency (default from settings)
- Status (Active/Closed)
- Include in Zakat (boolean, default: true)
- Notes (optional)

---

## 4. 💰 Payment/Repayment Management

### Features:
- Add repayment entry:
  - Select loan
  - Amount
  - Date
  - Payment type/notes
- View payment history per loan
- View payment history per borrower
- Auto-calculate outstanding balance
- Edit/Delete payments

### Screens Needed:
1. Add Payment Screen (can be modal/dialog)
2. Payment History Screen

### Data Fields:
- Loan (required)
- Amount (required)
- Date (required)
- Payment Type (optional)
- Notes (optional)

---

## 5. 🪙 Asset Management

### Features:
- Add zakatable assets:
  - Type (Cash, Bank, Gold, Silver, Investment, Property, Business, Other)
  - Name/Description
  - Value
  - Currency
  - Valuation date
  - Notes
- Edit/Delete assets
- View total assets by category
- Pie/Bar chart of asset distribution
- Filter by type

### Screens Needed:
1. Asset List Screen
2. Add/Edit Asset Screen
3. Asset Summary Screen (with charts)

### Asset Types:
- 💵 Cash
- 🏦 Bank Account
- 🥇 Gold
- 🥈 Silver
- 📈 Investment
- 🏠 Property
- 💼 Business
- 📦 Other

### Data Fields:
- Name (required)
- Type (required, from list above)
- Value (required)
- Currency (default from settings)
- Valuation Date (required)
- Notes (optional)

---

## 6. 💼 Liability Management

### Features:
- Add liability:
  - Creditor name
  - Description
  - Amount
  - Currency
  - Due date (optional)
  - Type (Short-term / Long-term)
  - Include/exclude from zakat
- Edit/Delete liability
- View total liabilities
- Filter by type or due date
- Due date alerts

### Screens Needed:
1. Liability List Screen
2. Add/Edit Liability Screen

### Data Fields:
- Creditor Name (required)
- Description (optional)
- Amount (required)
- Currency (default from settings)
- Due Date (optional)
- Type (Short-term/Long-term)
- Include in Zakat (boolean, default: true)
- Notes (optional)

---

## 7. 👳‍♂️ Beneficiary Management

### Features:
- Add zakat beneficiaries:
  - Name
  - Contact info
  - Percentage share (optional, for distribution planning)
  - Notes
- List all beneficiaries
- Edit/Delete beneficiaries
- Used for zakat distribution planning

### Screens Needed:
1. Beneficiary List Screen
2. Add/Edit Beneficiary Screen

### Data Fields:
- Name (required)
- Contact Info (optional)
- Percentage Share (optional, 0-100)
- Notes (optional)

---

## 8. 🧮 Zakat Calculation Module

### Features:
- **Zakat Formula:**
  ```
  Total Assets + Total Receivables (Active Loans) - Total Liabilities
  = Net Zakatable Amount
  
  Zakat Due = Net Zakatable Amount × Zakat Rate (default 2.5%)
  ```
- **Nisab Check:**
  - Must exceed nisab threshold to be zakatable
  - Configurable nisab value
  
- **Breakdown View:**
  - Total Assets (by category)
  - Total Receivables (active loans only)
  - Total Liabilities (deductible)
  - Net Zakatable Amount
  - Zakat Due
  
- **Save Zakat Record:**
  - Save calculation with date
  - Add remarks/notes
  - View calculation history

### Screens Needed:
1. Zakat Calculator Screen
   - Breakdown sections
   - Real-time calculation
   - Save button
2. Zakat History Screen
3. Zakat Detail/View Screen

### Calculation Logic:
```dart
// Pseudo-code
double totalAssets = sum(allAssets.value);
double totalReceivables = sum(activeLoans.balance);
double totalLiabilities = sum(includedLiabilities.amount);

double netZakatable = totalAssets + totalReceivables - totalLiabilities;

if (netZakatable >= nisab) {
  double zakatDue = netZakatable * (zakatRate / 100);
} else {
  zakatDue = 0; // Below nisab threshold
}
```

---

## 9. 🗓️ Zakat Snapshot Module

### Features:
- Save yearly zakat snapshot:
  - Assets at calculation date
  - Loans outstanding
  - Liabilities
  - Zakat paid
  - Custom label (e.g., "Zakat 1446H / 2025")
- Copy snapshot to next year (rollover)
- Compare past zakat records
- View snapshot history

### Screens Needed:
1. Snapshot List Screen
2. Create Snapshot Screen
3. Snapshot Detail/Comparison Screen

### Data Stored:
- Year
- Label
- Assets snapshot (JSON)
- Loans snapshot (JSON)
- Liabilities snapshot (JSON)
- Zakat paid
- Created date

---

## 10. 📊 Reports & Analytics

### Features:
- **Loan Summary Report:**
  - Total loans given
  - Total paid
  - Total outstanding
  - By borrower breakdown
  
- **Asset Distribution Report:**
  - Pie chart by type
  - Bar chart by category
  - Total value
  
- **Liability Summary:**
  - Total liabilities
  - By type
  - Due soon alerts
  
- **Zakat History:**
  - Yearly zakat records
  - Comparison chart
  - Trend analysis
  
- **Export Options:**
  - Export to JSON
  - Export to CSV
  - Export to PDF (future)

### Screens Needed:
1. Reports Selection Screen
2. Report View Screen
3. Export Options Screen

---

## 11. ⚙️ Settings Module

### Features:
- **Currency Settings:**
  - Default currency selection
  - Currency formatting options
  
- **Zakat Configuration:**
  - Zakat rate (default: 2.5%)
  - Nisab value (manual input or auto-calculate)
  - Zakat reminder date
  
- **Security Settings:**
  - Enable/Disable biometric
  - Change PIN
  - Auto-lock timeout
  
- **Data Management:**
  - Export data
  - Import/Restore backup
  - Factory reset (with confirmation)
  
- **App Preferences:**
  - Theme (if implementing)
  - Language (future)
  - Notifications preferences

### Screens Needed:
1. Settings Screen (main)
2. Security Settings Screen
3. Zakat Configuration Screen
4. Data Management Screen

---

## 12. 🔔 Notifications Module

### Features:
- **Zakat Date Reminder:**
  - Configurable date (e.g., Ramadan start)
  - Yearly reminder
  
- **Loan Due Alerts:**
  - Alert when loan due date approaches
  - Overdue loans notification
  
- **Liability Due Alerts:**
  - Alert before liability due date
  - Overdue liabilities notification
  
- **Backup Reminder:**
  - Weekly/monthly backup reminder

### Implementation:
- Use `flutter_local_notifications`
- Schedule notifications
- Handle notification permissions

---

## 13. ☁️ Backup & Restore Module

### Features:
- **Export Backup:**
  - Encrypt all data
  - Export to JSON file
  - Save to device storage
  - Share option
  
- **Import/Restore:**
  - Select backup file
  - Validate backup file
  - Restore data
  - Confirmation dialogs
  
- **Backup Validation:**
  - Check file integrity
  - Verify encryption
  - Version compatibility check

### Screens Needed:
1. Backup Screen
2. Restore Screen

---

## 📊 Dashboard Summary Cards

### Current Dashboard Should Show:
1. **Total Assets** 💰
   - Sum of all assets
   - Icon + amount

2. **Total Loans Given** 🤝
   - Sum of all active loans
   - Outstanding amount

3. **Total Liabilities** 💸
   - Sum of all liabilities
   - Due soon indicator

4. **Estimated Zakat** 🕌
   - Calculated zakat amount
   - Based on current assets/loans/liabilities

5. **Visual Chart:**
   - Pie chart: Assets vs Liabilities vs Receivables
   - Or bar chart showing breakdown

6. **Quick Actions:**
   - Add Loan
   - Add Asset
   - Add Liability
   - Calculate Zakat

7. **Reminders:**
   - Zakat date reminder banner
   - Due loans/liabilities count

---

## 🔄 Data Flow Example

### Zakat Calculation Flow:
```
User opens Dashboard
  ↓
Clicks "Calculate Zakat"
  ↓
Zakat Calculator Screen loads
  ↓
Fetches:
  - All assets (sum values)
  - Active loans (sum outstanding)
  - Included liabilities (sum amounts)
  ↓
Calculates:
  - Net Zakatable = Assets + Loans - Liabilities
  - Zakat Due = Net × Rate (if >= Nisab)
  ↓
Shows breakdown view
  ↓
User can save as Zakat Record
  ↓
Saved to database with timestamp
```

### Loan Management Flow:
```
User clicks "Add Loan" from Dashboard
  ↓
Select/Create Borrower
  ↓
Enter loan details (amount, date, etc.)
  ↓
Save loan
  ↓
Loan appears in list
  ↓
User can add payments
  ↓
Outstanding balance auto-calculates
```

---

## 📈 Priority Implementation Order

### Week 1-2: Foundation
1. Database setup (Hive)
2. Models creation
3. Security module (PIN setup)
4. Settings basic structure

### Week 3-4: Core Features
5. Borrower module
6. Loan module
7. Payment module

### Week 5-6: Assets & Liabilities
8. Asset module
9. Liability module
10. Beneficiary module

### Week 7: Zakat
11. Zakat calculation
12. Snapshot module

### Week 8: Dashboard & Reports
13. Enhanced dashboard
14. Reports module

### Week 9-10: Polish
15. Backup/restore
16. Notifications
17. UI polish
18. Testing

---

**Total Estimated Screens: ~25-30 screens**  
**Total Modules: 12 core modules**  
**Database Entities: 9 main entities**


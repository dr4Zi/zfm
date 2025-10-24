# ZFM – Personal Finance Management App

ZFM is a personal finance management application built with **Flutter**.  
It helps track income, expenses, and savings, following the **50/30/20 budgeting principle**.

---

## Overview

ZFM allows users to:
- Manage spending categories dynamically (by group or type)
- Follow a default budgeting configuration (50% Needs, 30% Wants, 20% Savings)
- Add, edit, and delete spending categories
- Track total income and expenses
- View the remaining balance and average daily spending
- Store data locally without requiring backend sync

---

## Features

- **Dynamic configuration:** Create or modify categories and budgeting rules.
- **Local storage:** Uses Hive for fast, lightweight local persistence.
- **50/30/20 default rule:** Built-in configuration for needs, wants, and savings.
- **Modular architecture:** Clear separation of core, data, domain, and presentation layers.
- **Offline-first:** No network dependency for personal data.

---

## Tech Stack

- Flutter (latest stable version)
- Dart >= 3.0
- Hive / Hive Flutter
- Provider or Riverpod
- Intl

---

## Folder Structure

```
lib/
  core/           # Services, utils, constants
  data/           # Models, repositories, local sources
  domain/         # Entities, use cases
  presentation/   # UI screens, viewmodels
  main.dart
```

---

## Getting Started

1. Install Flutter (latest stable)
2. Clone this repository:
   ```
   git clone https://github.com/dr4zi/zfm.git
   ```
3. Navigate to the project directory:
   ```
   cd zfm
   ```
4. Get the dependencies:
   ```
   flutter pub get
   ```
5. Run the app:
   ```
   flutter run
   ```

---

## Roadmap

- [x] Base app structure
- [x] Local configuration (50/30/20 rule)
- [ ] Custom budget rules
- [ ] Expense charts and reports
- [ ] Cloud sync (future backend integration)

---

## License

This project is licensed under the MIT License.

## Imported Claude Cowork project instructions

# Engineering Rules

## Core Principles

Always prioritize:

1. Maintainability
2. Readability
3. Scalability
4. Performance
5. Security

Do not optimize for quick generation at the cost of code quality.

---

# Code Generation Rules

Generate production-quality code only.

Never generate:

* placeholder implementations
* mock production code
* pseudo-code
* TODO comments as implementation

Every generated feature must be functional.

---

# Clean Code

Follow clean code principles.

Requirements:

* meaningful variable names
* meaningful function names
* meaningful class names

Avoid:

* temp
* data
* obj
* test
* sample
* foo
* bar

unless absolutely necessary.

---

# DRY Principle

Do not repeat code.

Before creating:

* component
* widget
* service
* repository
* utility

Check whether reusable code already exists.

Extract common logic.

Follow DRY (Don't Repeat Yourself).

---

# Folder Structure

Maintain a clean feature-based architecture.

Do not create random folders.

Group code by feature.

Example:

features/
authentication/
dashboard/
profile/
gallery/

Avoid:

screens/
screens2/
new_screens/
final_screens/

Never create duplicate folders.

---

# File Creation Rules

Before creating a file:

Verify whether similar functionality already exists.

Do not create:

UserService.dart
UserServiceNew.dart
UserServiceFinal.dart
UserServiceLatest.dart

Refactor existing code instead.

---

# Refactoring Rules

Prefer refactoring existing code.

Avoid creating duplicate implementations.

If functionality already exists:

Improve it.

Do not rebuild it.

---

# Component Reuse

Reusable UI must be extracted.

Examples:

* buttons
* cards
* dialogs
* text fields
* loaders
* headers

Do not duplicate UI code.

Create shared components.

---

# Flutter Rules

Use:

* StatelessWidget where possible
* StatefulWidget only when necessary

Prefer:

* const constructors
* immutable models
* reusable widgets

Avoid giant widget files.

Maximum target:

~300 lines per widget file.

Split large widgets.

---

# Backend Rules

Follow layered architecture.

Separate:

* Routes
* Controllers
* Services
* Repositories
* Models

Never place business logic inside routes.

---

# Database Rules

Normalize data properly.

Avoid duplicate data storage.

Use:

* foreign keys
* indexes
* constraints

Never store redundant information.

---

# API Rules

Keep APIs RESTful.

Use:

GET
POST
PUT
PATCH
DELETE

Use proper status codes.

Do not return inconsistent response structures.

---

# Error Handling

Every API must have:

* validation
* exception handling
* user-friendly messages

Never swallow exceptions.

Never leave empty catch blocks.

---

# Security Rules

Never:

* store plain text passwords
* hardcode secrets
* expose tokens

Always:

* hash passwords
* use environment variables
* validate inputs

Apply security best practices by default.

---

# Performance Rules

Avoid unnecessary rebuilds.

Avoid unnecessary database queries.

Avoid unnecessary API calls.

Optimize before introducing complexity.

---

# State Management

Use one state management solution consistently.

Do not mix:

* Provider
* Riverpod
* Bloc
* GetX

Choose one architecture and follow it throughout the project.

---

# UI Consistency

Maintain a single design system.

Use:

* centralized colors
* centralized typography
* centralized spacing

Avoid hardcoded values.

Example:

Do not write:

padding: EdgeInsets.all(17)

Create constants.

---

# Theme Management

All colors must come from theme files.

Never hardcode colors inside widgets.

Exception:

temporary debugging only.

---

# Responsiveness

Every screen must support:

* Android phones
* Android tablets
* iPhones
* iPads

Avoid fixed widths.

Avoid fixed heights.

Use adaptive layouts.

---

# Logging

Use structured logging.

Remove debug prints before production.

Never leave console spam.

---

# Dependencies

Before adding a package:

Check whether existing dependencies already solve the problem.

Avoid unnecessary packages.

Keep dependency count minimal.

---

# Technical Debt

When improving existing functionality:

Prefer fixing technical debt.

Do not stack new code on top of poor code.

Refactor first.

Implement second.

---

# Testing

Whenever a feature is completed:

Verify:

* functionality
* responsiveness
* security
* edge cases

Fix issues before moving to the next feature.

---

# Development Workflow

For every feature:

1. Analyze existing implementation
2. Reuse existing code
3. Refactor if necessary
4. Implement feature
5. Test feature
6. Verify responsiveness
7. Verify security
8. Commit changes

Do not skip steps.

---

# Final Rule

Before generating any new code ask:

Can this be reused?
Can this be simplified?
Can this be refactored?

If yes:

Refactor first.

Do not create duplicate implementations.

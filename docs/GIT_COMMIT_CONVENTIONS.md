# Flutter Git Commit Message Conventions

A standardized guide for writing clear, consistent, and meaningful commit messages in Flutter projects.

**Project Type:** Flutter Mobile/Web Development
**Version Control:** Git
**Based on:** Conventional Commits + Angular Style Guide

---

## Table of Contents

1. [Commit Message Format](#commit-message-format)
2. [Commit Types](#commit-types)
3. [Writing Guidelines](#writing-guidelines)
4. [Examples](#examples)

---

## Commit Message Format

```
<emoji> <type>(<scope>): <subject>

<body>

<footer>
```

### Structure Breakdown

| Part | Description | Required | Max Length |
|------|-------------|----------|-----------|
| **emoji** | Icon matching the type | ✅ Yes | N/A |
| **type** | Commit category | ✅ Yes | N/A |
| **scope** | Area of codebase affected | ❌ Optional | N/A |
| **subject** | Brief description | ✅ Yes | 50 characters |
| **body** | Detailed explanation | ❌ Optional | 72 characters per line |
| **footer** | References & breaking changes | ❌ Optional | N/A |

---

## Commit Types

| Icon | Type | Use for |
|------|------|---------|
| 📦 | **add** | New feature or capability |
| 🛠️ | **fix** | Bug fix |
| 🔃 | **refactor** | Restructuring code, no behavior change |
| ⚡ | **perf** | Performance improvement |
| 💫 | **style** | Formatting only, no logic change |
| 🧪 | **test** | Adding or correcting tests |
| 📄 | **document** | README, API docs, comments |
| 🏗️ | **build** | Build system, CI pipeline, project version |
| ⚙️ | **ci** | CI/CD configuration files and scripts |
| 🧹 | **chore** | Misc changes (deps, .gitignore, etc.) that aren't `upgrade` |
| 🖥️ | **ops** | Infrastructure, deployment, backup, recovery |
| ⏪ | **revert** | Reverting a previous commit |
| 🚀 | **release** | Cutting or preparing a release |
| 🗑️ | **remove** | Deleting code, files, or dead functionality |
| 🔼 | **upgrade** | Bumping a dependency version |

### 1. 📦 **add** - New Feature
Introduces a new feature or capability to the codebase.

```
📦 add(auth): add JWT token refresh mechanism
```

### 2. 🛠️ **fix** - Bug Fix
Fixes a bug in the existing code.

```
🛠️ fix(validation): correct email regex pattern
```

### 3. 🔃 **refactor** - Code Refactoring
Restructures code without changing functionality or fixing bugs.

```
🔃 refactor(api): simplify error handling logic
```

### 4. ⚡ **perf** - Performance Improvement
Improves code performance or application speed.

```
⚡ perf(database): optimize query with indexing
```

### 5. 💫 **style** - Code Style Changes
Formatting, missing semicolons, whitespace, etc. (no code logic changes).

```
💫 style(formatting): add missing semicolons in utils.js
```

### 6. 🧪 **test** - Test Changes
Adds missing tests or corrects existing test cases.

```
🧪 test(auth): add unit tests for login flow
```

### 7. 📄 **document** - Documentation Changes
Updates README, API docs, comments, or documentation files.

```
📄 document(readme): add installation instructions
```

### 8. 🏗️ **build** - Build System Changes
Changes affecting build system, CI pipeline, dependencies, or project version.

```
🏗️ build(webpack): upgrade webpack to v5
```

### 9. ⚙️ **ci** - CI/CD Configuration
Changes to CI/CD configuration files and scripts.

```
⚙️ ci(github-actions): add automated testing workflow
```

### 10. 🧹 **chore** - Miscellaneous Changes
Changes that don't affect source or test files (dependencies, .gitignore, etc.)
and aren't a version bump (use `upgrade` for that).

```
🧹 chore(deps): tidy up unused entries in .gitignore
```

### 11. 🖥️ **ops** - Operational Changes
Infrastructure, deployment, backup, recovery, and operational components.

```
🖥️ ops(docker): update production Dockerfile configuration
```

### 12. ⏪ **revert** - Revert Previous Commit
Reverts a previous commit.

```
⏪ revert: undo commit abc1234 (fix login redirect issue)
```

### 13. 🚀 **release** - Release
Cuts or prepares a release (version bump, changelog, tagging).

```
🚀 release(app): cut version 1.3.0
```

### 14. 🗑️ **remove** - Removal
Deletes code, files, or dead functionality outright.

```
🗑️ remove(legacy-auth): delete unused OAuth1 flow
```

### 15. 🔼 **upgrade** - Dependency Upgrade
Bumps a dependency to a newer version.

```
🔼 upgrade(deps): bump dio to 5.4.0
```

---

## Writing Guidelines

### ✅ Do's

- **Use imperative mood** - "add feature" not "added feature"
- **Capitalize the subject line** - Start with capital letter
- **Don't end with a period** - No period at end of subject
- **Separate subject from body** - Use blank line after subject
- **Limit subject to 50 characters** - Keep it concise
- **Wrap body at 72 characters** - Better readability in terminals
- **Use body to explain WHAT and WHY** - Not just HOW
- **Use scope when relevant** - Clarifies which part of code is affected
- **Reference issues** - Link related issues/PRs in footer

### ❌ Don'ts

- ❌ Don't use vague messages like "fix stuff" or "update code"
- ❌ Don't mix multiple features in one commit
- ❌ Don't use lowercase type prefix
- ❌ Don't end subject line with period
- ❌ Don't write multiple topics in one commit message
- ❌ Don't forget to mention breaking changes
- ❌ Don't omit the emoji, and don't mismatch it to the type

---

## Examples

### Example 1: Flutter Widget Feature

```
📦 add(ui/main): create dashboard shell navigation

Implemented HomeScreen widget with BottomNavigationBar.
Added navigation between Feed, Explore, and Profile pages.
Used Provider for state management across navigation states.

Dependencies added:
- provider: ^6.0.0

Closes #1234
```

### Example 2: Bug Fix in Widget Rendering

```
🛠️ fix(ui/profile): resolve profile image not displaying on iOS

The NetworkImage was not caching properly on iOS due to 
missing cache headers. Added CachedNetworkImage from 
cached_network_image package with proper cache management.

Tested on:
- iOS 15.0+
- Android 10+

Fixes #5678
```

### Example 3: State Management Refactoring

```
🔃 refactor(state): migrate GetX to Provider pattern

Consolidated all GetX controllers into Provider notifiers.
Simplified dependency injection and improved testability.
No user-facing changes.

Migration summary:
- 12 GetX controllers → 12 ChangeNotifier classes
- Routes simplified with go_router
- Reduced package dependencies

Related: #2345
```

### Example 4: Performance Optimization

```
⚡ perf(list): optimize FutureBuilder with pagination

Implemented pagination instead of loading all items at once.
Reduced initial load time from 3s to 400ms on slow networks.
Added shimmer loading indicator for better UX.

Dependencies:
- flutter_staggered_animations: ^1.1.1

Performance metrics:
- Initial load: 3000ms → 400ms
- Memory usage: 150MB → 45MB for 1000 items

Related: #3456
```

### Example 5: Flutter Test Addition

```
🧪 test(unit): add widget tests for authentication flow

Added comprehensive widget tests:
- LoginScreen validation tests
- SignupForm field validation
- ForgotPassword flow integration
- OTP verification screen

Test coverage increased from 58% to 78% for auth module

```bash
flutter test test/features/auth/
```

Closes #4567
```

### Example 6: Dart Code Style Fix

```
💫 style(dart): apply dartfmt and fix linting issues

- Formatted all Dart files with dartfmt
- Fixed 23 linting warnings from dart_linter
- Updated imports to follow library organization rules
- Added missing documentation comments

```bash
dartfmt -w .
dart analyze
```

No functional changes
```

### Example 7: Documentation Update

```
📄 document(readme): add setup instructions and architecture diagram

Added comprehensive README with:
- Project structure overview
- Setup & installation guide
- Architecture explanation (MVC with Provider)
- Running tests and building APK/IPA
- Contributing guidelines
- Troubleshooting section

Added architecture.md with visual diagrams
```

### Example 8: Dependency Update (Chore)

```
🧹 chore(pubspec): update Flutter and package dependencies

Updated packages:
- flutter: 3.13.0 → 3.16.0
- provider: 6.0.0 → 6.1.0
- dio: 5.2.0 → 5.3.1
- firebase_core: 2.20.0 → 2.24.0

All tests passing, no breaking changes
Compatibility verified with Flutter 3.16.0+
```

### Example 9: Platform-Specific Fix

```
🛠️ fix(platform): fix Android build issue with Gradle conflicts

Resolved Gradle dependency conflict in android/build.gradle.
Updated kotlin_version to 1.9.0 for compatibility with 
latest Firebase libraries.

```gradle
kotlin_version = '1.9.0'
```

Fixes Android build failure on machines with Kotlin 1.8.x

Tested on:
- Android SDK 34
- Gradle 8.2
```

### Example 10: Native Integration (Plugins)

```
📦 add(native): add biometric authentication using local_auth

Integrated biometric authentication for Android and iOS.
Added fingerprint and face recognition support.

New dependencies:
- local_auth: ^2.1.0
- local_auth_android: ^1.0.30
- local_auth_ios: ^1.0.10

iOS permissions added to Info.plist
Android permissions added to AndroidManifest.xml

Closes #6789
```

### Example 11: App Configuration/Build

```
🏗️ build(flutter): configure release build and signing

Set up Android release signing in android/app/build.gradle
Configured iOS release certificate and provisioning profiles
Added app version management in pubspec.yaml

Release checklist:
- ✅ Bumped version to 1.2.0
- ✅ Updated build number
- ✅ Generated signed APK
- ✅ Built IPA for App Store

Ready for release to Play Store and App Store
```

### Example 12: Revert Problematic Feature

```
⏪ revert: undo commit a1b2c3d (add dark mode theme)

This reverts commit a1b2c3d. Dark mode implementation 
caused memory leaks in ThemeProvider. Will revisit after 
refactoring theme architecture.

Related: #7890
Blocked by: Issue with Theme caching
```

### Example 13: API Integration

```
📦 add(api): integrate REST API with Dio and interceptors

Created API service layer using Dio with:
- Request/response interceptors for logging
- Token refresh on 401 responses
- Timeout handling and retry logic
- Custom error handling

New dependencies:
- dio: ^5.3.0
- pretty_dio_logger: ^1.3.1

API endpoints configured in constants/api_constants.dart

Closes #8901
```

### Example 14: Navigation Update

```
🔃 refactor(navigation): restructure app routing with go_router

Replaced deprecated Navigator 1.0 with go_router for 
declarative routing. Improved deep linking support and 
navigation state management.

Route structure:
- /auth/* - Authentication flows
- /main/* - Landing, dashboard, and shell screens
- /profile/* - User profile pages

Updated routes configuration in lib/config/router.dart

Breaking: Old route names no longer supported

Closes #9012


## Flutter Development Tips

### Best Practices for Commits

1. **Test before commit** - Run `flutter test` before committing
2. **Format code** - Use `dart format .` for consistency
3. **Analyze** - Run `flutter analyze` to catch issues
4. **Update pubspec** - Document dependency changes in commit
5. **Version bump** - Update version in pubspec.yaml for releases
6. **Platform testing** - Test on both iOS and Android when relevant
7. **Migration docs** - Document breaking changes clearly
8. **Performance notes** - Include metrics if it's a performance improvement

### Commit Checklist

- [ ] Code is formatted with `dart format`
- [ ] No analysis warnings (`flutter analyze`)
- [ ] Tests pass (`flutter test`)
- [ ] Commit message follows conventions
- [ ] Emoji matches the type
- [ ] Proper scope is used
- [ ] Platform info included (iOS/Android/Web)
- [ ] Dependencies documented (if any)
- [ ] Issue number referenced (if applicable)
- [ ] Body explains WHY not just WHAT
- [ ] No build artifacts committed

---

**Remember:** Clean commits make your Flutter project's history readable and maintainable for your entire team! 🚀

Happy committing! 💙

# Contributing to native_home_widgets

Thank you for your interest in contributing! This document outlines the guidelines and process for contributing to this project.

## Code of Conduct

Be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists
2. Open a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Platform (Android/iOS) and version
   - Flutter version (`flutter --version`)

### Suggesting Features

1. Open an issue with the `enhancement` label
2. Describe the use case and proposed API
3. Wait for maintainer feedback before implementing

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Write clear, focused commits
4. Add tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Ensure `flutter analyze` passes
7. Update documentation if needed
8. Submit PR with clear description

## Development Setup

```bash
git clone https://github.com/your-org/native_home_widgets.git
cd native_home_widgets
flutter pub get
cd example && flutter pub get
```

## Coding Standards

### Dart
- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use `flutter_lints` rules
- Document public APIs with `///` comments
- Keep functions small and focused
- Prefer immutability (`@immutable`, `const` constructors)

### Android (Kotlin)
- Follow [Kotlin Style Guide](https://developer.android.com/kotlin/style-guide)
- Use coroutines for async operations
- Prefer `val` over `var`
- Document public APIs with KDoc

### iOS (Swift)
- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use `let` over `var`
- Document public APIs with `///` comments
- Use `@available` annotations for version-gated APIs

## Project Structure

- `lib/` — Public Dart API
- `lib/src/` — Internal implementation
- `android/` — Kotlin native code
- `ios/` — Swift native code
- `test/` — Dart unit and widget tests
- `example/` — Example application

## Testing

- All new features require tests
- Run `flutter test` before submitting
- Aim for high coverage of models and services
- Mock platform interfaces for unit tests

## Versioning

This project follows [Semantic Versioning](https://semver.org/):
- `MAJOR` — Breaking API changes
- `MINOR` — New features (pre-1.0: breaking changes allowed)
- `PATCH` — Bug fixes

## Release Process

1. Update `CHANGELOG.md` with release date
2. Update version in `pubspec.yaml`
3. Create git tag: `git tag -a v0.1.0 -m "Release v0.1.0"`
4. Push to repository
5. Publish to `pub.dev`: `flutter pub publish`

## Questions?

Open an issue or discussion on GitHub.

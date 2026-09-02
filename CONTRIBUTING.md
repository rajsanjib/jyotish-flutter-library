# Contributing to Jyotish

Thank you for your interest in contributing to Jyotish! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Assume good intentions

## How to Contribute

### Reporting Bugs

Before creating a bug report:

1. Check if the bug has already been reported
2. Verify you're using the latest version
3. Check the SETUP.md guide to ensure proper configuration

When reporting bugs, include:

- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Platform and version information
- Code samples (if applicable)
- Error messages and stack traces

### Suggesting Features

Feature requests are welcome! Please:

- Check if the feature has already been requested
- Provide clear use cases
- Explain why this feature would be useful
- Consider whether it fits the library's scope

### Pull Requests

1. **Fork the repository** and create your branch from `main`

2. **Setup your development environment**:

   ```bash
   git clone https://github.com/yourusername/jyotish.git
   cd jyotish
   flutter pub get
   ```

3. **Make your changes**:

   - Write clear, readable code
   - Follow Dart style guidelines
   - Add tests for new functionality
   - Update documentation as needed

4. **Test your changes**:

   ```bash
   # Run tests
   flutter test

   # Run analysis
   flutter analyze

   # Format code
   dart format .
   ```

5. **Commit your changes**:

   - Use clear, descriptive commit messages
   - Reference related issues

6. **Submit a pull request**:
   - Provide a clear description of changes
   - Link to any related issues
   - Include screenshots for UI changes

## Development Guidelines

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` for consistent formatting
- Write self-documenting code with clear names
- Add comments for complex logic

### Testing

- Write unit tests for all new functionality
- Maintain or improve code coverage
- Test edge cases and error conditions
- Use descriptive test names

### Documentation

- Add dartdoc comments for public APIs
- Include usage examples
- Update README.md for significant changes
- Keep CHANGELOG.md up to date

### Commit Messages

Format: `type(scope): description`

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or changes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

Examples:

```
feat(calculations): add house calculation support
fix(position): correct nakshatra pada calculation
docs(readme): update installation instructions
```

## Project Structure

```
jyotish/
├── lib/
│   ├── jyotish.dart              # Main export file
│   └── src/
│       ├── jyotish_core.dart     # Core API
│       ├── bindings/             # FFI bindings
│       ├── models/               # Data models
│       ├── services/             # Business logic
│       ├── constants/            # Constants
│       └── exceptions/           # Exception classes
├── test/                         # Tests
├── example/                      # Example app
└── docs/                         # Additional documentation
```

## Testing Locally

### Unit Tests

```bash
flutter test
```

## Areas for Contribution

### High Priority

- House calculations
- Aspect calculations
- More comprehensive tests
- Performance optimizations
- Additional platform support

### Documentation

- More usage examples
- Video tutorials
- API reference improvements
- Translation to other languages

### Features

- Dasha system calculations
- Transit calculations
- Chart drawing utilities
- Additional ayanamsa systems
- Heliocentric calculations

## Questions?

- Open a GitHub issue
- Start a discussion
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Jyotish! 🙏

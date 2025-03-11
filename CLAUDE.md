# CLAUDE.md - Development Guide

## Build/Test/Lint Commands
- Install dependencies: `bundle install`
- Run all tests: `bundle exec rspec`
- Run single test file: `bundle exec rspec spec/path/to/file_spec.rb`
- Run specific test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Test watch mode: `bundle exec guard`
- Run linter: `bundle exec standardrb`
- Auto-fix linting issues: `bundle exec standardrb --fix`

## Code Style Guidelines
- Uses Standard Ruby for style enforcement (`gem "standard"`)
- Follow conventional Rails Engine directory structure
- Model classes go in `app/models/file_system/`
- Tests go in `spec/models/file_system/`
- Use RSpec for testing with descriptive contexts and examples
- Follow Ruby naming conventions:
  - snake_case for methods and variables
  - CamelCase for classes and modules
  - SCREAMING_SNAKE_CASE for constants
- Add appropriate documentation for public methods
# AI Project Rules

This project is a minimalistic state management package for Flutter.

## Core Principles

1.  **Minimal Dependencies**
    - The package must use ONLY Flutter internal classes and widgets.
    - No external dependencies (like `provider`, `riverpod`, etc.) should be added to the core logic.

2.  **Ease of Use**
    - The API should be very convenient and intuitive, even for inexperienced developers.
    - Minimize boilerplate and complex setup patterns.

3.  **Rich Capabilities & Scalability**
    - While being simple to start, it should offer rich capabilities for larger projects.
    - The architecture should support growth as the project's needs and the developer's experience increase.

4.  **Comprehensive Examples**
    - Changes in the package must be reflected in the `example/` directory.
    - The example should demonstrate all capabilities of the package.

5.  **Test Documentation**
    - Usage of the "GIVEN, WHEN, THEN" pattern is mandatory for documenting tests.
    - **Atomic Tests**: Test only one aspect of the code at a time. Do not chain multiple WHEN/THEN clauses in one test.
    - **Formatting**: Use the specific string template with triple quotes:
      ```dart
      testWidgets('GIVEN: [state], '
        'WHEN: [action], '
        'THEN: [result]',
        ...
      );
      ```
    - DO NOT use comments for this. Use the pattern directly in the test description.

6.  **Tooling & Workflow**
    - **Prefer MCP Tools**: Always use `dart-mcp-server` tools (e.g., `analyze_files`, `run_test`, `dart_format`) instead of direct console commands for project operations.
    - **Dart Tooling Daemon (DTD)**: Connect to DTD whenever available to leverage advanced AI capabilities like widget tree inspection and real-time runtime error analysis.

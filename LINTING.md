# Linting and Formatting Configuration

This project uses automated linting and formatting to maintain code quality and consistency.

## EditorConfig

The `.editorconfig` file provides basic formatting rules that work with most editors:

- **Max line length**: 100 characters
- **Trailing whitespace**: Automatically removed
- **Indentation**: Tabs for GDScript files
- **Line endings**: LF (Unix-style)
- **Final newline**: Required

Most modern editors (VS Code, Cursor, etc.) automatically respect these settings.

## GDScript Linting

### Option 1: Built-in Godot Linter

Godot's built-in linter automatically checks your code. Configure it in:
- **Editor → Editor Settings → Text Editor → Completion → GDScript**

The linter checks for:
- Max line length (100 characters)
- Trailing whitespace
- Code style issues

### Option 2: External Tool (gdtoolkit)

For more advanced linting and formatting, use [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit):

#### Installation

```bash
pip install gdtoolkit
```

#### Usage

**Lint a file:**
```bash
gdlint path/to/script.gd
```

**Lint all GDScript files:**
```bash
gdlint **/*.gd
```

**Format a file:**
```bash
gdformat path/to/script.gd
```

**Format all GDScript files:**
```bash
gdformat **/*.gd
```

#### Configuration

This project includes:
- `.gdlintrc` - Linter configuration (100 char line limit, whitespace checks, etc.)
- `.gdformatrc` - Formatter configuration

## Automatic Formatting

### VS Code / Cursor

Install the "GDScript" extension and enable:
- **Format on Save**
- **Editor: Format On Save** setting

### Pre-commit Hooks

You can set up pre-commit hooks to automatically format code:

```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml with:
#   - gdformat hook
#   - gdlint hook

# Install hooks
pre-commit install
```

## Common Issues

### Trailing Whitespace

The linter will flag lines ending with spaces or tabs. Most editors can remove these automatically.

### Max Line Length

Lines exceeding 100 characters will be flagged. Break long lines using:
- Line continuation with backslash (`\`)
- Breaking into multiple statements
- Using parentheses for natural breaks

### Mixed Tabs/Spaces

GDScript should use tabs for indentation. The linter will flag files with mixed tabs and spaces.


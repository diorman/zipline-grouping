# CSV Record Grouping

[![Test](https://github.com/diorman/zipline-grouping/workflows/Test/badge.svg)](https://github.com/diorman/zipline-grouping/actions)

Groups CSV records that may represent the same entity based on shared identifiers.

## Table of Contents
- [Assumptions](#assumptions)
- [How It Works](#how-it-works)
- [Performance](#performance)
- [Setup](#setup)
- [Usage](#usage)
- [Development](#development)
- [Testing](#testing)
- [Future Improvements](#future-improvements)

## Assumptions

- **Indirect matching is desired:** If A matches B and B matches C, all three are grouped
- **CSV files fit in memory:** Files are loaded entirely into memory for processing. For very large files, a two-pass streaming approach should be considered.
- **Column naming convention:**
  - Email columns: `Email`, `Email1`, `Email2`
  - Phone columns: `Phone`, `Phone1`, `Phone2`

## How It Works

### Algorithm Overview

The grouping algorithm uses a hash map where keys point to nodes, and each CSV row is associated with a node.

**Steps:**

1. Extract and normalize identifiers from each row based on matching type (see table below)
2. Look up keys in the hash map to find existing nodes
3. Associate row with a node:
   - No keys match: Create a new node, associate it with the row and its keys
   - Keys match one node: Reuse that existing node for this row
   - Keys match multiple nodes: Merge those nodes by creating a new parent node
4. Output row ID by following each row's node up to its root

**Example:** Given a row with `Email1: john@test.com, Phone2: 555-1234`

| Matching Type | Extracted Keys |
|---------------|----------------|
| `same_email` | `["email:john@test.com"]` |
| `same_phone` | `["phone:5551234"]` |
| `same_email_or_phone` | `["email:john@test.com", "phone:5551234"]` |

**Indirect grouping example:**
```
Step 1: Row 1 (email: john@test.com, phone: 111)
  Keys: ["email:john@test.com", "phone:111"]
  No existing nodes → Create Node A
  Map: email:john@test.com → Node A, phone:111 → Node A
  Row1 → Node A

Step 2: Row 2 (email: jane@test.com, phone: 222)
  Keys: ["email:jane@test.com", "phone:222"]
  No existing nodes → Create Node B
  Map: email:jane@test.com → Node B, phone:222 → Node B
  Row2 → Node B

Step 3: Row 3 (email: john@test.com, phone: 222)
  Keys: ["email:john@test.com", "phone:222"]
  email:john@test.com → Node A, phone:222 → Node B (multiple nodes!)
  Merge: Create Node C, set Node A and Node B as children of Node C
  Row3 → Node C
  All three rows now share Node C's ID
```

### Components

- **Node:** Structure for tracking groups. A root node represent a "person"
- **KeyBuilder:** Extracts and normalizes identifiers from rows
- **CSVProcessor:** Core grouping logic
- **CLI:** Command-line interface and argument validation

## Performance

The time complexity is O(n × m) where:
- n = number of rows
- m = average number of identifiers per row

**Note:** Most of the execution time is spent on CSV output formatting (creating CSV::Row objects and calling `.to_csv`).
For very large files, performance could potentially be improved by preserving original CSV lines and prepending IDs directly,
avoiding the CSV formatting overhead.

## Setup

### Requirements

- **Ruby:** 3.4+
- **Make:** GNU Make (optional, for convenience commands)

### Development Environment

This project uses [Nix](https://nix.dev/) for reproducible development environments and CI/CD:
```sh
# If you have Nix installed
nix develop

# Or with direnv (recommended)
cp .envrc.nix.example .envrc.nix
direnv allow
```

**Without Nix:**
```sh
# Ensure Ruby 3.4+ is installed
ruby --version
```

### Dependencies

Install gems:

```sh
bundle install
```

| Gem | Purpose |
|-----|---------|
| `csv` | CSV parsing. Bundled gem as of ruby 3.4 |
| `minitest` | Testing framework |
| `simplecov` | Code coverage reporting |
| `simplecov-console` | Terminal coverage output |
| `rubocop-shopify` | Code linting and style |
| `ruby-lsp` | Language server for editor support |

## Usage

### Basic Usage
```sh
./bin/run <input_file.csv> <matching_type>
```

### Examples
```sh
# Group by email only
./bin/run sample_inputs/input1.csv same_email

# Group by phone only
./bin/run sample_inputs/input2.csv same_phone

# Group by email OR phone (same_phone_or_email is also supported as matching type)
./bin/run sample_inputs/input3.csv same_email_or_phone
```

### Input Format

CSV file with headers. The tool recognizes these column names:
- **Email columns:** `Email`, `Email1`, `Email2`
- **Phone columns:** `Phone`, `Phone1`, `Phone2`

### Output Format

Same as input CSV with an `ID` column prepended. Records with the same `ID` represent the same entity.

**Example:**

Input:
```csv
FirstName,LastName,Email,Phone
John,Doe,john@test.com,555-1234
Jane,Doe,john@test.com,555-5678
```

Output:
```csv
ID,FirstName,LastName,Email,Phone
ae0b0d2c-a8a9-4f49-ae3e-110c8db1e557,John,Doe,john@test.com,555-1234
ae0b0d2c-a8a9-4f49-ae3e-110c8db1e557,Jane,Doe,john@test.com,555-5678
```

## Development

### Running Tests
```sh
# Run all tests
make test
```

### Linting
```sh
# Run Rubocop
make lint
```

### Project Structure
```
.
├── bin/
│   └── run                  # Executable entry point
├── lib/
│   ├── cli.rb              # Command-line interface
│   ├── csv_processor.rb    # CSV processing
│   ├── key_builder.rb      # Identifier extraction
│   ├── node.rb             # Union-find data structure
│   └── environment.rb      # Load path configuration
├── test/
│   ├── test_helper.rb      # Test configuration
│   ├── key_builder_test.rb
│   ├── node_test.rb
│   └── csv_processor_test.rb
├── sample_inputs/          # Example CSV files
│   ├── input1.csv
│   ├── input2.csv
│   └── input3.csv
├── Gemfile                 # Gem dependencies
├── Makefile                # Development commands
├── flake.nix               # Nix development environment
└── README.md
```

## Future Improvements

Given more time, I would:
- Add comprehensive inline code documentation
- Optimize CSV output formatting
- Support configurable column name patterns
- Implement streaming mode for very large files

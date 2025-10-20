# mangroves

This is a Rails 8.0 app.

## Prerequisites

This project requires:

- Ruby (see [.ruby-version](./.ruby-version)), preferably managed using [rbenv](https://github.com/rbenv/rbenv)
- PostgreSQL must be installed and accepting connections

On macOS, these [Homebrew](http://brew.sh) packages are recommended:

```
brew install rbenv
brew install postgresql@17
```

## Getting started

### bin/setup

Run this script to install necessary dependencies and prepare the Rails app to be started for the first time.

```
bin/setup
```

> [!TIP]
> The `bin/setup` script is idempotent and is designed to be run often. You should run it every time you pull code that introduces new dependencies or makes other significant changes to the project.

> [!TIP]
> To drop your existing database and start over with a clean local environment, use `bin/setup --reset`.

### Run the app!

Start the Rails server with this command:

```
bin/dev
```

The app will be located at <http://localhost:3000/>.

## Development

Use this command to run the full suite of automated tests and lint checks:

```
bin/rake
```

> [!TIP]
> Rake allows you to run all checks in parallel with the `-m` option. This is much faster, but since the output is interleaved, it may be harder to read.

```
bin/rake -m
```

### Fixing lint issues

Some lint issues can be auto-corrected. To fix them, run:

```
bin/rake fix
```

> [!WARNING]
> A small number of Rubocop's auto-corrections are considered "unsafe" and may
> occasionally produce incorrect results. After running `fix`, you should
> review the changes and make sure the code still works as intended.

---

```shell
mangroves main
❯❯ rails stats
+----------------------+--------+--------+---------+---------+-----+-------+
| Name                 |  Lines |    LOC | Classes | Methods | M/C | LOC/M |
+----------------------+--------+--------+---------+---------+-----+-------+
| Controllers          |    364 |    273 |       7 |      41 |   5 |     4 |
| Helpers              |     12 |      6 |       0 |       0 |   0 |     0 |
| Jobs                 |     33 |     13 |       1 |       0 |   0 |     0 |
| Models               |    707 |    334 |      10 |      34 |   3 |     7 |
| Mailers              |     57 |     23 |       1 |       3 |   3 |     5 |
| Views                |    802 |    627 |       0 |       1 |   0 |   625 |
| Stylesheets          |     10 |     10 |       0 |       0 |   0 |     0 |
| JavaScript           |   2809 |   2250 |       0 |       0 |   0 |     0 |
| Libraries            |    319 |    242 |       0 |       6 |   0 |    38 |
| Component specs      |   4449 |   3509 |       0 |       7 |   0 |   499 |
| Job specs            |    122 |     80 |       2 |       2 |   1 |    38 |
| Mailer specs         |    182 |    133 |       1 |       1 |   1 |   131 |
| Model specs          |    549 |    229 |       0 |       3 |   0 |    74 |
| Policy specs         |    581 |    462 |       0 |       0 |   0 |     0 |
| Request specs        |    675 |    524 |       0 |       0 |   0 |     0 |
| Tool specs           |     26 |     19 |       0 |       0 |   0 |     0 |
| Policies             |    236 |    153 |       8 |      39 |   4 |     1 |
+----------------------+--------+--------+---------+---------+-----+-------+
| Total                |  11933 |   8887 |      30 |     137 |   4 |    62 |
+----------------------+--------+--------+---------+---------+-----+-------+
  Code LOC: 3931     Test LOC: 4956     Code to Test Ratio: 1:1.3
```

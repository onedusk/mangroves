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
| Controllers          |    392 |    294 |       7 |      42 |   6 |     5 |
| Helpers              |     66 |     36 |       0 |       3 |   0 |    10 |
| Jobs                 |     33 |     13 |       1 |       0 |   0 |     0 |
| Models               |    798 |    389 |      10 |      36 |   3 |     8 |
| Mailers              |     57 |     23 |       1 |       3 |   3 |     5 |
| Views                |    819 |    640 |       0 |       1 |   0 |   638 |
| Stylesheets          |     10 |     10 |       0 |       0 |   0 |     0 |
| JavaScript           |   3489 |   2746 |       0 |       4 |   0 |   684 |
| Libraries            |    319 |    242 |       0 |       6 |   0 |    38 |
| Component specs      |   5529 |   4326 |       0 |      10 |   0 |   430 |
| Concurrency specs    |    277 |    222 |       0 |       0 |   0 |     0 |
| Integration specs    |    282 |    206 |       0 |       1 |   0 |   204 |
| Job specs            |    122 |     80 |       2 |       2 |   1 |    38 |
| Mailer specs         |    182 |    133 |       1 |       1 |   1 |   131 |
| Model specs          |    586 |    250 |       0 |       4 |   0 |    60 |
| Performance specs    |    246 |    199 |       0 |       1 |   0 |   197 |
| Policy specs         |    581 |    462 |       0 |       0 |   0 |     0 |
| Request specs        |    851 |    662 |       0 |       0 |   0 |     0 |
| Security specs       |   1518 |   1157 |       0 |       0 |   0 |     0 |
| System specs         |   1048 |    752 |       0 |       1 |   0 |   750 |
| Tool specs           |     31 |     23 |       0 |       0 |   0 |     0 |
+----------------------+--------+--------+---------+---------+-----+-------+
| Total                |  17236 |  12865 |      22 |     115 |   5 |   109 |
+----------------------+--------+--------+---------+---------+-----+-------+
  Code LOC: 4393     Test LOC: 8472     Code to Test Ratio: 1:1.9
```

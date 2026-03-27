# BabyVinci

Shared baby tracking for two sleep-deprived parents.

## Current implemented slice

- P1-01 Parent sign up / sign in
- Parent can create an account with name, email, password, and password confirmation.
- Parent can sign in, sign out, and see a clear error for invalid credentials.
- Password reset request and reset screens are available through the Rails authentication generator.

## Local setup

```bash
bin/rails db:migrate
bin/dev
```

## Verification

```bash
bin/rails test
```

## Production DB sync

```bash
bin/pull-production-db
```

The script snapshots production SQLite through `bin/kamal`, backs up your current local database, and replaces `storage/development.sqlite3` by default.

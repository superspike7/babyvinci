## Development Server

**Always assume a Rails development server is running on `localhost:3000`**

This project uses Rails default development server setup:
- `rails server` starts the server on port 3000
- No need to start/stop servers during development
- All commands assume server is accessible at `http://localhost:3000`

Start server manually if needed:
```bash
rails server
# or
rails server -p 3000
```


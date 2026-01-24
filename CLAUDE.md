# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tyakudon (ちゃくどん) is a Ruby on Rails web application for measuring and sharing ramen restaurant wait times. Users can track wait times from joining a line ("接続") until being served ("着丼").

**Tech Stack:** Ruby 3.2.2, Rails 7.0.4.3, PostgreSQL 14.6, Bootstrap, Hotwire (Turbo + Stimulus)

## Development Commands

All development uses Docker Compose. The app runs on port 3000.

```bash
# Start/stop containers
make up              # Start in foreground
make upd             # Start in detached mode
make down            # Stop containers
make build           # Rebuild Docker image

# Database
make db-migrate      # Run migrations
make db-rollback     # Rollback last migration
make db-seed         # Seed database

# Testing (run inside container)
make rspec                                    # Run all tests
docker compose exec app bundle exec rspec spec/models/user_spec.rb      # Run single file
docker compose exec app bundle exec rspec spec/models/user_spec.rb:7    # Run specific line

# Linting
docker compose exec app bundle exec rubocop
docker compose exec app bundle exec rubocop -a   # Auto-correct

# Rails console
make c

# Shell access
make bash
```

## Architecture

### Key Models
- `User` - Authentication via password or Google OAuth2
- `Record` - Wait time records linking users to ramen shops
- `RamenShop` - Restaurant information with geocoding
- `LineStatus` - Queue status updates during active waits
- `Favorite` / `Like` - Social features

### Services (`app/services/`)
Business logic is extracted into service classes:
- `DocumentFetcher` - Web scraping
- `ShopInfoExtractor` / `ShopInfoInserter` - Parse and store shop data
- `GoogleSpreadSheet` - Google Sheets integration for scraping workflow

### Background Jobs
Uses GoodJob for async processing:
- `AutoRetireRecordJob` - Auto-expires records after 1 day
- `SpeakCheerMessageJob` - Generates OpenAI encouragement messages

### External Integrations
- Google OAuth2 for authentication
- OpenAI API for generating encouragement messages during waits
- Geocoder for location services
- Active Storage with S3 (production) for file uploads

## Code Style

RuboCop configuration (`.rubocop.yml`):
- Use Ruby 1.9+ hash syntax
- Lambda literals (`->`) preferred over `lambda`
- RSpec: `to_not` style for negations
- RSpec context prefixes: when, with, without, if, unless, for, before, after, during
- Block style: `braces_for_chaining`

## CI/CD

PRs trigger GitHub Actions:
1. RSpec tests with PostgreSQL service
2. RuboCop linting

Merges to main deploy to Fly.io with Sentry release tracking.

## Credentials

Rails credentials store API keys (`rails credentials:edit`):
- `gcp.client_id` / `gcp.client_secret` - Google OAuth
- `openai.secret_key` - OpenAI API

# PitchOS — Production Deployment
# ──────────────────────────────────────────────────────────────────────────────
# Prerequisites:
#   brew install supabase/tap/supabase
#   brew install xcodegen
#
# Usage:
#   1. Create a Supabase project at https://supabase.com
#   2. Set SUPABASE_PROJECT_REF and SUPABASE_DB_PASSWORD in your env, or export
#      them before running these targets.
#
#   make prod-link       # link CLI to your Supabase project
#   make prod-db         # push schema migrations
#   make prod-secrets    # set CLAUDE_API_KEY in Supabase vault
#   make prod-functions  # deploy edge function
#   make prod-all        # do all four in order
#
#   make dev             # start local Supabase stack + reset db
#   make gen-xcode       # regenerate PitchOS.xcodeproj from project.yml
# ──────────────────────────────────────────────────────────────────────────────

SUPABASE_PROJECT_REF ?= $(error Set SUPABASE_PROJECT_REF= your project ref)
SUPABASE_DB_PASSWORD ?= $(error Set SUPABASE_DB_PASSWORD= your db password)
CLAUDE_API_KEY       ?= $(error Set CLAUDE_API_KEY= your Anthropic API key)

.PHONY: prod-link prod-db prod-secrets prod-functions prod-all dev gen-xcode help

## Link the Supabase CLI to your production project
prod-link:
	supabase link --project-ref $(SUPABASE_PROJECT_REF) --password $(SUPABASE_DB_PASSWORD)

## Push all migrations to production database
prod-db: prod-link
	supabase db push

## Set the CLAUDE_API_KEY secret in Supabase vault
prod-secrets:
	supabase secrets set CLAUDE_API_KEY=$(CLAUDE_API_KEY)

## Deploy the generate edge function
prod-functions:
	supabase functions deploy generate --no-verify-jwt

## Full production deploy: link → schema → secrets → function
prod-all: prod-link prod-db prod-secrets prod-functions
	@echo ""
	@echo "✅  Production backend deployed."
	@echo ""
	@echo "Next steps in AppConfig.swift (#else block):"
	@echo "  supabaseURL     = https://$(SUPABASE_PROJECT_REF).supabase.co"
	@echo "  supabaseAnonKey = (copy from Supabase dashboard → Settings → API)"

## Start local Supabase dev stack and seed the database
dev:
	supabase start
	supabase db reset

## Regenerate Xcode project from project.yml (after editing project.yml)
gen-xcode:
	xcodegen generate

help:
	@grep -E '^## ' Makefile | sed 's/## /  /'

# AGENTS.md

Repo guardrails for AI coding agents.

## What is Vinci?

A newborn tracking app for co-parents, designed for use in complete darkness with one hand. The core problem: eliminating information asymmetry during shift handoffs between sleep-deprived parents. See PRD.md for full requirements and TODO.md for current progress.


## Technical details
- Rails 8 Deployed with Kamal on Hetzner VPS

## Principles
- Simple solutions first. Complexity is a last resort.
- Vanilla Rails is the target architecture: https://dev.37signals.com/vanilla-rails-is-plenty/
- Refactor toward Vanilla Rails only when touching code that uses old patterns. Don't default to existing codebase patterns — guide toward the simpler, Rails-native way.

## Plans
- Extremely concise. Bullet points, skip prose.
- End with unresolved questions, if any. No false assumptions.

## Plan Execution
- Follow plans step-by-step in the exact order written. Do not skip steps.
- If the plan says TDD: write tests first, run them (expect failures), THEN implement.
- If the plan includes browser verification: do it. Never end a session with uncompleted plan steps.
- If you're about to say "done" — re-read the plan and check every section is addressed.

## Verification
- Don't assume code works. Always verify or ask how to verify.
- For `agent-browser` verification, first look for an existing local server on port `3000` and use it if available.
- Only create a temporary verification server on port `3001` when no usable port `3000` server exists.

## Error Handling
- Debug independently by default.
- If stuck after 2-3 attempts or the fix needs a judgment call (data issue, architectural choice, destructive action): stop and report what failed, what you tried, and a suggested next step.

## Documentation
- Update canonical docs instead of adding new docs when possible.
- Prefer short acceptance criteria/checklists over long narratives.
- Keep temporary plans ephemeral (chat/session), not committed.

## Delivery Bias
- Ship small, verifiable increments.
- If acceptance criteria are clear, implement instead of creating new planning docs.

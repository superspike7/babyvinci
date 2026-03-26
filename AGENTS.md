# AGENTS.md

Repo guardrails for AI coding agents.

## What is Vinci?

A newborn tracking app for co-parents, designed for use in complete darkness with one hand. The core problem: eliminating information asymmetry during shift handoffs between sleep-deprived parents.

## Technical details
- Rails 8 (Will be Deployed with Kamal on Hetzner VPS)

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

## PRD Task Workflow
- Start by reading `PRD.md` and implement the current PRD task unless the user names a different one.
- Treat user-stated technical preferences as optional constraints for that task, not default architecture policy.
- Default PRD task order: understand the task contract in `PRD.md` (ask clarifying questions only if needed), implement code to match that contract, write/update written tests, review/refactor if needed, then run automated QA and `agent-browser` end-to-end verification as contract evidence.
- If a PRD task is underspecified, update `PRD.md` first instead of inventing a separate quick task contract in chat.
- Definition of done for PRD tasks: written tests pass, `agent-browser` QA succeeds as contract evidence, and `PRD.md` progress tracker is updated.

## Anti-Laziness Guardrails
- Do not mark work done if it only works in isolation; verify the real user flow.
- Test how the feature is actually reached and used, not just the direct endpoint or happy-path unit.
- Cover both empty and populated states when the feature behavior changes across them.
- Verify acceptance criteria, automated checks, and manual/browser QA before updating progress.
- For non-trivial work, get an independent review when an appropriate reviewer is available.
- If a requirement is unverified, say so plainly and keep the task in progress.

## Task Completion Authority
- **NEVER mark PRD tasks as complete.** Only the user decides when a task is done.
- Present test results and QA evidence, then ask: "Ready to mark complete?"
- Wait for explicit user approval before updating PRD.md progress trackers.

## Verification
- Don't assume code works. Always verify or ask how to verify.
- Do not add Rails system tests. Prefer integration/controller/model tests for app coverage, and use `agent-browser` for end-to-end verification.
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

## UI Design Preference
@DESIGN.md

## My Production User Credentials
- email: "spikevinz@gmail.com"
- password: "^&*#0rIFsxd*rE0q"

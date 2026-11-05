# Plan · <feature>

- **Ticket:** <KEY, or "none" in a plain chat>
- **Date:** YYYY-MM-DD
- **Decisions:** NNN, NNN
- **Tech spec:** tuq/tech-specs/<feature>.md
- **Orchestrator prompt:** tuq/prompts/<feature>-orchestrator.md

<!-- tuq:plan:start -->

<Why this split, in a few lines: <feature> is built in N pieces, one behaviour each; what comes first
and why, what runs side by side. Name the decisions it follows. The agent in charge follows
tuq/prompts/<feature>-orchestrator.md.>

## Pieces

1. <Title of the one behaviour> — waits for nothing
   <Self-contained details: the files, the behaviour, the decisions and tech spec section it follows. When it
   crosses layers, say so: "one behaviour across API and page, on purpose".>
   Check: <how to see this one behaviour working>
2. <Title> — waits for 1
   <Details.>
   Check: <how to see it working>

<!-- tuq:plan:end -->

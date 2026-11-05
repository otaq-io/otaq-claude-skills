# Orchestrator · <feature>

- **Ticket:** <KEY, or "none" in a plain chat>
- **Date:** YYYY-MM-DD
- **Plan:** tug/plans/<feature>.md
- **Tech spec:** tug/tech-specs/<feature>.md
- **Decisions:** NNN, NNN

You are the agent in charge of building <feature>. You don't build the pieces: you start one agent per piece, check
what it hands back and merge it. Read the plan first; each piece's details there are its brief.

## Run order

<!-- tug:order:start -->

Start a piece as soon as every piece it waits for is merged:

- First: 1 <Title>

<!-- tug:order:end -->

## Running a piece

### In an Otaq build stage ($OTAQ_TICKET set, prime shows this Plan)

- Start a piece with `otaq helper start N --title "<the Plan's title>"`; when it has a note below, pass the note on
  stdin (`--stdin`).
- Check what it hands back with `otaq helper diff N` and the project's tests in its worktree (`otaq helper list`
  names it).
- Merge with `otaq helper merge N`, one piece at a time, then start the pieces that waited for it.
- Follow the build stage's own rules for questions, hand-backs and re-plans; this prompt never replaces them.

### Anywhere else

- Start one Agent call per piece with isolation "worktree". Its prompt: the piece's details from the plan, its note
  below, and "commit on your branch; don't merge".
- Check its diff and the project's tests in its worktree.
- Merge its branch into the current branch with `git merge`, one piece at a time, then start the pieces that waited
  for it.

## Notes per piece (only pieces that need one)

### Piece N

<Only what the orchestrator passes on or watches for beyond the plan's details.>

## Bringing it together

After the last merge: run the project's full tests, try each piece's Check: line on the merged branch, and
<anything else that proves the whole feature works>.

---
name: milestone-plan
description: >-
  Split a feature into the smallest pieces that each deliver one behaviour, with what waits for what, and write an
  orchestrator prompt for the agent that builds them: saves tuq/plans/<feature>.md and
  tuq/prompts/<feature>-orchestrator.md from the feature's decisions and tech spec. Runs as the Milestone plan
  stage of an Otaq ticket (keeping the ticket Plan's Pieces shape), or when the user types /tuq:milestone-plan.
argument-hint: "[feature]"
disable-model-invocation: true
adapted-from: "Otaq 0.1.0, built-in skill `milestone-plan` (plugin/skills/milestone-plan/SKILL.md)"
---

# Turn the specs into a Plan: tuq:milestone-plan

Adapted from Otaq 0.1.0's built-in `milestone-plan` skill: its stage contract is kept; its piece size rule is
replaced by "a piece is one behaviour" and its docs step by the tuq files. When Otaq's skill changes, merge the change here by
hand.

**Run `tuq rules` and read all of it before you read or write `tuq/`.** It holds the folder's layout and rules;
this skill doesn't repeat them. `tuq` and `tuq-plan` are commands the tuq plugin puts on the Bash tool's PATH
(`tuq-plan new`, `check`, `order`, `body`, `pull`; each takes the `<feature>` name, see step 6); this skill names no file
paths, so it works the same when Otaq copies only this `SKILL.md` into a ticket's worktree. `command not found` means
the plugin isn't enabled in this session: stop and say so.

## Which mode

Decide this first, before anything else:

```sh
if [ -n "$OTAQ_TICKET" ]; then otaq prime; fi   # then read "## Your stage"
```

- **`$OTAQ_TICKET` set and `otaq prime`'s "Your stage" is Milestone plan:** you run the stage. Follow "Steps" below
  as written.
- **`$OTAQ_TICKET` set but another stage** (Product spec, Tech spec, Dev, Validate...): **write nothing.** Tell the
  user that the plan belongs to the Milestone plan stage (a change goes through Spec review); in the build stage, say
  that the agent in charge already rewrites the Plan with `otaq update --plan-stdin`. Then stop.
- **`$OTAQ_TICKET` unset:** a plain chat. Follow "Steps" with the changes in "In a plain chat".

You run the **Milestone plan** stage of an Otaq ticket (its key is in `$OTAQ_TICKET`, for example `SHOP-40`).
Product spec settled what to build and Tech spec how; both committed their decisions and docs on the ticket's branch.
Your job is to turn them into work: the ticket's **Plan**, which says why the work is split the way it is and lists
its **pieces**, their order and what each waits for. The user checks it at Spec review, and in the build stage the
ticket's agent starts a helper for each piece and merges their work.

**You file nothing.** The whole deliverable stays this one ticket; its pieces live in its Plan.

**Your stage ends only when you run `otaq stage next`**, or pauses while you wait for the user's answer to `otaq ask
human --stdin`. A summary in this chat reaches no one: the board, the user and the next stage see only what those
commands carry. So when your work is done and nothing is open, don't stop to report or to ask whether to go on: commit
and end your stage. If you end your turn without either, Otaq types a reminder into this session.

## Steps

1. **Get the context first.** Run `otaq prime` and read all of it: the ticket, its description and its Plan (under
   "## Plan", when there is one), the **comments** (Product spec's and Tech spec's name the files and decisions they
   wrote), the user's **Agent instructions** and the project's notes ("Notes every agent in … gets"), the tickets it
   depends on, and the stages after yours. Otaq refuses to end your stage until you have run it: "Run `otaq prime`
   first: SHOP-40 has 2 comments you haven't read." **Open the reports from you before you start.** `prime` lists the
   files the user attached under "Reports from you · read these before you start"; read each one
   (`otaq report SHOP-40 1`, or search a long one with `grep -n "token" "$(otaq report SHOP-40 1 --path)"`). The
   agents' reports you open only when you need them.
2. **Follow the Agent instructions** that `prime` prints. They are the user's own rules (for example "pieces that
   touch one crate each") and they apply to every step below. They add to these steps; they never remove getting the context (step 1)
   or ending your stage (step 7).
3. **Read both specs.** `prime`'s first line names the branch it merges into (for example `main`):
   `git log --oneline main..HEAD` lists the planning commits, `git diff main...HEAD` shows them. Read every decision and
   doc they wrote, and the code the work touches.
4. **Decide the pieces**: **a piece is one behaviour**, one thing a user (or a caller) can see working
   when it is done ("a student can remove a book from a reading list"). It may touch every layer that behaviour needs
   (data, API, screen) and brings its own tests.
   - **List the behaviours first.** Read the product decisions about this feature (`tuq/decisions/`, indexed in
     `tuq/README.md`) and the tech spec, and write down for yourself every behaviour they ask for, one line each.
     Then map each behaviour to exactly one piece, so none is dropped or built twice.
   - **Split whenever there is more than one behaviour**, even when they share files. **Never split one behaviour by
     layer** (an API piece and a screen piece for the same behaviour). Shared groundwork that several behaviours need
     first (for example a new data model) may be its own piece, which they wait for, when it belongs to none of them.
   - **A piece that crosses layers says so** in its details ("one behaviour across the API and the page, on
     purpose"): the build stage measures a piece by one layer, and its helper might otherwise hand it back as too big.
   - **Every piece's details end with a `Check:` line**: how to see its one behaviour working on its own (a test, a
     page, a request).
   - **One piece when the work is one**: a small deliverable gets a Plan with a single piece.
   - **Order them by what each needs**: a piece waits for the pieces whose code it builds on ("the button waits for the
     API"). Pieces that wait for nothing, or for the same pieces, are built side by side, so don't chain what doesn't
     need chaining.
   - **Too big for one ticket?** When the work is really several deliverables, each worth reviewing and merging on its
     own, ask the user (see "Asking"). If they want several tickets, they ask Noyan to file them; you still file
     nothing, and you plan only what stays on this ticket.
5. **Write the ticket's Plan** with `otaq update` (see "Writing the Plan"): first the why (how the work is split and
   the order, in a few lines, naming the decisions it follows), then the **Pieces** list in its fixed shape.
6. **Write the orchestrator prompt** next to the plan, in `tuq/prompts/<feature>-orchestrator.md`. `tuq-plan new` created it from the template in step 5; fill in only the feature's parts, and never repeat a
   piece's details there (the plan holds them):
   - the intro under the header: what the feature is, in a line, and the header's Ticket, Date, Tech spec and
     Decisions lines (the same as the plan's);
   - **Notes per piece**, as `### Piece N` headings (by number, never by title), only for pieces that need one: what
     the orchestrator passes on or watches for beyond the plan's details. Delete the template's `### Piece N` stub
     when no piece needs a note;
   - **Bringing it together**: what proves the whole feature works after the last merge, beyond each piece's
     `Check:` line.
   - Leave "Run order" and "Running a piece" alone: `tuq-plan order` writes the run order, and "Running a piece" is
     the same for every feature.

   Then run `tuq-plan order "$F" && tuq-plan check "$F"` again; `check` must pass. Then **commit everything** on the
   ticket's branch with the commit skill `prime` names
   (`otaq-commit`, or your agent's own commit skill); when it names none, commit with `git add -A` and
   `git commit -m "SHOP-40: …"`. Nothing may stay uncommitted: `otaq stage next` is refused while files are
   uncommitted. **Never push.**

7. **End your stage** with a short comment on stdin, then end your turn: the number of pieces and each file you wrote,
   in a line or two (at most 2,000 characters). The user reads it at Spec review:

   ```sh
   otaq stage next --stdin <<'COMMENT'
   Milestone plan: 4 pieces; tuq/plans/wishlist.md, tuq/prompts/wishlist-orchestrator.md
   COMMENT
   ```

   Add `--manual-check "<what to check>"` for anything no agent will be able to check, one per check.

## Writing the Plan

The plan file `tuq/plans/<feature>.md` **owns the pieces**: the text between its plan markers is the ticket's Plan
word for word, and the run order in the prompt is generated from it. Never keep the pieces in step by hand.

**The feature name** (`$F` below) is the tech spec's: `tuq/tech-specs/<feature>.md` when it exists. Without one,
use 2–5 kebab-case words from the ticket's title (`reading-list-sharing`). When a plan file's `Ticket` line already
names this ticket (`grep -l "Ticket:\*\* $OTAQ_TICKET" tuq/plans/*.md`), use its name: planning again updates the
same two files. **No tech spec in `tuq/`** (Tech spec ran another skill): read the files Tech spec's comment names
instead, and name that file in the header's `Tech spec` line.

```sh
F=wishlist
tuq-plan new "$F"      # creates tuq/plans/$F.md and tuq/prompts/$F-orchestrator.md when missing
```

In the plan file, fill the header (Ticket, Date, the Decisions and Tech spec it builds on) and write the Plan between
`<!-- tuq:plan:start -->` and `<!-- tuq:plan:end -->`, nothing else there:

```markdown
<!-- tuq:plan:start -->

The wishlist is built in four pieces, one behaviour each: the share token first (groundwork the others
need), then saving and the page side by side, then the share link, which needs both. The agent in charge follows
tuq/prompts/wishlist-orchestrator.md.

## Pieces

1. Share token on wishlists — waits for nothing
   A random token per wishlist, created on first share: lib/wishlist.ts (decision 0141).
   Check: the token unit tests pass; an unknown token is rejected.
2. A customer saves an item — waits for 1
   The heart on each product card (components/ProductCard.tsx) and POST/DELETE /api/wishlist: one behaviour across
   the API and the card, on purpose.
   Check: tapping the heart saves the item; it is still saved after a reload.
3. A customer sees their wishlist — waits for 1
   /wishlist lists the saved items, with an empty state; GET /api/wishlist.
   Check: the page shows what was saved, and the empty state with nothing saved.
4. A customer shares their wishlist — waits for 2, 3
   The Share button on /wishlist and the read-only shared view, without the owner's email (decisions/0140).
   Check: the copied link opens the list signed out, with no email on the page.

<!-- tuq:plan:end -->
```

Then generate the run order, check the pair, and pass the Plan to Otaq. `otaq update` replaces the whole Plan; `body`
writes it to a temporary file outside the worktree:

```sh
tuq-plan order "$F" && tuq-plan check "$F"
plan="$(mktemp)"; tuq-plan body "$F" > "$plan"
otaq update SHOP-40 --plan-file "$plan"
```

The shape is fixed, because Otaq reads it to start the helpers (`check` fails, naming the file and line, when it
isn't kept):

- The list is headed `## Pieces` and comes **last** in the Plan: a heading after it ends the list.
- Each piece is numbered from 1, then its short title, then an em dash and what it waits for: "waits for nothing",
  "waits for 1", "waits for 2, 3". A piece only waits for pieces with a smaller number.
- Its details go on the lines under it, indented. **They must stand on their own**: a helper starts with a fresh
  context and reads only its piece, so name the files, screens and decisions it builds on, and anything its helper
  must not miss, so it doesn't have to explore again. Never statuses ("done", "in progress"): Otaq keeps those itself.
- The details end with the piece's `Check:` line, and the why names the orchestrator prompt's path, so the Developer,
  who sees only the Plan, finds it.

Every version of the ticket's Plan stays in its History, and every version of the plan file in git.

## In a plain chat

With no `$OTAQ_TICKET`, there is no ticket, no stage and nothing to hold a question. This skill only runs here when
the user typed `/tuq:milestone-plan`. Follow steps 3-6 above, with these changes, and skip everything that
names `otaq`:

- **Context instead of steps 1-3:** the user's request (the skill's argument names the feature), `CLAUDE.md` and the
  project's notes, `tuq/README.md`, the decisions about this feature, its tech spec in
  `tuq/tech-specs/<feature>.md`, and the code the work touches (read it, don't change it). The repository root is
  `git rev-parse --show-toplevel`; outside a git repository use the current directory and say so.
- **Ask with the AskUserQuestion tool**, one question per call, then wait for the answer, mapped from "Asking": each
  `--option` is an option `label` (at most 40 characters), its `--note` the option's `description`, the recommended
  option first with " (Recommended)" at the end of its label; the context goes in the question text. An **open
  question** is plain text in your reply; then end your turn.
- **"Too big for one ticket?" isn't asked:** there is no ticket. When the work is really several deliverables, each
  worth building and merging on its own, ask once whether to plan them as several features; on a yes, each gets its
  own pair of files, under its own feature name.
- **Write the two files as steps 5 and 6 say, but no ticket Plan**: skip `body` and `otaq update`, and write
  `none` in the header's Ticket lines. `tuq-plan check "$F"` must still pass. **Never commit, stage or push**: the
  user commits when they choose.
- **End** by naming the two files (`tuq/plans/<feature>.md`, `tuq/prompts/<feature>-orchestrator.md`) and the
  number of pieces, and say that the orchestrator prompt is what to run next: hand it to the session that will build
  the feature.

## When the ticket comes back

The user checks all three planning stages at Spec review. A Send back goes to Product spec; when Product spec and Tech
spec have finished, the card walks your stage again and this session resumes with a sentence such as:

> SHOP-40 is back in Milestone plan: Spec review sent it to Product spec, which finished. Run `otaq prime`.

When Spec review sends the card back to you directly, it reads "Spec review sent SHOP-40 back to you with a
comment. Run `otaq prime`." Either way:

1. Run `otaq prime` and read the new comments: the user's from Spec review is the feedback, and the specs' latest
   comments say what they changed.
2. **Start from the Plan as `prime` shows it now**, not from the one you wrote: the user may have edited it at Spec
   review. **Keep the user's edits** (a renamed piece, a moved wait, a piece they added or removed) unless their
   comment says otherwise. `tuq-plan pull "$F"` puts the ticket's current Plan between the plan file's markers;
   nothing else in the file changes.
3. **Change only what the comment asks**, or what the specs' changes make wrong, in the plan file (and the prompt's
   notes when a piece they name changed), then run `tuq-plan order "$F" && tuq-plan check "$F"`. When `check` names a
   line the user's edit broke (a hyphen for the em dash, a missing `Check:`), fix its shape and keep their content.
   Then write the whole Plan again with `tuq-plan body "$F" > "$plan"` and
   `otaq update SHOP-40 --plan-file "$plan"`, commit, and run
   `otaq stage next --stdin` again with a comment saying what changed ("Milestone plan: merged pieces 2 and 3 as you
   asked; kept your rename of piece 4").

## Long output

Long output (a long diff, a test run) goes to a file in `$OTAQ_RESOURCE_DIR`, Otaq's folder for this ticket outside
the repository, never in the worktree: `git diff main...HEAD > "$OTAQ_RESOURCE_DIR/spec-diff.txt"`, then
`grep -n "^+++" "$OTAQ_RESOURCE_DIR/spec-diff.txt"`. Search it; **never print it in full or retype it.** Name it in
your comment; never attach command output, such as a run, a diff or a log. **Attach only a document you wrote**, with
`--report-file "$OTAQ_RESOURCE_DIR/notes.md"`: a write-up the user or a later stage will read (an investigation, a
comparison of options). It goes into the repo only when the project's notes say research lives there.

## Asking

Ask the user only what the specs don't answer and changes the plan (one ticket or several, a piece the user may not
want). One question per turn, then end your turn; the answer arrives as the user's next message. When there are clear
alternatives, offer **2–4 options**, each with a note of its pros and cons, and recommend one when there is a sensible
default:

```sh
otaq ask human \
  --option "One ticket, 6 pieces" --note "One review and one merge; the share link waits for the whole wishlist." \
  --option "Two tickets" --note "Wishlist and Share link reviewed and merged apart; Noyan files the second one." \
  --recommended 1 --stdin <<'QUESTION'
The wishlist and the share link are each several pieces, and each could be reviewed and merged on its own. Plan them as one ticket or two?
QUESTION
```

An open question stays free text, with no options (`otaq ask human --stdin` and the question on stdin). The user's
Agent instructions take precedence over this guidance.

## Rules

- **File nothing**: you never create tickets. Several tickets are Noyan's, at the user's request.
- Plan the work; don't build it. The build stage's agent and its helpers write the code from the Plan.
- **Never push, never open a PR, never merge.** Commit on the ticket's branch only.
- **Long text always goes through stdin** (`--stdin`) or a file, never quoted arguments. Long command output goes to
  a file.
- The plan file owns the pieces: the ticket's Plan comes from `tuq-plan body`, the run order from `tuq-plan order`,
  and `tuq-plan check` passes before you commit.
- In an Otaq stage, always finish with `otaq stage next --stdin`. In a plain chat, never commit.

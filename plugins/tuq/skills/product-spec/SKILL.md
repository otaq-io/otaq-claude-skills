---
name: product-spec
description: >-
  Settle what a new feature or a change to what the product does should be, before any code: ask the user one
  product question at a time (never about the implementation) until every function and edge case is decided, and
  save each agreed point as a numbered decision in tuq/decisions/ after checking it against the earlier ones.
  Use when the user starts describing or exploring a feature ("I want users to...", "what if we added...", "let's
  spec this"), and as the Product spec stage of an Otaq ticket. Not for bug fixes, questions about existing code,
  refactors, reviews or other technical work.
argument-hint: "[feature or topic]"
adapted-from: "Otaq 0.1.0, built-in skill `product-spec` (plugin/skills/product-spec/SKILL.md)"
---

# Settle what to build: tuq:product-spec

Adapted from Otaq 0.1.0's built-in `product-spec` skill: its stage contract is kept (steps 1-8, "When the ticket
comes back", "Long output", "Asking" and "Rules" below); its decision format is replaced by tuq's rules
(`tuq rules`), and it also runs in a plain Claude Code chat ("In a plain chat"). When
Otaq's `product-spec` skill changes, merge the change here by hand.

**Run `tuq rules` and read all of it before you read or write `tuq/`.** It holds the folder's layout,
numbering, the decision file's shape, statuses, the conflict check and renumbering; this skill doesn't repeat them.
`tuq` is a command the tuq plugin puts on the Bash tool's PATH (`rules`, `template`, `init`, `next`, `index`,
`clashes`); this skill names no file paths, so it works the same when Otaq copies only this `SKILL.md` into a
ticket's worktree. `tuq: command not found` means the plugin isn't enabled in this session: stop and say so.

## Which mode

Decide this first, before anything else:

```sh
if [ -n "$OTAQ_TICKET" ]; then otaq prime; fi   # then read "## Your stage"
```

- **`$OTAQ_TICKET` set and `otaq prime`'s "Your stage" is Product spec:** you run the stage. Follow "Steps" below as
  written.
- **`$OTAQ_TICKET` set but another stage** (Tech spec, Dev, Validate...): **write nothing.** Tell the user that a
  product change for this ticket goes through Spec review (send it back to Product spec), or offer to file it as a
  follow-up with `otaq create "Title" --stdin`, and stop. Committing product decisions here would break that stage.
- **`$OTAQ_TICKET` unset:** a plain chat. Follow "Steps" with the changes in "In a plain chat".

You run the **Product spec** stage of an Otaq ticket (its key is in `$OTAQ_TICKET`, for example `SHOP-40`). No code
has been written for it yet. Your job is to settle **what to build, for whom and why** with the user, then write it
down as the project's own **product decisions and docs** and commit them on the ticket's branch. After you, Tech spec
works out how to build it from what you committed, Milestone plan turns both into the ticket's Plan, and the user
checks all three at Spec review.

The committed docs carry the reasons to the next stages, not only your comment: write each decision so someone who
never saw this conversation understands what was decided and why.

**Your stage ends only when you run `otaq stage next`** (or `otaq stage done` when there is nothing to deliver), or
pauses while you wait for the user's answer to `otaq ask human --stdin`. A summary in this chat reaches no one: the
board, the user and the next stage see only what those commands carry. So when your work is done and nothing is open,
don't stop to report or to ask whether to go on: commit and end your stage. If you end your turn without either, Otaq
types a reminder into this session.

## Steps

1. **Get the context first.** Run `otaq prime` and read all of it: the ticket and its description, the
   **comments**, the user's **Agent instructions** and the project's notes ("Notes every agent in … gets"), the
   tickets it depends on, and the stages after yours. Otaq refuses to end your stage until you have run it: "Run
   `otaq prime` first: SHOP-40 has 1 comment you haven't read." **Open the reports from you before you start.**
   `prime` lists the files the user attached under "Reports from you · read these before you start"; read each one
   (`otaq report SHOP-40 1`, or search a long one with `grep -n "share" "$(otaq report SHOP-40 1 --path)"`). The
   agents' reports you open only when you need them.
2. **Follow the Agent instructions** that `prime` prints. They are the user's own rules and they apply to every step
   below. They add to these steps; they never remove getting the context (step 1), asking one question at a time
   (step 5) or ending your stage (step 8).
3. **Find where the product decisions and docs live.** Product decisions always live in `tuq/decisions/` at the
   repository root, indexed in `tuq/README.md`, by `tuq rules`; read `tuq/README.md` and the
   decisions about this feature. The project's notes may name other product docs (an overview such as DESIGN.md):
   keep those in step too. When the ticket's description has no "Where the docs live" line for product decisions,
   add `- Product decisions: tuq/decisions/ (index tuq/README.md)` to it (see "Recording where the docs
   live"), so Tech spec and Milestone plan find it there. Don't ask the user where decisions go.
4. **Find the open points.** Read the description, the existing decisions and docs, and the code it touches, then list
   for yourself what is undecided about the product: what is asked, **for whom** (which users or roles) and **why**
   (the problem it solves), which screens and data, what happens at the edges (empty, too many, errors, signed out),
   what is out of scope, and how the user will know it works. A decision the new work contradicts is an open point too.
   Put the ones that change what gets built first. Drop anything the description, the decisions, the code or the
   Agent instructions already answer. How to build it is Tech spec's job: leave it out. **Never ask about the
   implementation** (libraries, APIs, storage, file layout): only what the product does.
5. **Ask one question at a time** with `otaq ask human --stdin` (see "Asking"), most important first, then **end
   your turn**. The ticket shows "Asks you" on the board; the answer arrives in this session as the user's next
   message. Read it. **When it settles a point, save that point now** (step 6: conflict check, then the decision
   file), then check your list again (an answer can settle or drop the next point), and ask the next question.
   Say where you are: "Question 2 of about 4". Once nothing that changes what gets built is open, or the user says
   "enough" or "go", go straight on to step 6. **No open points at all?** Then ask nothing and go straight on to step
   6: there is nothing to wait for. **The user says it is getting more complicated than it should be, or isn't sure
   about the set of decisions?** Offer a step back ("Want me to take a step back with `tuq:step-back` and look at the
   feature without its decisions?") and run `tuq:step-back` only after a yes.
6. **Write the product decisions and docs**, one point at a time, as soon as each is agreed, by `tuq rules`:
   - **Conflict check first** (`tuq rules`, "The conflict check"). On a conflict, don't save: the conflict question
     is your next question (step 5), and you wait for the answer.
   - Then `tuq next`, write `tuq/decisions/NNN-<slug>.md` from `tuq template decision` (`Ticket:` is `$OTAQ_TICKET`),
     mark a superseded decision's Status line only, and run `tuq index`. In a repo with no `tuq/` yet, run
     `tuq init` first and add the pointers `tuq rules` describes.
   - A point you saved earlier in this session and haven't committed is edited in place when the user changes it;
     anything committed changes only through a new, superseding decision.
   - Update the overview docs the project's notes name to match. You may edit any file the spec needs (an overview,
     a docs page, a sample), but don't build the feature: Dev does that.
7. **Commit everything** on the ticket's branch with the commit skill `prime` names (`otaq-commit`, or your agent's
   own commit skill); when it names none, commit with `git add -A` and `git commit -m "SHOP-40: …"`. Nothing may stay
   uncommitted: `otaq stage next` is refused while files are uncommitted. **Never push.**
8. **End your stage** with a short comment on stdin, then end your turn. It names **each file and decision you
   wrote**, then what you agreed, in a line or two (at most 2,000 characters). Tech spec, Milestone
   plan and the user at Spec review read it:

   ```sh
   otaq stage next --stdin --report-file "$OTAQ_RESOURCE_DIR/market-comparison.md" \
     --manual-check "Open a shared wishlist link in a private window" <<'COMMENT'
   Product spec: tuq/decisions/008 (the share link), 009 (who can open it), DESIGN.md; 004 superseded by 008;
   agreed: per-account storage, no email in the shared view.
   Attached: how three shops share wishlists.
   COMMENT
   ```

   When you agreed on something no agent will be able to check (it needs a real browser, a device, or a service the
   agents can't reach), list it with `--manual-check "<what to check>"`, one line per check, repeated for each. The
   user sees them as "Manual checks for you" at review.

   **Nothing to build?** Only when the user agrees the ticket isn't needed (for example "already fixed in SHOP-31")
   and you committed nothing, end the ticket instead, with the reason on stdin. It goes to Done as "Closed · nothing
   to merge":

   ```sh
   otaq stage done --stdin <<'REASON'
   Already fixed in SHOP-31: the user confirmed the share link there covers this.
   REASON
   ```

## In a plain chat

With no `$OTAQ_TICKET`, there is no ticket, no stage and nothing to hold a question. Follow steps 3-6 above, with
these changes, and skip everything that names `otaq`:

- **Context instead of step 1-2:** the user's request (the skill's argument, or what they just said), `CLAUDE.md`
  and the project's notes, `tuq/README.md` and the decisions about this feature, and the code the feature touches
  (read it, don't change it). The repository root is `git rev-parse --show-toplevel`; outside a git repository use
  the current directory and say so.
- **Ask with the AskUserQuestion tool**, one question per call, then wait for the answer, mapped from "Asking":
  each `--option` is an option `label` (at most 40 characters), its `--note` the option's `description`, the
  recommended option first with " (Recommended)" at the end of its label; the context and "Question 2 of about 4" go
  in the question text. An **open question** is plain text in your reply; then end your turn.
- **Write the decision files and run `tuq index`**, as step 6 says, with no `Ticket:` line. **Never commit,
  stage or push**: the user commits when they choose.
- **End** by listing every file you created or changed (decision numbers, the README, superseded files) and the
  points agreed, in a few lines.

## When the ticket comes back

At Spec review the user reads what all three planning stages wrote. When they send it back to you, this session
resumes with one plain sentence:

> Spec review sent SHOP-40 back to you with a comment. Run `otaq prime`.

Run `otaq prime` and read the user's comment under "Comments": it is the latest one, and it is all the feedback.
Fix what it asks: ask the user again one question at a time where the comment leaves something open, change the
decisions and docs, commit everything, and run `otaq stage next --stdin` again with a comment saying what changed
("Product spec: tuq/decisions/008 now keeps shared links for 30 days, as you asked"). The card then walks Tech spec and
Milestone plan again, so they pick up your change.

## Recording where the docs live

`otaq update` replaces the whole description, so send the old text with your note added. Keep what the user wrote:

```sh
otaq update SHOP-40 --stdin <<'BODY'
Let customers share their wishlist with a link.

## Where the docs live
- Product decisions: tuq/decisions/ (index tuq/README.md)
BODY
```

## Long output

Long output (a test run, a long log) goes to a file in `$OTAQ_RESOURCE_DIR`, Otaq's folder for this ticket outside
the repository, never in the worktree: `npm test > "$OTAQ_RESOURCE_DIR/test-run.txt" 2>&1`, then
`grep -n FAIL "$OTAQ_RESOURCE_DIR/test-run.txt"`. Search it; **never print it in full or retype it.** Name it in your
comment; never attach command output, such as a run, a diff or a log. **Attach only a document you wrote**, in
`$OTAQ_RESOURCE_DIR`, with `--report-file`: a write-up the user or a later stage will read (a market comparison, an
investigation, a comparison of options). It goes into the repo only when the project's notes say research lives there.

## Asking

When the question has a few clear alternatives, offer them as **2–4 options** so the user can answer with one key, give
each option a **note with its pros and cons**, and recommend one when there is a sensible default:

```sh
otaq ask human \
  --option "Anyone with the link" --note "Easy to send in a chat; anyone who gets the link sees the list." \
  --option "Signed-in friends" --note "Private, but each friend needs an account first: fewer people will look." \
  --recommended 1 --stdin <<'QUESTION'
Question 1 of about 4. Who can open a shared wishlist link?
QUESTION
```

An **open question** stays free text, with no options:

```sh
otaq ask human --stdin <<'QUESTION'
Question 2 of about 4. Who asked for wishlist sharing, and what do they want to do with it?
QUESTION
```

- **One question per turn.** A ticket holds one open question; a second one would replace the first.
- 2–4 options, each a short label (at most 40 characters). The context goes in the question, each option's pros and
  cons in its `--note`, right after its `--option`: one or two short sentences (at most about 200 characters) on
  what it costs and what it changes. Give every option one.
- Never invent options for an open question.
- The question text always goes through stdin; only the short labels and notes are arguments.
- The user may answer in the agent's terminal instead of Needs you; treat it the same.
- The user's Agent instructions take precedence over this guidance.

## Rules

- Settle the product, not the code: don't plan the code or start building, and never ask about the implementation.
- Product decisions go in `tuq/` by `tuq rules`; read them before you touch the folder.
- Ask before you decide anything that changes what gets built; don't guess an answer the user hasn't given.
- **Never push, never open a PR, never merge.** Commit on the ticket's branch only.
- **Long text always goes through stdin** (`--stdin`), never quoted arguments. Long command output never does: it
  goes to a file.
- In an Otaq stage, always finish with `otaq stage next --stdin` (or `otaq stage done --stdin` when there is nothing
  to build). In a plain chat, never commit.

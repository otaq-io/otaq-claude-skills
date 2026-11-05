---
name: tech-spec
description: >-
  Work out how to build a feature whose product decisions are settled in tuq/decisions/: read them and the code,
  draft the architecture (where it goes, the parts it adds or changes and how they depend on each other, data and
  APIs, alternatives considered) with a very small plain-text diagram, discuss any part the user questions until
  it is settled, and save tuq/tech-specs/<feature>.md. Runs as the Tech spec stage of an Otaq ticket, or when the
  user types /tuq:tech-spec. Technical questions only, never the product.
argument-hint: "[feature]"
disable-model-invocation: true
adapted-from: "Otaq 0.1.0, built-in skill `tech-spec` (plugin/skills/tech-spec/SKILL.md)"
---

# Work out how to build it: tuq:tech-spec

Adapted from Otaq 0.1.0's built-in `tech-spec` skill: its stage contract and "Shaping the design" are kept; its
asking rule is replaced by draft, then discuss (step 5) and its docs step by `tuq/tech-specs/` (steps 4 and 6); it
also runs in a plain Claude Code chat ("In a plain chat"). When Otaq's `tech-spec` skill changes, merge the change
here by hand.

**Run `tuq rules` and read all of it before you read or write `tuq/`.** It holds the folder's layout and the
shape of the decisions you build on; this skill doesn't repeat them. Start the tech spec from `tuq template
tech-spec`. `tuq` is a command the tuq plugin puts on the Bash tool's PATH; this skill names no file paths, so it
works the same when Otaq copies only this `SKILL.md` into a ticket's worktree. `tuq: command not found` means the
plugin isn't enabled in this session: stop and say so.

## Which mode

Decide this first, before anything else:

```sh
if [ -n "$OTAQ_TICKET" ]; then otaq prime; fi   # then read "## Your stage"
```

- **`$OTAQ_TICKET` set and `otaq prime`'s "Your stage" is Tech spec:** you run the stage. Follow "Steps" below as
  written.
- **`$OTAQ_TICKET` set but another stage** (Product spec, Dev, Validate...): **write nothing.** Tell the user that
  the tech spec belongs to the Tech spec stage and a change to it goes through Spec review, and stop.
- **`$OTAQ_TICKET` unset:** a plain chat. Follow "Steps" with the changes in "In a plain chat".

You run the **Tech spec** stage of an Otaq ticket (its key is in `$OTAQ_TICKET`, for example `SHOP-40`). Product
spec has settled **what** to build with the user and committed it on the ticket's branch, as numbered decisions in
`tuq/decisions/`. Your job is to work out **how** to build it, and write that down as the feature's **tech spec**,
`tuq/tech-specs/<feature>.md`, committed on the same branch. After you, Milestone plan turns both specs into the
ticket's Plan, and the user checks all three at Spec review.

The committed docs carry the reasons to the next stages, not only your comment: write each decision so someone who
never saw this conversation understands what was decided, what else was considered and why.

**Your stage ends only when you run `otaq stage next`** (or `otaq stage done` when there is nothing to deliver), or
pauses while you wait for the user's answer to `otaq ask human --stdin`. A summary in this chat reaches no one: the
board, the user and the next stage see only what those commands carry. So when your work is done and nothing is open,
don't stop to report or to ask whether to go on: commit and end your stage. If you end your turn without either, Otaq
types a reminder into this session.

## Steps

1. **Get the context first.** Run `otaq prime` and read all of it: the ticket and its description, the
   **comments** (Product spec's names the files and decisions it wrote), the user's **Agent instructions** and the
   project's notes ("Notes every agent in … gets"), the tickets it depends on, and the stages after yours. Otaq
   refuses to end your stage until you have run it: "Run `otaq prime` first: SHOP-40 has 1 comment you haven't read."
   **Open the reports from you before you start.** `prime` lists the files the user attached under "Reports from
   you · read these before you start"; read each one (`otaq report SHOP-40 1`, or search a long one with
   `grep -n "share" "$(otaq report SHOP-40 1 --path)"`). The agents' reports you open only when you need them.
2. **Follow the Agent instructions** that `prime` prints. They are the user's own rules and they apply to every step
   below. They add to these steps; they never remove getting the context (step 1) or ending your stage (step 7).
3. **Read what Product spec committed.** `prime`'s first line names the branch it merges into (for example `main`):
   `git log --oneline main..HEAD` lists the commits, `git diff main...HEAD` shows them. Read every decision and
   doc it wrote in full: they are what you build on. Read `tuq/README.md`'s index too, and the earlier decisions
   that touch the same feature.
4. **Find the tech spec file.** It is always `tuq/tech-specs/<feature>.md` at the repository root; don't ask the
   user where it goes.
   - **Same file on rework.** First look for a tech spec of this ticket:
     `grep -l "^- \*\*Ticket:\*\* $OTAQ_TICKET\$" tuq/tech-specs/*.md`. Found: use that file and its `<feature>`,
     and update it.
   - **Otherwise** `<feature>` is 2–5 kebab-case words from the ticket title (`reading-list-sharing`). When
     `tuq/plans/<feature>.md` already exists for this ticket, use its name, so the feature's tech spec, plan and
     prompt match by name.
   - **Where the docs live.** When the ticket's description has no "Tech spec" line under "Where the docs live", add
     `- Tech spec: tuq/tech-specs/<feature>.md` with `otaq update SHOP-40 --stdin` (the whole description, with
     the line added), so Milestone plan finds it there.
   - **No `tuq/` yet:** run `tuq init` and add the pointers `tuq rules` describes.
   - **No decisions about the feature** (Product spec wrote its docs elsewhere): read the files Product spec's
     comment names, name them in "How it is built", and write `Decisions: none` in the header.
5. **Work out how to build it: draft first, then discuss.** Read the code the work touches and decide: where the new
   code goes, the parts it adds or changes and how they depend on each other, the data it stores and how, the APIs
   and their shapes, what it reuses, how it is tested, and what could go wrong (migrations, load, security). Shape
   the design as "Shaping the design" says: start from the caller, design it twice when the shape matters, and check
   it against the warning signs.
   - **Draft:** write the **whole** tech spec file (see "The tech spec file") before you ask anything: every choice
     made, with its reason. Don't walk the user through the choices one by one first.
   - **Show and ask**, one open question with `otaq ask human --stdin` (no options: the answer is free text), then
     end your turn: the rough explanation in a few lines, the diagram, and the architecture decisions as a numbered
     list of one line each, then "What do you want to question or change? Reply with the point's number and what
     bothers you, or 'settled'." Name the file by its path in this worktree, so the user can open it; the question
     carries only the short version (see "Asking").
   - **Discuss:** when the answer questions or changes a point, revise the file in place, and ask the same closing
     question again, starting with your answer to that point (why the draft chose it, or what changed now). **One
     point per turn.** A point that changes the shape (a new module, a different store) runs "design it twice"
     again for that point and keeps the loser under "Considered".
   - **Settled** when the user says "settled", "enough", "go" or the like: go straight on to step 6. The file is kept
     current after each answer, so an interrupted session loses nothing.
   - **Technical only.** Never ask about the product: it is settled in `tuq/decisions/`. A point that turns out to
     be an open product question is not decided here: say so in your next question, write it under "Open product
     points" in the file, and design around it only where the design doesn't depend on the answer.
6. **Write the tech spec** in `tuq/tech-specs/<feature>.md`, then **commit everything** on the ticket's branch
   with the commit skill `prime` names (`otaq-commit`, or your agent's own commit skill); when it names none, commit
   with `git add -A` and `git commit -m "SHOP-40: …"`. Commit once, at the end. You may edit any file the spec needs
   (a schema sketch, a config sample), but don't build the feature: Dev does that. Nothing may stay uncommitted:
   `otaq stage next` is refused while files are uncommitted. **Never push.**
7. **End your stage** with a short comment on stdin, then end your turn. It names **the tech spec file and the
   decisions it builds on**, then the main choices, in a line or two (at most 2,000 characters), and any open product
   points, so the user sends the ticket back to Product spec at Spec review. Milestone plan and the user at Spec
   review read it:

   ```sh
   otaq stage next --stdin --report-file "$OTAQ_RESOURCE_DIR/options.md" <<'COMMENT'
   Tech spec: tuq/tech-specs/reading-list-sharing.md (decisions 008-010); a random token per list in the lists
   table, no new service. Attached: the approaches I weighed. Query plan: `$OTAQ_RESOURCE_DIR/query-plan.txt`
   COMMENT
   ```

   Add `--manual-check "<what to check>"` for anything no agent will be able to check (a real device, a service the
   agents can't reach), one per check.

   **Nothing to build?** Only when the user agrees the ticket isn't needed and the branch has no commits, end the
   ticket instead with `otaq stage done --stdin` and the reason on stdin. Once Product spec committed, use
   `otaq stage next`.

## The tech spec file

Start from `tuq template tech-spec` and fill it in. Rough on purpose: the explanation fits on
one screen and the whole file a few screens. It is the spec, not the plan: no step-by-step coding plan, no code.

- **Header exactly three lines:** `Ticket` (the ticket key; left out in a plain chat), `Date` (the day of the latest
  change), `Decisions` (the numbers it builds on, comma-separated, or `none`). No other header line: Milestone plan
  reads this shape.
- **How it is used:** the caller sketch of "Shaping the design".
- **How it is built:** a few short paragraphs: where the change goes, the parts it adds or changes, the data and
  APIs, what it reuses.
- **What changes: the diagram owns the dependencies.** One very small plain-text drawing in a ` ```text ` block:
  the parts the change touches and who calls or imports whom, each marked `[new]` or `[changed]` (untouched parts
  unmarked, and only where the change plugs in), a handful of lines. Find the dependencies by reading the imports and
  call sites of the touched files (`grep` for the language's import, require or use lines, or the LSP tool). No
  Mermaid, no images. The **Parts** table under it gives each part's path, new or changed, and role, but **no
  dependency column**: the dependencies are written once, in the diagram.
- **Architecture decisions:** numbered sections (`### 1. …`), each: what was chosen, why, and "Considered: … Lost:
  …" when there was a real alternative (always for a "design it twice" point). These are the numbered points of the
  discussion.
- **Testing** and **Risks:** two short sections.
- **Open product points:** only when there are any (step 5).

## In a plain chat

With no `$OTAQ_TICKET`, there is no ticket, no stage and nothing to hold a question. Follow steps 3-6 above, with
these changes, and skip everything that names `otaq`:

- **Context instead of steps 1-3:** the feature (the skill's argument, or what the user just said), `CLAUDE.md` and
  the project's notes, `tuq/README.md` and the decisions about this feature, and the code the feature touches
  (read it, don't change it). The repository root is `git rev-parse --show-toplevel`; outside a git repository use
  the current directory and say so.
- **The feature name** is the skill's argument in kebab case, or 2–5 words from the topic; reuse an existing
  `tuq/tech-specs/<feature>.md` or `tuq/plans/<feature>.md` of the same feature. No "Where the docs live" step.
- **No decisions about the feature:** ask once whether to run `/tuq:product-spec` first (recommended) or go on from
  the description, with `Decisions: none`.
- **The header has no `Ticket` line.**
- **Show and ask:** the draft (explanation, diagram, numbered points and the file's path) goes in your reply, then
  the AskUserQuestion tool asks "What do you want to question or change?" with the options `Settled (Recommended)`
  and `Change something`; the user types the details under "Other". Discuss one point per turn, as step 5 says.
  Any other question is mapped from "Asking": each `--option` an option `label` (at most 40 characters), its
  `--note` the option's `description`, the recommended option first with " (Recommended)" at the end of its label.
- **An open product point:** write it under "Open product points" and suggest `/tuq:product-spec`; decide nothing
  about it.
- **Never commit, stage or push**: the user commits when they choose.
- **End** by naming the file you wrote and the main choices in a few lines, and suggest `/tuq:milestone-plan <feature>`
  next.

## Shaping the design

1. **Start from the caller.** Before you decide the shape, write a few lines of how the new code will be used: the
   call site, the command the user types, or the request and its response. Derive the types and the module from it,
   not the other way round. Put the sketch in the doc, so Milestone plan, Dev and the user at Spec review see the
   shape at a glance:

   ```rust
   let link = wishlists.share(list_id)?;   // ShareLink { token, url }
   let list = wishlists.open_shared(&token)?;  // read-only Wishlist, or NotShared
   ```

2. **Design it twice when the shape matters**: the ticket adds a new module, a new stored data shape, or an API
   other code will call. Then sketch two whole shapes, not two variants of one ("a share token column in
   `wishlists`" against "a separate `shares` table"), pick one, and write the other in the doc's "considered" part
   with why it lost. A smaller change needs one design, as before.
3. **Check the chosen design against the warning signs.** The next contributor is an agent that sees only the files
   it opened, copies the nearest example and takes the shortest path that compiles; prefer the design where a change
   that looks right from one file is right for the whole repo. Fix each sign that fires; when you keep one on purpose,
   the decision says why. Don't list the ones that passed.
   - **Two writers of one state**: more than one module writes the same state or keeps its own copy. Give each
     piece of state one owner; the others read it or ask the owner.
   - **Two ways to do one task**: every way keeps gaining callers. Keep one.
   - **Lists kept in step by hand**: adding an item means editing several places. Keep one list and derive the
     rest, or make the build fail when they disagree.
   - **Pass-through layers**: a layer that only forwards the same arguments. Remove it, or give it real work.
   - **Shallow modules**: callers call several functions to do one thing, or the interface exposes its internal
     steps. Hide more behind a smaller interface.
   - **A decision leaking into several modules**: a storage format, wire type or policy that several modules
     depend on, so changing it means coordinated edits. Keep it behind one module.
   - **Internals other modules can import**: they become part of the interface. Make them private, so the import
     fails.

## When the ticket comes back

The user checks all three planning stages at Spec review; a Send back goes to Product spec. When Product spec has
finished its fix, the card walks your stage again and this session resumes with a sentence such as:

> SHOP-40 is back in Tech spec: Spec review sent it to Product spec, which finished. Run `otaq prime`.

Run `otaq prime`, read the new comments (the user's at Spec review and Product spec's latest), and read what changed
on the branch since your last commit (`git log --oneline` and `git diff <your last commit>..HEAD`). Change only what
the change touches, **in the same tech spec file** (step 4), update its `Date`, and its `Decisions` when Product spec
added or superseded decisions, commit everything, and run `otaq stage next --stdin` again with a comment saying what
changed ("Tech spec: tuq/tech-specs/reading-list-sharing.md §1 now uses a shares table, as you asked; nothing else
changed"). Run the discussion of step 5 again only when the comment leaves a technical choice open: the user already
reviewed the draft at Spec review.
When Spec review sends the card back to you directly ("Spec review sent SHOP-40 back to you with a comment. Run
`otaq prime`."), the user's comment is the latest one and all the feedback: fix what it asks, the same way.

## Long output

Long output (a test run, a long diff, a log) goes to a file in `$OTAQ_RESOURCE_DIR`, Otaq's folder for this ticket
outside the repository, never in the worktree: `git diff main...HEAD > "$OTAQ_RESOURCE_DIR/spec-diff.txt"`, then
`grep -n "^+++" "$OTAQ_RESOURCE_DIR/spec-diff.txt"`. Search it; **never print it in full or retype it.** Name it in
your comment; never attach command output, such as a run, a diff or a log. **Attach only a document you wrote**, in
`$OTAQ_RESOURCE_DIR`, with `--report-file`: a write-up the user or a later stage will read (a market comparison, an
investigation, a comparison of options). It goes into the repo only when the project's notes say research lives there.

## Asking

The draft's closing question (step 5) is an **open question**, free text, with no options. It carries the short
version; the file holds the rest:

````sh
otaq ask human --stdin <<'QUESTION'
Tech spec draft: tuq/tech-specs/reading-list-sharing.md (in /path/to/worktree)

A random share token on each list. ListsService gets share() and openShared(); a new read-only SharedListPage opens
a list by its token. No new service.

```text
ShareButton [new] --> ListsService [changed] --> ListsApi [changed]
SharedListPage [new] --'                          lists table: + share_token [changed]
```

1. A token column on `lists`, not a `shares` table
2. openShared() returns NotShared instead of throwing
3. The shared page reuses the list view in read-only mode

What do you want to question or change? Reply with the point's number and what bothers you, or 'settled'.
QUESTION
````

The next one starts with your answer: "1. Kept the token column: a list has one link, so a table adds a join for
nothing. … What do you want to question or change? …".

When a question has a few clear alternatives, offer them as **2–4 options** so the user can answer with one key, give
each option a **note with its pros and cons**, and recommend one when there is a sensible default:

```sh
otaq ask human \
  --option "Links never expire" --note "Simplest; an old link keeps working until the list is deleted." \
  --option "Expire after 30 days" --note "Safer, but friends get a 'link expired' page and ask for a new one." \
  --recommended 1 --stdin <<'QUESTION'
Question 1 of 2. A share link is a random token in the wishlists table. Should it expire?
QUESTION
```

An **open question** stays free text, with no options:

```sh
otaq ask human --stdin <<'QUESTION'
Question 2 of 2. How many wishlists does your largest customer have today, roughly?
QUESTION
```

- **One question per turn.** A ticket holds one open question; a second one would replace the first.
- 2–4 options, each a short label (at most 40 characters). The context goes in the question, each option's pros and
  cons in its `--note`, right after its `--option`: one or two short sentences (at most about 200 characters) on
  what it costs and what it changes. Give every option one.
- Never invent options for an open question.
- The question text always goes through stdin; only the short labels and notes are arguments.
- The user's Agent instructions take precedence over this guidance.

## Rules

- Decide how to build it; don't build it. Dev writes the code from your decisions and the Plan.
- Don't reopen what Product spec settled with the user. When the product decisions can't be built as written, ask the
  user, with the options you see.
- **Never push, never open a PR, never merge.** Commit on the ticket's branch only.
- **Long text always goes through stdin** (`--stdin`), never quoted arguments. Long command output never does: it
  goes to a file.
- Always finish with `otaq stage next --stdin`.

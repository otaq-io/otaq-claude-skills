# Tech spec · <feature>

- **Ticket:** SHOP-40
- **Date:** YYYY-MM-DD
- **Decisions:** 008, 009, 010

## How it is used

```ts
const link = await lists.share(listId); // ShareLink { token, url }
const list = await lists.openShared(token); // read-only ReadingList, or NotShared
```

## How it is built

A few short paragraphs: where the change goes in the application, the parts it adds or changes, the data it stores
and how, the APIs and their shapes, what it reuses. Rough: no step-by-step coding plan, no code.

## What changes

```text
ShareButton [new] --> ListsService [changed] --> ListsApi [changed]
SharedListPage [new] --'                          lists table: + share_token [changed]
```

| Part         | Where                      | New / changed | What it does                  |
| ------------ | -------------------------- | ------------- | ----------------------------- |
| ListsService | libs/lists/data-access/... | changed       | adds share() and openShared() |

## Architecture decisions

### 1. A share token column on `lists`

What was chosen and why. Considered: a separate `shares` table. Lost: ...

## Testing

How it is tested: which tests, at which level.

## Risks

Migrations, load, security, what could go wrong.

## Open product points

Only when there are any: the product question, and what the design assumes until it is settled.

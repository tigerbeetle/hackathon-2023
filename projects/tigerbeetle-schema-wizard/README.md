<img src="https://github.com/emschwartz/tigerbeetle-schema-wizard/assets/3262610/046153f4-4657-4109-89b0-cb990b790621" width=200 />

# TigerBeetle Schema Wizard

## Backstory

_Once in the whimsical world of DataOz, a place where semicolons frolicked and functions danced, there was a legendary accounting database known as TigerBeetle, the guardian of debits and credits. Like Dorothy in her quest for the Emerald City, our heroes—Alice the Analyst, Bob the Backend Dev, and Charlie the CPA—were on a quest to master this digital beast to balance their mystical ledgers. "If only we could speak 'TigerBeetlese'," sighed Alice, as they stared at a maze of numbers more perplexing than the riddles of the Sphinx._

_Bob, ever the optimist despite once trying to use a sandwich as a floppy disk, chimed in, "Fear not, for legend speaks of the TigerBeetle Schema Wizard, a being who can conjure a robot so smart, it would turn our business logic into TigerBeetle treats!" Off they went, down the winding paths of code, through forests of parentheses, and over mountains of syntax errors. They faced obstacles like the Wicked Witch of the Wrong Data Type and the Flying Monkeys of Misplaced Decimals. "Remember," Charlie said as they debugged yet another haunted function, "when we find the Schema Wizard, we must ask for client code that's as easy to use as a scarecrow's brain is to install—plug, play, and no hay required!"_

## Overview

When using TigerBeetle, you need to model your use case in terms of [ledgers](https://docs.tigerbeetle.com/reference/accounts#ledger), [codes](https://docs.tigerbeetle.com/reference/accounts#code), [accounts](https://docs.tigerbeetle.com/reference/accounts), and [transfers](https://docs.tigerbeetle.com/reference/transfers). That means developers need to first wrap their heads around double-entry bookkeeping in order to take advantage of the power of TigerBeetle.

This project aims to simplify the usage of TigerBeetle by allowing you to define the schema of your business logic in a simple TOML format. It then generates client code in any of the supported languages to make building systems on top of TigerBeetle easy and error-free.

By generating the client code from provided ledger types, we make it easier for developers to use TigerBeetle without thinking about questions like:

- What `ledger` numbers should we use for each currency?
- What's the difference between a `ledger` and a `code`?
- Is a user's balance equal to the debits minus credits or vice versa?
- How do we use linked transfers to enable cross-currency transfers across ledgers?

## Contents

- [Schema](./schema.toml)
- [Generated TypeScript client code\*](./src/generated.ts)
- [Example usage script](./src/index.ts)

\* Note: the client code is not currently being generated 😋

## Trying it out

1. [Run TigerBeetle on your local machine](https://docs.tigerbeetle.com/quick-start/single-binary)
2. Clone this repo
3. `npm install`
4. Run `npm run dev` to create two accounts, fund them, and send a transfer between them

## Challenges we ran into

The biggest one was actually wrapping my head around the double-entry bookkeeping model, which gave me more of an appreciation for what developers trying to use TigerBeetle will need to do. Aside from that, I ran into the following documentation and client library issues:

- https://github.com/tigerbeetle/docs/issues/36
- https://github.com/tigerbeetle/docs/issues/37
- https://github.com/tigerbeetle/tigerbeetle/issues/1284
- https://github.com/tigerbeetle/tigerbeetle/issues/1285
- https://github.com/tigerbeetle/tigerbeetle/issues/1287
- https://github.com/tigerbeetle/tigerbeetle/issues/1290

Oh, also, I didn't actually have enough time to start generating the client code from the schema 😋

## Accomplishments that we're proud of

TigerBeetle's model seems -- and is -- very simple. However, figuring out how to correctly model your application's business logic using double-entry bookkeeping is quite tricky, unless you have prior experience with it. Something along the lines of this project would probably help developers get started with standard use cases much more quickly.

## What's next for TigerBeetle Schema Wizard

1. Actually generate the TypeScript client code from the schema
2. Add more transfer types (including currency exchange)
3. Add more ledger types
4. Add support for other programming languages

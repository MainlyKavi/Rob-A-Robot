---
name: roblox-security
description: Security review for Rob a Robot server code. Use when writing or reviewing RemoteEvents/RemoteFunctions, currency or purchase logic, robot ownership, stealing or trading, or DataStore saving, and before merging any feature that touches money or items.
---

# Roblox security review (Rob a Robot)

Assume every client is an exploiter who can fire any remote with any arguments, at any rate, at any time, and can read every client script and replicated value.

## Review procedure

1. List every remote in the change (`grep -rn "OnServerEvent\|OnServerInvoke" src/Server`). For each handler, check all items below. Report each failure with file:line and a concrete exploit ("fire RequestBuyRobot with price = 0").
2. List every write to currency, robots or saved data. Each one must be reached only through a validated server path.

## Remote handler checklist

- [ ] Types checked: `typeof(arg) == "string"` etc. for **every** argument; reject NaN/inf (`x ~= x`, `math.abs(x) == math.huge`) and huge strings.
- [ ] No client-supplied price, amount, reward, rarity or "success" flag is used. The server looks prices up in `Shared/Config`.
- [ ] Ownership: the player owns the robot/plot they act on (server-side table, never a client value or instance name).
- [ ] Affordability is checked and the deduction happens in the same step with no yield between check and write.
- [ ] Rate limiting per player per remote (simple timestamp table is enough).
- [ ] Spatial actions (pick up, steal, collect) check distance from the server-side character position.
- [ ] RemoteFunctions: never invoke the **client** from the server (it can hang forever); server-side `OnServerInvoke` returns only data the player may see.

## Duplication and stealing

- A robot has exactly one owner id in server state. Moving it (buy, steal, trade) is one function that removes from the source and adds to the destination with no yield in between. Grep for any other code that adds robots.
- Steal flow: the server validates that the thief is near, the target robot is stealable (not protected, cooldown elapsed, victim online or the offline rule allows it), and that the thief has space. The client only *requests*.
- Trading: both sides lock, the server re-validates both inventories at confirm time, then swaps atomically. Cancel on either player leaving.
- On leave mid-steal/trade: the item stays with its original owner.

## Saved data

- Only the data module touches DataStoreService (rule 6 in `AGENTS.md`). Writes use `UpdateAsync`, there is a session lock so two servers can't load the same profile, and data saves on PlayerRemoving and BindToClose.
- Never save a value the client computed. Clamp loaded values (no negative cash, robot ids exist in config).
- Data has a `version` field; migrations are explicit.

## Other

- No `loadstring`, no `require(assetId)`, no HttpService calls to unknown hosts, no Toolbox models with scripts.
- No Robux purchase code without the user's approval. If present, `ProcessReceipt` must be idempotent and grant only after the save succeeds.

End the review with: blocking issues, non-blocking issues, and what you did not check.

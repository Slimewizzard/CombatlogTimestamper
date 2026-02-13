# CombatlogTimestamper

A lightweight Turtle WoW addon that places a clickable button on your screen to stamp markers directly into your `WoWCombatLog.txt` file. Useful for tagging important moments during raids or dungeons so you can find them later.

**Requires:** [SuperWoW](https://github.com/balakethelock/SuperWoW) (uses `CombatLogAdd` API)

## Usage

| Action | What it does |
|---|---|
| **Left-click** button | Stamps a `CTS_MARKER` entry into the combat log |
| **Right-click** button | Opens the config panel |
| **Drag** button | Move it anywhere on screen |

<img width="683" height="417" alt="bilde" src="https://github.com/user-attachments/assets/2af52ae4-6714-44bf-851a-6893230eed95" />

In the combatlog ( remmeber it writes in batches so it might take a moment for it to show up) 

<img width="723" height="103" alt="bilde" src="https://github.com/user-attachments/assets/c4f14172-7c21-4843-9c36-d79e8dcd2355" />

## Slash Commands

| Command | Description |
|---|---|
| `/cts` | Toggle config panel |
| `/cts show` | Show button |
| `/cts hide` | Hide button |
| `/cts size <16-200>` | Resize button |
| `/cts msg <text>` | Set custom stamp message |
| `/cts stamp` | Stamp without clicking |
| `/cts reset` | Reset stamp counter |
| `/cts help` | List all commands |

## Config Panel

Open with right-click or `/cts`:

- **Show Button** checkbox
- **Size slider** (16–200px)
- **Stamp Message** text field + Save button
- **Reset Counter** button

## Combat Log Output

Each click writes a line like this to `WoWCombatLog.txt`:

```
2/13 00:31:03.001  CTS_MARKER: [#1] === TIMESTAMP MARKER ===
```

Make sure combat logging is enabled (`/combatlog`).

## Flushing to Disk

WoW writes combat log data in **batches** — it buffers entries in memory and flushes them to `WoWCombatLog.txt` on its own schedule. This means your marker might not appear in the file immediately after clicking.

The addon attempts to force a flush by toggling combat logging off and back on (`LoggingCombat(0)` → `LoggingCombat(1)`) after each stamp. This usually works, but WoW ultimately decides when data hits the disk.

If your marker isn't showing up in the file yet:
- **Wait a moment** — WoW may flush on its own after a few seconds
- **`/reload`** — forces a UI reload which flushes the buffer
- **Log out** — guaranteed flush on character logout or `/quit`

The marker **is** being written — it just may take a moment to appear in the file.

## Settings

All settings (position, size, visibility, message) are saved per-character.

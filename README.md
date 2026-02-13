# CombatlogTimestamper

A lightweight Turtle WoW addon that places a clickable button on your screen to stamp markers directly into your `WoWCombatLog.txt` file. Useful for tagging important moments during raids or dungeons so you can find them later.

**Requires:** [SuperWoW](https://github.com/balakethelock/SuperWoW) (uses `CombatLogAdd` API)

## Usage

| Action | What it does |
|---|---|
| **Left-click** button | Stamps a `CTS_MARKER` entry into the combat log |
| **Right-click** button | Opens the config panel |
| **Drag** button | Move it anywhere on screen |

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

## Settings

All settings (position, size, visibility, message) are saved per-character.

# CARDBALL

A 4-player card-battler where each duel resolves as a 1v1 Head-Soccer-style match.
Built in Godot 4 (GDScript). Solo project.

## Status
Phase 5 - Networking - connect card game layer using Steamworks lobbies and P2PŽ

## Build order
1. Offline soccer minigame (core feel)
2. 3–4 abilities + ability bar, offline
3. Card game layer, offline / hotseat
4. Wire card game <-> 1v1 handoff, offline
5. Networking: card game layer (Steamworks lobbies + P2P)
6. Networking: real-time 1v1
7. Remaining abilities
8. Meta systems: coaches, cards, referee, standings
9. Polish: art, shaders, stadiums, sound

## Folder layout
- `scenes/` - Godot scenes (.tscn), grouped by feature
- `scripts/logic/` - pure game-state functions (no rendering / networking / randomness)
- `scripts/` - node scripts that drive scenes
- `assets/` - sprites, audio, shaders
- `addons/`- plugins (e.g. GodotSteam, added later)

## Conventions
- Keep game logic (state in - new state out) separate from rendering and networking.
- `snake_case` for files and variables, `PascalCase` for nodes and classes.

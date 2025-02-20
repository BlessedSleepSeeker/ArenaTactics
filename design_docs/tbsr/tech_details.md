# TBSR : Technical Details

- [TBSR : Technical Details](#tbsr--technical-details)
	- [Both](#both)
	- [Server](#server)
	- [Client](#client)

This document aims to design the technical side of the TSBR.

## Both

- GameplayServer -> Main server getting turn data and sending resolution data to clients
  - Input : ActionSequence for entities.
  - Hold the game state.
  - Has 3 modes : server, client and replay.
    - Server : Receives the actions and resolve them.
    - Client : used to simulate your turn and preview actions sequence results.
      - > might be hard !!
  - Potential issues : how do I deal with the player hosting the game ? Does he have 2 ? How do I make sure he doesn't cheat ?

- [ ] GameplaySettings ressource
  - main seeds
  - player_id
    - class, skins
  - other settings

- `var game_turns: Array[Array]` all the `turn_data` made. `game_turns[0]` is the first turn played.

- `var turn: Array[ActionSequence]`
  - All the actions made by every player in a single turn

- [x] ActionSequence ressource
  - serialized from and to dict
  - Hold a player unique turn

- [x] PlayedAction ressource
  - Hold a player unique action

- ReplayWriter
  - Can be hooked to gameplay server to store all the game data and action to a file.

- ReplayReader
  - Feed the input to the server.

## Server

- OnlineServer
  - Hold Identity
  - Deals with sending data to the right nodes

- ChatModule
- SpectatingMode

## Client

- TurnManager + UI
  - Manage the creation of your turn and of an actionsequence ressource
  - Use ActionGridUI

- OnlineClient
  - Hold Identity

- ChatModule + UI
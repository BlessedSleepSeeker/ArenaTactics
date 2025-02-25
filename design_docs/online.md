# Online Implementation

- [Online Implementation](#online-implementation)
	- [Architecture](#architecture)
	- [Game Scenario](#game-scenario)
		- [I want to host a game](#i-want-to-host-a-game)

## Architecture

- Client and Server are the same project
  - Easier to manage long term
  - Use of `if multiplayer.is_server():` to branch out functionality.

## Game Scenario

1. Download the game

### I want to host a game

1. Launch the server in headless "host game mode".
   1. This will open a terminal running the server.
2. Forward your ports if needed.
3. Launch your player's clients and connect to the server.
4. The first connected player is admin and can tweak settings/launch the game.
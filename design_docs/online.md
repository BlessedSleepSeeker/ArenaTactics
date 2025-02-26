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

1. Launch the game with `-- --server` args.
2. Set your server setting then click on "run server"
   1. If headless : this will open a terminal running the server.
   2. If not, this will continue executing the server.
3. Forward your ports if needed.
4. Launch your player's clients and connect to the server.
5. The first connected player is admin and can tweak settings/launch the game.
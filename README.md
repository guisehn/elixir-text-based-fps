# elixir-text-based-fps

Online multiplayer text-based FPS game using Elixir + Phoenix. The game is live at [elixir-text-based-fps.herokuapp.com](https://elixir-text-based-fps.herokuapp.com/)

![Screenshot of the game](misc/screenshot.png)

[Original game](http://eigen.pri.ee/shooter/) and map made by [Eigen Lenk](http://eigen.pri.ee/).

You can also see a node.js version of this game I made a few years ago at https://github.com/guisehn/text-based-fps

## How to run locally

### Running the web server

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Running in your terminal

It can also be played in the terminal.

  * Install dependencies with `mix deps.get`
  * Run `mix cli.server` to start the server
  * Run `mix cli.client` in another Terminal session to join the server. You can open multiple sessions for multiple players.

## How to deploy

Click on the button below to deploy to Heroku:

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/guisehn/elixir-text-based-fps)

## Editing the map

The game map is interpreted from the plain text file `priv/map.txt` where:

- `#` represent the walls
- `N`, `S`, `W`, `E` represent the respawn positions where the letters mean the player initial direction (north, south, west or east)

The engine automatically ignores empty lines at the start and end of the map, and also empty spaces after the last wall of the line. You can add a `.` character to circumvent that if you really mean to have those empty spaces.

## How the game works

The entire game is a giant `%TextBasedFPS.ServerState` struct. The `IO.inspect` dump below is for a server with two players `John` and `Jane`, and one room `spaceship`.

The server state is stored in an [Agent](https://hexdocs.pm/elixir/1.12/Agent.html) at [/lib/text_based_fps/server_agent.ex](/lib/text_based_fps/server_agent.ex).

The `%TextBasedFPS.ServerState` struct has the following members:

  * `players` is a map containing all players of the server of all rooms. The keys are UUIDs that uniquely identify those players in the server. Each player is a `%TextBasedFPS.Player` struct.

  * `rooms` is a map containing all rooms of the game, and each room is a `%TextBasedFPS.Room` struct. Inside this struct, you'll find the keys: 
  
    * `name`: the name of the room

    * `players`: each player is a `%TextBasedFPS.RoomPlayer` with the room session specific information such as coordinates, direction, ammo, kills and killed, etc.

    * `game_map`: contains a matrix with the current state of the map (including players and objects such as ammo and health packs), and a list of respawn positions

  * `notifications` is a list of notifications that are pending to be delivered to someone. When a player joins a room, leaves a room, or changes their name, notification structs are generated for each user on that room.

```elixir
%TextBasedFPS.ServerState{
  players: %{
    "d5556609-0b58-47cd-ae08-7db873fa5ac5" => %TextBasedFPS.Player{
      key: "d5556609-0b58-47cd-ae08-7db873fa5ac5",
      last_command_at: ~U[2021-06-05 23:09:37.075344Z],
      name: "Jane",
      room: "spaceship"
    },
    "e01f611e-4a61-4127-ba7b-4ba85ee73e3e" => %TextBasedFPS.Player{
      key: "e01f611e-4a61-4127-ba7b-4ba85ee73e3e",
      last_command_at: ~U[2021-06-05 23:09:37.072602Z],
      name: "John",
      room: "spaceship"
    }
  },
  rooms: %{
    "spaceship" => %TextBasedFPS.Room{
      name: "spaceship",
      players: %{
        "d5556609-0b58-47cd-ae08-7db873fa5ac5" => %TextBasedFPS.RoomPlayer{
          ammo: {8, 24},
          coordinates: {8, 5},
          direction: :south,
          health: 100,
          killed: 0,
          kills: 0,
          player_key: "d5556609-0b58-47cd-ae08-7db873fa5ac5"
        },
        "e01f611e-4a61-4127-ba7b-4ba85ee73e3e" => %TextBasedFPS.RoomPlayer{
          ammo: {8, 24},
          coordinates: {5, 1},
          direction: :south,
          health: 100,
          killed: 0,
          kills: 0,
          player_key: "e01f611e-4a61-4127-ba7b-4ba85ee73e3e"
        }
      },
      game_map: %TextBasedFPS.GameMap{
        matrix: [
          [:"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#"],
          [
            :"#",
            :" ",
            :" ",
            :" ",
            :"#",
            %TextBasedFPS.GameMap.Objects.Player{
              player_key: "e01f611e-4a61-4127-ba7b-4ba85ee73e3e"
            },
            :" ",
            :" ",
            :" ",
            :"#"
          ],
          [:"#", :" ", :"#", :" ", :" ", :" ", :"#", :"#", :" ", :"#"],
          [:"#", :" ", :"#", :" ", :"#", :" ", :" ", :" ", :" ", :"#"],
          [:"#", :" ", :" ", :" ", :"#", :"#", :" ", :"#", :"#", :"#"],
          [
            :"#",
            :"#",
            :" ",
            :" ",
            :" ",
            :" ",
            :" ",
            :" ",
            %TextBasedFPS.GameMap.Objects.Player{
              player_key: "d5556609-0b58-47cd-ae08-7db873fa5ac5"
            },
            :"#"
          ],
          [:"#", :" ", :" ", :"#", :" ", :"#", :"#", :"#", :" ", :"#"],
          [:"#", :" ", :"#", :"#", :" ", :" ", :" ", :"#", :" ", :"#"],
          [:"#", :" ", :" ", :" ", :" ", :"#", :" ", :" ", :" ", :"#"],
          [:"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#"]
        ],
        respawn_positions: [
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {1, 1},
            direction: :east
          },
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {5, 1},
            direction: :south
          },
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {8, 3},
            direction: :north
          },
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {3, 4},
            direction: :west
          },
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {8, 5},
            direction: :south
          },
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {6, 7},
            direction: :west
          },
          %TextBasedFPS.GameMap.RespawnPosition{
            coordinates: {1, 8},
            direction: :north
          }
        ]
      }
    }
  },
  notifications: [
    %TextBasedFPS.Notification{
      body: "Jane joined the room!",
      created_at: ~U[2021-06-05 23:09:37.075358Z],
      player_key: "e01f611e-4a61-4127-ba7b-4ba85ee73e3e"
    }
  ]
}
```

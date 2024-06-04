# ArenaTactics

A fusion between Dofus Arena and Your Only Move Is (YOMI) Hustle, with a few MOBA features like Fog of War. Also understandable as Hunger Games but one on one.

You'll fight an opponent in a restricted arena, filled with opportunity for ambushs, traps or duel to the death. You are hunter and hunted at the same time. Every action is a commitment that could lead to your success or your death. All knowledge is ultimately based on that which we cannot know. Will you fight ? Or will you perish like a dog ?

- [ArenaTactics](#arenatactics)
  - [Main Features](#main-features)
  - [Appearance](#appearance)
  - [Main Feature Technical Design](#main-feature-technical-design)

## Main Features

- Turn-Based with Simultaneous Resolution : every player pick an action or action sequence with an amount of point alloted and both action are resolved simulatenously, leading to no player waiting too much for their opponents to play and always giving players control.
- Full freedom of movement & actions : no grid and targeting system (even if it were easier to code and handle)
  - Think Transistor planning system but all the time.
- Ever-Evolving Arena
  - The arena is proceduraly generated at the start of every match.
  - With time, the arena will start to erode : bushes dies, trees leaves fall, water stop.
    - This makes it so hiding is more difficult with time goes on.
- Fog of War
  - With the ever changing map, you'll have to discover the layout every time.
    - This is to create tension and stress.
  - If you do not have "line of sight", your camera will not let you see what is happening here (imagine if your opponent is hiding behind a tree, you won't see any action he takes. You could hear him though)
  - Traces : every action your character perform will affect the environnement, allowing your opponent to know you were here and perhaps deduct where you are going.
- Sound Design
  - Probably the most important feature ?
  - Everything makes sound : you'll make noise yourself, potentially revealing yourselves.
  - Luckily, the fauna is also here. And water running in the nearby river could help you making less noise.
- Class System for different gameplay
  - Annoying dude pulling you into traps and shoot arrow
  - Annoying dude running at you very fast
  - Annoying dude who can do everything ok
  - Annoying magic dude breaking the rules

## Appearance

- 3D Low Poly. Doable, not too costly in time.

## Main Feature Technical Design

The game will be developped using Godot.

- Online Multiplayer
  - Must research more (YOMI)
  - Client and Server architecture -> MUST RESEARCH MORE BEFORE WRITING ANY CODE

- TBSR
  - Main idea is to pause processing of nodes and manually count frames.
  - Must research more (YOMI)

- Full freedom of movement
  - Must research Pathinding in 3D

- Arena Generation
  - ServerSide
  - Multipass Generation (minecraft like)
  - Wave Function Collapse for defining rules
  - Research More

- Fog of War + Hiding
  - Handled ServerSide
  - Research More

- Sound Design and visual subtitles
  - Client Side visual options
  - Signals + UI

- Class & Spell system
  - Data Driven as much as possible
    - Factory pattern ?
  - Will make balancing and iterating faster
  - Will make modding possible
  - Research More
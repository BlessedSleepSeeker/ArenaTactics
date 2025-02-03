# Turn-Based with Simultaneous Resolution

[Back to the main design doc](../main.md)

- [Turn-Based with Simultaneous Resolution](#turn-based-with-simultaneous-resolution)
  - [Concept](#concept)
  - [Design Interrogations](#design-interrogations)
    - [Simultaneous Resolution](#simultaneous-resolution)
    - [Amount of Action per Turn](#amount-of-action-per-turn)
      - [One Action Per Turn](#one-action-per-turn)
        - [Pros](#pros)
        - [Cons](#cons)
      - [Action Sequence](#action-sequence)
        - [Pros](#pros-1)
        - [Cons](#cons-1)
      - [Resources](#resources)
      - [What Moving Costs](#what-moving-costs)
      - [Reactions](#reactions)
        - [Generic Permanent Reactions](#generic-permanent-reactions)
      - [Timed Reaction](#timed-reaction)
  - [My Path](#my-path)
    - [Homework](#homework)

## Concept

In a traditional TBSR gameplay, each player pick an action, the action is resolved then player get to pick again.

## Design Interrogations

### Simultaneous Resolution

The TBSR has one glaring issue. How can you hit your opponent if they could walk out of the range every time ?
> i do not have an answer right now.

Random ideas to explore :

- Defensive actions always resolve first, then Offensive, then Movement ?
- RPS : Move lose against Attack which soft-lose against Protect (Platfighter RPS) ?
  - Interesting especially with Action sequence which would make you play it once or twice.

- With a "follow movement" action which would make the player move to keep the same distance as their target ?

### Amount of Action per Turn

Are we playing with **One Action Per Turn** or can the player be able to script an **Action Sequence** ?  
Let's examine the pros and cons of each strategies.

#### One Action Per Turn

The Player will pick one action, this action will play out, then another turn start.

##### Pros

1. Higher reactivity in tense moments.
   1. With only one action per turn, you can instantly react to the new situation and change your plan accordingly.
2. Easy to understand for players. Select an action, action get played out.
3. Easier to create compared to Action Sequence.
   1. The code and UI is simpler to develop.

##### Cons

1. Makes move balancing harder.
   1. All you have for balancing is giving action more constraints.
2. Makes all action feel the same.
   1. If all action have the same Cost (one turn), then big, powerful actions "feel" the same than "move 2".
   2. This can be solved to a degree by giving an additional cost to moves. Cooldown, Penalty, Revealing you...
3. The player with [Initiative](../glossary.md#initiative) is weaker as the opponent can react faster.

#### Action Sequence

The Player will pick multiples actions in sequence, which then get played in sequence, and when everything has been played, another turn start.

This has a consequence of actions having a fixed cost to be used, like Action Point from Dofus or the Action/Bonus Action duo from DnD.

##### Pros

- Action Costs allow greater flexibility in Move Creation.
- Reward more deep reads on your opponent choice in tense moment.
- Do more in a turn, which help in early game.

##### Cons

- Harder to code.
- Harder to use for players.
- Harder to predict opponent decisions since they do more per turn.
- More questions arise.
  - What's the Sequence Max Lenght if it has one ?
  - What's the resource used ? How does it work ?
  - How do the sequence resolve ?
  - Does every action take the same time ?
    - Yes.

#### Resources

The question of resources quickly arise.

In YOMI Hustle, which use one action per "turn", the cost of actions is the amount of frame where you can't do anything. While this solution is elegant for a TBSR Fighting Game, I do not think it would match well here. Moving here is a commit, it will lock you out of doing anything else for a time.

In DnD, you have one Action and one Bonus Action, with movement costing Movement Points. My experience with this system (BG3) was interesting. You have a lot of spatial freedom : moving doesn't lock you out of doing anything else, but the opportunity attack system doesn't allow you to freely roam a battlefield. The value of one Action is so high that missing an attack feels really bad as you could end up your turn by having done nothing. Inversely, class that can attack twice like Barbarian or Warrior feels amazing when you hit both and deal 60 in a turn. This system is balanced around the randomness of dice rolls and while it fits for DnD, I don't want it in my game. The randomness leads to High Highs and Low Lows, and I want mine to come from your plan working to perfection or being seen through and countered by your opponent. (I like the idea of Crits though, just not FailCrit).

In Dofus, you have Action Points and Movement Points, which each spell costing various amount of points. I really like this system, has it opens a lot of creativity for the player. Your player has a fixed amount of point at the start of a turn, and he can spend it how he wants to, creating interesting choices. Moving doesn't cost a lot here (worse lie of my life, since position is so important in Dofus), but the map layout, Line of Sight and Tacle mechanics will restrict you (your own allies restrict your line of sight). This entire system also allows more control over balancing since you can tweak action cost or the amount of AP your player has.

#### What Moving Costs

> One Thing to remember : we're playing on an HexGrid.

In our previous exemple, we've seen that moving should have a cost. In YH, it's frames, in DnD, it's exposing yourself to Opportunity Attacks, and with Dofus RectGrid and Map Design, the Line Of Sight and positionment is so important that MP might arguably be more important than AP.

What this little analysis has shown me is that the environnement dictate the kit of the character and how they move.

#### Reactions

I really like the Reaction System from DnD and the Instants from Magic. This help solving the Not-Having-Option-When-It's-Not-Your-Turn-Curse from Pure Turn-Based games.

I would want to experiment with a reaction system for certain situations.

How reactions works :

- Something predetermined happens.
  - Example : You are taking damage !
- You **can** react if you nail the minigame (requires an action, so if you do not want to you can simply miss it on purpose).
  - Example : Turn to the damage direction to see from where it came if you manage to do UP DOWN UP LEFT in 3 seconds.
- Perhaps you will see a 120cm gobelin backstabbing you.
- Perhaps you will see nothing as your opponent has fled already.

on{SomethingHappening}Do{Reaction}.

> Building your own reaction idea ???
This pauses the turn execution and might change the outcome of the remaining actions.

##### Generic Permanent Reactions

- onDamageTakenDoTurn
- onNoiseHeardDoTurn

#### Timed Reaction

- OnHitDoParry
  - The Anti-Attack reaction : you bet that your opponent will hit you with something and prepare to parry it.
  - Last One Turn
- OnProjectileDoDodge
  - The Anti-Projectile reaction : you bet that your opponent will send a projectile on you and prepare to dodge it.
  - Last One Turn

## My Path

I'm going with **Action Sequence** with an **AP System** with added **Reactions** and **Movement** costing AP.  
Players choose the order of their actions and can do as much as they want if they have points.  

### Homework

- [ ] Design the technical side of Action Sequence.
- [ ] Design the Action Sequence UI
  - [ ] Look at Transistor "Time Stop" UI.

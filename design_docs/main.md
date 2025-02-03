# Arena Tactics Design Doc

- [Arena Tactics Design Doc](#arena-tactics-design-doc)
  - [General](#general)
    - [Game Pillars](#game-pillars)
    - [Consequences](#consequences)
      - [Going Turn-Based](#going-turn-based)
      - [Building a replayable World](#building-a-replayable-world)
      - [Players Avatars](#players-avatars)

## General

### Game Pillars

1. The game Fantasy is about feeling like a master-planner and master-tracker.
   1. All about making a plan and seeing it succeed.
2. The game Concept is Opposition Multiplayer.
   1. You are the Hunter and the Hunted at the same time.
3. The game should reward **Game Knowledge**, **Adaptability/Creativity**, **Quick-ish Decision Making**, **Mid/Long Term Planning** and **Understanding of your opponent goals and methods**.
    > Similar goals to Hearthstone, Minecraft HUC, or Bullet Chess.
4. The game focus isn't on **TechSkill**.
   1. Remember the Fantasy !
   2. Technical ability should be used very sparringly (See [Reactions](deadlink)).
    > Not a classic Fighting Game
5. Trying to simply avoid your opponent permanently should be detered.

### Consequences

#### Going Turn-Based

The game rewards alone could match a lot with Battle Royale genre, like Apex Legend. Avoiding the TechSkill makes more sense if our fantasy is to give our players the feeling of being a master-planner, as it would distract from planning/makes it harder to grasp.

My first reaction was to go Turn-By-Turn. Turn-by-Turn allow "Time-Freeze" and enough thinking time to properly assess a situation and react almost perfectly to it. This was a step in the right direction but I didn't like 2 things about it. Firstly, watching your opponent play without having options isn't really fun (Magic Combo Deck). Secondly, I wanted to still have thoses "spagettis" moments from high, tense, situations, and True Turn-By-Turn (and a high time limit per turn) didn't really allow it as your opponent would see you doing something incredibily stupid and just punish you for it since he didn't have any action to take.

In light of theses issues, and having played Y.O.M.I Hustle recently, I really like [Turn Based with Simultaneous Resolution](tbsr\tbsr.md) (TBSR from now on) with a short time limit per turn.

#### Building a replayable World

In thinking about which World I wanted to create, the first two Skills (Game Knowledge and Adaptability/Creativity) were really important. Since I want to create a game where interacting with the environnement is the primary action, I didn't want my players to spend 3 months mapping each location of a unique repeating map for setting up traps. Having a perfect Game Knowledge is cool, but raise the barrier to entry too much for my liking and leaves less places for Adaptating on the fly. Making more static maps would simply push the barrier higher while doing nothing for solving this issue.  
To balance Game Knowledge and Adaptability/Creativity, I took inspiration from Immersive Sims and Minecraft. Every game of ArenaTactics should be like a playthrough of Procedurally Generated Dishonored. "Wait, can I do that ? Damn I can LOL !" -> proceed to shove a boulder on your opponent face. Using [Procedural Generation](arena_gen\arena_gen.md) allows replayability, enhance adaptability/creativity and make Game Knowledge less of a barrier of entry. You will still lose to peoples knowing every possibles interactions, but you could still take them by surprise at some point.

#### Players Avatars

The [Character Design](characters\characters.md) isn't really thoughful, I think about my characters as Fantasy, like "I wanna play the discreet dude who backstab you 3 times then disapear in the shadows" (rushdown), "I want to be the magic dude who will teleport the boulder on your previously burned face" (law-breaking) or "I am the muscular dude who's easy to track but hard to kill and I better not see you" (grappler).  
I go for simple, recognizable archetype because my skillset limit my ambition here (and makes everything easier for you and for me and the entire playerbase).

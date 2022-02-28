# Dragon Quest Heroes: Rocket Slime reverse engineering project

This is the main repository for my reverse engineering project of Dragon Quest Heroes: Rocket Slime in Love2D. It's in very early stages but contains an almost fully complete character controller of Rocket and a basic Platypunk NPC.

Alot of the code for this is ugly since this project was started 1-2 years ago before I had a good understanding of software architecture, etc. Cleaning up will be done every now and then and probably an entire partial rewrite to adopt an actual comprehensible architecture

I'd also like to state that this is mostly a 'high level' reverse engineering and what I mean by that is that I'm just programming something that looks and acts similar to the original DS game, rather than a 1:1 copy. This is mostly because I do not have the necessary knowledge to analyze the game's assembly code to get a better understanding

If, for some insane reason, you want to work on this with me, you can DM me on discord (Garf#6969). I cannot provide any form of payment so it'll be purely something you'll have to do in your own time. Main thing I would like to do is rip more tilesets from the game so if you want to help and can do that it'd be great.

# Disclaimer
Contains ripped assets from the game. None of the graphics were drawn by me and all credit go to the original artists. Most (like Rocket and the Playpunk's sprites) are stuff that already exist online. The tileset that can be found in Resources/graphics/Tilemaps/CannonRoom was directly ripped from the ROM by me and manually recolored and thus may have slight inaccuracies in color.


To run, you can drag the root folder onto Love.exe.
If you are unable to run, make sure the imgui dll (inside Resources) is in your Love install directory
If you still get errors, make an issue with a screenshot of the error.

# Info about the project

### Sprites atlases
Sprites are loaded individually and then made into a texture atlas via the Runtime Texture Atlas library for Love2D. The individually loaded are discarded after this. It may be better to write a parser for the metadata created by Shoebox (the program I use to extract sprites from sprite sheets)

### Tile maps
Currently, I've ripped most of one tileset from the game which is the player tank's cannon room. It's ripped straight from the ROM and there's still plenty of issues with some tiles having wrong colors (it's a pain in the ass to get the correct palette. I just get close enough and manually color the wrong parts). If anyone wants to help with that, that'd be great.

### Code naming convention
I'm trying to keep code to this_style_of_naming mostly due to personal preference. External libraries made by other people will obvious follow their own naming convention and I won't spend time changing that since it's pretty pointless.

### End goal
The end goal this project is to have a (maybe) indistinguishable copy of Dragon Quest Heroes: Rocket Slime in terms of an engine. Ideally, I would want to make a demo of the tank battle system from the game to show of the capabilities of the engine but that's pretty far off.

### Main to-dos

* ~~Pathfinding~~ (while not implemented currently, there's a system in place for generating points that can be used for pathfinding via jumper)
* Better NPC AI (ability to pick up and throw ammo, attack player, etc.)

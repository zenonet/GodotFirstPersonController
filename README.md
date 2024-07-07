# Godot Stealth Game

Why is the Repo called "GodotFirstPersonController"? Well, I originally wanted to just write a simple FirstPersonController for Godot to learn Godot but when I noticed how easy that was, I decided to continue the project into some kind of FirstPerson shooter/stealth game.
The game still only features one level but I learned a lot about Godot while creating the games mechanics.

## How to play

Here's a full keymap:

| Input            | Action                                       |
|------------------|----------------------------------------------|
| ESC              | Immediately close the game                   |
| WASD             | Movement                                     |
| Mouse movement   | Looking around                               |
| C                | Throw a coin                                 |
| Left click       | Shoot                                        |
| Right click      | Aim                                          |
| Left CTRL (hold) | Crouch                                       |
| Q (hold)         | Silent takedown when standing behind a guard |

## Goal

In the building, there's a red briefcase you need to find and extract. The way you want to achieve this is your decision.

## Implemented systems

The game features enemy vision (seeing the player) and a sound system that allows enemies to investigate noises like thrown coins, footsteps, gunshots and other enemies yelling.

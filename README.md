# Circuit Skies

## Overview

Circuit Skies is a 2D platformer game developed using the Godot Engine. Players navigate challenging levels, overcome obstacles, and defeat enemies in a vibrant pixel-art world.

## Gameplay Design

The core gameplay revolves around classic platforming mechanics with modern additions:

*   **Movement:** Standard running and jumping.
*   **Dashing:** A boost-consuming dash ability for quick maneuvers and potentially crossing gaps or dodging.
*   **Combat:** The player can take damage from enemies and hazards, featuring knockback and temporary invincibility.
*   **Progression:** The game is structured into multiple acts (levels), loaded sequentially. Players aim to reach the exit point of each act.
*   **Scoring & Ranking:** The game likely includes a scoring system and potentially ranks the player's performance upon completing an act (based on `_on_exit_reached` parameters).
*   **Resource Management:** Players manage Health (HP) and Boost energy, both of which regenerate over time.

## Technology

*   **Game Engine:** [Godot Engine](https://godotengine.org/) (v4.x inferred from script syntax)
*   **Scripting:** GDScript
*   **Assets:** Pixel art sprites and tilesets.

## Alibaba Cloud Integration



## How to Run

1.  Ensure you have Godot Engine (version 4.x or compatible) installed.
2.  Clone or download this repository.
3.  Open the Godot Engine project manager.
4.  Click "Import" and navigate to the project's root directory containing the `project.godot` file.
5.  Select the project and click "Edit".
6.  Run the main scene (likely `Scenes/game.tscn` or a dedicated main menu scene) using the "Play" button (F5).

## Project Structure

*   `Assets/`: Contains all visual and audio assets (sprites, tilesets, sounds, music, fonts).
*   `Scenes/`: Contains Godot scene files (`.tscn`), including the main game structure, levels (acts), player, enemies, and UI elements.
*   `Scripts/`: Contains all GDScript files (`.gd`) defining the logic for game objects and systems.
*   `project.godot`: The main Godot project configuration file.
*   `default_bus_layout.tres`: Godot audio bus layout.
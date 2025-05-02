# Circuit Skies - A Fast-Paced Robot Platformer

## Overview

Circuit Skies is a 2D platformer game built with the Godot Engine. Inspired by the fast-paced precision gameplay of games like BZZZT, Circuit Skies puts you in control of a nimble robot navigating challenging levels filled with hazards and enemies.

![Robot Attack Animation](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kawfzghuu3vfxyaci7tx.gif)

## Demo

*   **Play the game here:** [https://circuit-skies.mhlinks.tech/](https://circuit-skies.mhlinks.tech/)
*   **GitHub Repository:** [https://github.com/prime399/circuit-skies](https://github.com/prime399/circuit-skies)

*   **Screenshots:**
    <div align="center">
      <table>
        <tr>
          <td><img src="https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4vhnr5voevksjr1om1kc.png" alt="Screenshot 1: Title Screen & Gameplay" width="280px"/></td>
          <td><img src="https://dev-to-uploads.s3.amazonaws.com/uploads/articles/p7wgnepapfvv8py8uajw.png" alt="Screenshot 2: Gameplay Action" width="280px"/></td>
          <td><img src="https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hsffj289qhzjpirzdg03.png" alt="Screenshot 3: Challenging Section/Enemy" width="280px"/></td>
        </tr>
      </table>
    </div>

## Gameplay Features

The core gameplay revolves around classic platforming mechanics with modern additions:

*   🏃‍♂️ **Classic platforming actions:** Run and jump through challenging levels filled with hazards.
*   💨 **Dash mechanic:** Press **"D"** + **<- or ->** button to dash for quick bursts of speed—perfect for dodging obstacles and enemies. Dashing consumes a regenerating boost meter.
*   🪙 **Collect coins:** Gather coins scattered throughout levels to achieve a high score for the leaderboard.
*   👾 **Avoid hazards and enemies:** Watch out for dangerous traps and enemies like green and purple slimes. The player can take damage, featuring knockback and temporary invincibility.
*   🚪 **Reach the exit:** Your goal is to make it to the exit point of each level. The game is structured into multiple acts (levels), loaded sequentially.
*   ❤️ **Health & Boost Management:** Players manage Health (HP) and Boost energy, both of which regenerate over time.
*   🏆 **Online leaderboard:** Compete for the best scores and see how you rank against other players!

## Technology

*   **Game Engine:** [Godot Engine](https://godotengine.org/) (v4.4)
*   **Scripting:** GDScript
*   **Assets:** Asprite
*   **Backend API:** FastAPI (Python)
*   **Web Server / Reverse Proxy:** Nginx

## Alibaba Cloud Integration ☁️

Circuit Skies leverages these powerful Alibaba Cloud services for its online features:

### 🖥️ **Elastic Compute Service (ECS)**
*   **Purpose:** Hosts the game's web build (Godot HTML5 export) and the backend API.
*   **Implementation:** An Nginx web server serves the static game files and acts as a reverse proxy for the FastAPI application running on the same ECS instance.

### 💾 **ApsaraDB RDS for MariaDB**
*   **Purpose:** Stores and manages the online leaderboard data.
*   **Implementation:** The FastAPI backend connects to the managed MariaDB instance to submit and retrieve scores.

### 🌐 **API Gateway**
*   **Purpose:** Manages, secures, and routes all leaderboard API requests.
*   **Implementation:** Provides a secure endpoint that routes requests to the FastAPI application running on the ECS instance.

## How to Run Locally

1.  Ensure you have Godot Engine (version 4.4 or compatible) installed.
2.  Clone or download this repository.
3.  Open the Godot Engine project manager.
4.  Click "Import" and navigate to the project's root directory containing the `project.godot` file.
5.  Select the project and click "Edit".
6.  Run the main scene (likely `Scenes/game.tscn` or a dedicated main menu scene) using the "Play" button (F5).
    *(Note: Online leaderboard features require the backend infrastructure to be running).*

## Project Structure

*   `Assets/`: Contains all visual and audio assets (sprites, tilesets, sounds, music, fonts).
*   `Scenes/`: Contains Godot scene files (`.tscn`), including the main game structure, levels (acts), player, enemies, and UI elements.
*   `Scripts/`: Contains all GDScript files (`.gd`) defining the logic for game objects and systems.
*   `project.godot`: The main Godot project configuration file.
*   `default_bus_layout.tres`: Godot audio bus layout.
*   `README.md`: This file.
*   `post.md`: Original DEV.to submission post.

## Credits 🙏

*   **Robot Sprite Pack:** [https://au-pixel.itch.io/robotbasepack](https://au-pixel.itch.io/robotbasepack)
*   **Sound Effects:** Various artists on [https://itch.io/](https://itch.io/)
*   **Soundtrack:** Various artists on [https://freesound.org/](https://freesound.org/)
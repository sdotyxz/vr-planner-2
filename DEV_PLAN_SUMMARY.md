# VR Planner 2 - Development Plan Summary

## 1. Project Overview
**Title**: VR Planner 2 (MVP)
**Type**: On-Rails Shooter / Arcade
**Engine**: Godot 4.x
**Core Concept**: "Feature: DENIED" - Shoot down scope creep (Enemies) while protecting assets (Hostages) on a high-speed rail system.

## 2. Recent Adjustments
Based on the latest requirements, the following changes have been applied to the MVP scope:
- **No Reload**: Removed "Reload (R)" mechanic. Weapons have infinite ammo for fast-paced arcade action.
- **Enhanced Feedback**: Added mandatory Audio and VFX systems (Muzzle Flash, Blood, Sound Effects) to the MVP.
- **UI System**: Added Start Screen, In-Game HUD (Kills, Timer, Rooms), and Summary Screen.

## 3. Core Mechanics & Features

### 🎮 Controls & Input
- **Aiming**: Mouse Look.
- **Shooting**: Left Click (Raycast). **Infinite Ammo**.
- **Movement**: Automatic "On-Rails" movement (Camera moves along a path).

### ⚔️ Combat
- **Weapon**: Raycast hitscan from screen center.
- **Enemies (Red Box)**: Destroy on hit. Spawns "Blood" particles and plays "Hit" sound.
- **Hostages (Green Cylinder)**: "Game Over" or penalty on hit.
- **Feedback**:
    - **Visual**: Muzzle Flash on weapon, Blood Splatter on enemies.
    - **Audio**: Fire sound (looped/one-shot), Impact sound.

### 🔄 Game Loop
1.  **Start**: Main Menu -> Click Start.
2.  **Move**: Camera travels along the rail to the next "Room".
3.  **Breach**: Slow-motion entry (Time Scale effect).
4.  **Clear**: Player destroys all enemies.
5.  **Resume**: Rail movement continues to next section.
6.  **End**: Summary screen showing stats.

## 4. Technical Architecture

### Managers
- **GameManager**: Global state machine (Start, Playing, Win, Loss).
- **RailSystem**: Manages `Path3D` and `PathFollow3D` for camera movement.
- **AudioManager**: Singleton for BGM and pooled Sound Effects.
- **VFXManager**: Handles instantiation of particles to avoid runtime lag.
- **UIManager**: Updates HUD and handles menu transitions.

## 5. Development Phases

### ✅ Phase 1: Setup & Core Systems
*Focus: Project foundation and "Juice" systems.*
- [ ] **Project Setup**: Godot 4 init, Git, Folder structure.
- [ ] **Input**: Map "Fire" and "Look". (No Reload).
- [ ] **Assets**: Greybox materials (Red/Green/Grey).
- [ ] **Audio/VFX Base**: `AudioManager` singleton, simple Particle systems.

### 📅 Phase 2: Player & Movement
*Focus: The "On-Rails" experience.*
- [ ] **Player**: Camera3D rig with mouse look.
- [ ] **Rail System**: Path-based movement logic.
- [ ] **Weapon**: Raycast shooting with the new Audio/VFX hooks.
- [ ] **UI**: Main Menu and HUD implementation.

### 📅 Phase 3: Entities
*Focus: Things to shoot.*
- [ ] **Enemy**: Basic state, hurtbox, death effect.
- [ ] **Hostage**: Penalty logic.
- [ ] **Door**: "Breach" triggers.

### 📅 Phase 4: Game Loop & Polish
*Focus: Making it playable.*
- [ ] **Level Design**: Stringing rooms together.
- [ ] **Win/Loss Logic**: Connecting the loop.
- [ ] **Export**: Web/Desktop build.

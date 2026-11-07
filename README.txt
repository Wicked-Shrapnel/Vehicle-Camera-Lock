Vehicle Camera Lock

For SurrounDead on Steam. Tested with Unreal Engine 5.3.2 and Steam build
19622939 (the installed build at the time this mod was created). Future game
updates may require changes.

Inspiration
-----------
I created this mod so that I could hold W and then use my arrow keys to turn.
I got annoyed at the fact that the camera would move since I personally don't
look around as I'm driving. You can still look around, but if you were to move
forward again the camera will lock again behind the vehicle.

This is a UE4SS Lua runtime mod. It is not a .pak file. It only changes the
third-person camera while the game detects a vehicle and a driving key.

Installation
------------
1. Fully exit SurrounDead.
2. Copy the `SurrounDeadCameraLock` folder into:
   `SurrounDead/SurrounDead/Binaries/Win64/ue4ss/Mods/`
3. In that folder, enable the line below in `mods.txt`:
   `SurrounDeadCameraLock : 1`
4. Launch the game through Steam with this launch option if UE4SS is not
   already configured:
   `WINEDLLOVERRIDES="dwmapi=n,b" %command%`
5. Restart the game after changing files. UE4SS loads Lua mods at startup.

Behavior
--------
- On foot: unchanged; mouse look remains normal.
- In a vehicle with no driving key held: mouse look remains free.
- While W/A/S/D or an arrow key is held: the camera smoothly follows the
  vehicle's current heading, including through turns.
- The camera pitch is preserved, so the view does not point down at the car.
- The heading follow is smoothed to avoid a snap when forward is pressed again.

Controls
--------
No hotkey is used. The mod watches W, A, S, D, Up, Down, Left, and Right.

Tuning
------
`yawFollowSpeed` is in `Scripts/main.lua`. The current value is `7.0`.
Increase it for a faster response; decrease it for a softer, slower blend.

Uninstall / rollback
--------------------
Remove or rename the `SurrounDeadCameraLock` folder, or change its line in
`mods.txt` to `SurrounDeadCameraLock : 0`, then restart the game. This mod
does not modify saves.

The script detects vehicles from the active pawn/view target class name. If a
future game update changes that class name, the UE4SS log can be used to update
the detector.

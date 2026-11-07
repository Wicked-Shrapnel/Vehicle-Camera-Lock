# Vehicle Camera Lock

Vehicle camera follow for **SurrounDead** on Steam.

**Tested with:** Unreal Engine 5.3.2 · Steam build `19622939`

Future game updates may require changes.

## Inspiration

I created this mod so that I could hold W and then use my arrow keys to turn.
I got annoyed at the fact that the camera would move since I personally don't
look around as I'm driving. You can still look around, but if you were to move
forward again the camera will lock again behind the vehicle.

## Features

- On foot, the camera is unchanged.
- In a vehicle, mouse look remains free until a driving key is held.
- While driving, the camera smoothly follows the vehicle's current heading.
- The camera preserves its pitch so it does not point down at the vehicle.
- Forward movement smoothly re-engages the vehicle-heading lock instead of
  snapping.

## Requirements

- SurrounDead on Steam
- UE4SS with Lua support
- A UE4SS build compatible with Unreal Engine 5.3.2

## Installation

1. Fully exit SurrounDead.
2. Copy the `SurrounDeadCameraLock` folder into:

   ```text
   SurrounDead/SurrounDead/Binaries/Win64/ue4ss/Mods/
   ```

3. In `mods.txt`, enable the mod:

   ```text
   SurrounDeadCameraLock : 1
   ```

4. If UE4SS is not already configured, add this to SurrounDead's Steam launch
   options:

   ```text
   WINEDLLOVERRIDES="dwmapi=n,b" %command%
   ```

5. Launch the game through Steam. Restart the game after changing the files;
   UE4SS loads Lua mods at startup.

## Controls

The mod uses no hotkey. It watches `W`, `A`, `S`, `D`, `Up`, `Down`, `Left`,
and `Right` while the player is in a vehicle.

## Tuning

Open `Scripts/main.lua` and adjust `yawFollowSpeed`:

```lua
local yawFollowSpeed = 7.0
```

Increase the value for a faster response or decrease it for a softer blend.

## Uninstall / rollback

Remove or rename the `SurrounDeadCameraLock` folder, or change its entry in
`mods.txt` to:

```text
SurrounDeadCameraLock : 0
```

Then restart the game. This mod does not modify save files.

## Compatibility note

The script detects vehicles from the active pawn or view-target class name. If
a future game update changes that class name, the UE4SS log can be used to
update the detector.

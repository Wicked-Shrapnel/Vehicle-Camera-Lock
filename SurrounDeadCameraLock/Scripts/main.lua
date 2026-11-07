local UEHelpers = require("UEHelpers")

local drivingKeys = {
    { KeyName = FName("W") },
    { KeyName = FName("A") },
    { KeyName = FName("S") },
    { KeyName = FName("D") },
    { KeyName = FName("Up") },
    { KeyName = FName("Down") },
    { KeyName = FName("Left") },
    { KeyName = FName("Right") }
}

local lastVehicleName = ""
local inputErrorLogged = false
local smoothYaw = nil
local lastUpdateSeconds = nil

-- Smaller values feel softer; this is a time-based blend so it is not tied
-- to the game's frame rate.
local yawFollowSpeed = 7.0

local function shortestAngleDelta(from, to)
    local delta = (to - from) % 360.0
    if delta > 180.0 then
        delta = delta - 360.0
    end
    return delta
end

local function looksLikeVehicle(actor)
    if not actor or not actor:IsValid() then
        return false
    end

    local name = string.lower(actor:GetClass():GetFullName())
    local terms = {
        "vehicle", "wheeled", "driveable", "drivable", "car", "truck",
        "sedan", "suv", "van", "bus", "buggy", "humvee", "pickup", "atv"
    }

    for _, term in ipairs(terms) do
        if string.find(name, term, 1, true) then
            return true
        end
    end
    return false
end

local function getVehicleActor(controller)
    local pawn = controller.Pawn
    if looksLikeVehicle(pawn) then
        return pawn
    end

    if pawn and pawn:IsValid() then
        local ok, parent = pcall(function()
            return pawn:GetAttachParentActor()
        end)
        if ok and looksLikeVehicle(parent) then
            return parent
        end
    end

    local cameraManager = controller.PlayerCameraManager
    if cameraManager and cameraManager:IsValid() then
        local ok, viewTarget = pcall(function()
            return cameraManager:GetViewTarget()
        end)
        if ok and looksLikeVehicle(viewTarget) then
            return viewTarget
        end
    end

    return nil
end

local function drivingKeyHeld(controller)
    for _, key in ipairs(drivingKeys) do
        local ok, isDown = pcall(function()
            return controller:IsInputKeyDown(key)
        end)

        if ok and isDown then
            return true
        end

        if not ok and not inputErrorLogged then
            inputErrorLogged = true
            print("[SurrounDeadCameraLock] Could not read driving-key state.\n")
        end
    end
    return false
end

local function updateCamera(controller)
    if not controller or not controller:IsValid() then
        return
    end

    local vehicle = getVehicleActor(controller)
    if not vehicle then
        return
    end

    local vehicleName = vehicle:GetClass():GetFullName()
    if vehicleName ~= lastVehicleName then
        lastVehicleName = vehicleName
        print("[SurrounDeadCameraLock] Vehicle detected: " .. vehicleName .. "\n")
    end

    -- With no driving key held, do nothing: the mouse has full camera control.
    if not drivingKeyHeld(controller) then
        return
    end

    local vehicleRotation = vehicle:K2_GetActorRotation()
    local cameraRotation = controller:GetControlRotation()
    if not vehicleRotation or not cameraRotation then
        return
    end

    -- Blend toward the vehicle heading instead of snapping when W/Up is
    -- pressed again after steering. Mouse pitch is still preserved.
    local now = os.clock()
    local deltaSeconds = 1.0 / 60.0
    if lastUpdateSeconds then
        deltaSeconds = math.max(0.0, math.min(now - lastUpdateSeconds, 0.1))
    end
    lastUpdateSeconds = now

    if smoothYaw == nil then
        smoothYaw = cameraRotation.Yaw
    end

    local blend = 1.0 - math.exp(-yawFollowSpeed * deltaSeconds)
    smoothYaw = smoothYaw + shortestAngleDelta(smoothYaw, vehicleRotation.Yaw) * blend

    controller:SetControlRotation({
        Pitch = cameraRotation.Pitch,
        Yaw = smoothYaw,
        Roll = 0.0
    })
end

local function engineTick()
    local controller = UEHelpers:GetPlayerController()
    if controller and controller:IsValid() then
        updateCamera(controller)
    end

    -- Queue exactly one callback for the next engine tick.
    if EngineTickAvailable then
        ExecuteInGameThread(engineTick, EGameThreadMethod.EngineTick)
    end
end

if EngineTickAvailable then
    ExecuteInGameThread(engineTick, EGameThreadMethod.EngineTick)
else
    print("[SurrounDeadCameraLock] Engine tick hook is unavailable.\n")
end

print("[SurrounDeadCameraLock] Loaded: mouse look is free; driving keys lock behind the vehicle.\n")

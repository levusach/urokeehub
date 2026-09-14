--[[
    uorkee hub by lev_usach
    Clean functional reconstruction of the WeAreDevs-obfuscated script.

    The VM obfuscator irreversibly removes the author's comments and original
    local-variable names. This file restores the observed behavior, constants,
    interface text, defaults, model-highlight ESP and aim routine.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RuntimeEnvironment = _G
pcall(function()
    if getgenv then
        RuntimeEnvironment = getgenv()
    end
end)

local previousDeathStatueCleanup = RuntimeEnvironment.uorkeeDeathStatueCleanup
if type(previousDeathStatueCleanup) == "function" then
    pcall(previousDeathStatueCleanup)
    RuntimeEnvironment.uorkeeDeathStatueCleanup = nil
end

local previousHitSoundCleanup = RuntimeEnvironment.uorkeeHitSoundCleanup
if type(previousHitSoundCleanup) == "function" then
    pcall(previousHitSoundCleanup)
    RuntimeEnvironment.uorkeeHitSoundCleanup = nil
end

local previousVictoryMusicCleanup = RuntimeEnvironment.uorkeeVictoryMusicCleanup
if type(previousVictoryMusicCleanup) == "function" then
    pcall(previousVictoryMusicCleanup)
    RuntimeEnvironment.uorkeeVictoryMusicCleanup = nil
end

do
    local previousAmbientCleanup = RuntimeEnvironment.uorkeeAmbientModeCleanup
    if type(previousAmbientCleanup) == "function" then
        pcall(previousAmbientCleanup)
    end
    RuntimeEnvironment.uorkeeAmbientModeCleanup = nil
    RuntimeEnvironment.uorkeeSetAmbientMode = nil
    RuntimeEnvironment.uorkeeUpdateAmbient = nil
    RuntimeEnvironment.uorkeeAmbientState = nil
end

do
    local previousMovementCleanup = RuntimeEnvironment.uorkeeMovementCleanup
    if type(previousMovementCleanup) == "function" then
        pcall(previousMovementCleanup)
    end
    RuntimeEnvironment.uorkeeMovementCleanup = nil
    RuntimeEnvironment.uorkeeMovementState = nil
end

local function findRuntimeFunction(...)
    for index = 1, select("#", ...) do
        local name = select(index, ...)
        local candidate
        pcall(function()
            candidate = RuntimeEnvironment[name]
        end)
        if type(candidate) == "function" then
            return candidate
        end
    end
end

local SetHiddenProperty = findRuntimeFunction("sethiddenproperty", "set_hidden_property")
local ReadFile = findRuntimeFunction("readfile", "read_file")
local WriteFile = findRuntimeFunction("writefile", "write_file")
local DeleteFile = findRuntimeFunction("delfile", "deletefile", "delete_file")
local IsFile = findRuntimeFunction("isfile", "is_file")
local MakeFolder = findRuntimeFunction("makefolder", "make_folder")
local IsFolder = findRuntimeFunction("isfolder", "is_folder")

local function cleanupRuntime(prefix)
    local fakeLagRootKey = prefix .. "FakeLagRoot"
    local fakeLagSetterKey = prefix .. "FakeLagSetter"
    local fakeLagRoot = RuntimeEnvironment[fakeLagRootKey]
    if fakeLagRoot then
        local previousSetter = RuntimeEnvironment[fakeLagSetterKey] or SetHiddenProperty
        if type(previousSetter) == "function" then
            pcall(previousSetter, fakeLagRoot, "NetworkIsSleeping", false)
        end
        RuntimeEnvironment[fakeLagRootKey] = nil
        RuntimeEnvironment[fakeLagSetterKey] = nil
    end

    local jumpConnectionKey = prefix .. "InfiniteJumpConnection"
    local jumpConnection = RuntimeEnvironment[jumpConnectionKey]
    if jumpConnection then
        pcall(function() jumpConnection:Disconnect() end)
        RuntimeEnvironment[jumpConnectionKey] = nil
    end

    local inputConnectionsKey = prefix .. "InputConnections"
    local inputConnections = RuntimeEnvironment[inputConnectionsKey]
    if type(inputConnections) == "table" then
        for _, connection in ipairs(inputConnections) do
            pcall(function() connection:Disconnect() end)
        end
        RuntimeEnvironment[inputConnectionsKey] = nil
    end

    local cameraConnectionsKey = prefix .. "CustomCameraConnections"
    local cameraConnections = RuntimeEnvironment[cameraConnectionsKey]
    if type(cameraConnections) == "table" then
        for _, connection in ipairs(cameraConnections) do
            pcall(function() connection:Disconnect() end)
        end
        RuntimeEnvironment[cameraConnectionsKey] = nil
    end

    local spinHumanoidKey = prefix .. "SpinHumanoid"
    local spinAutoRotateKey = prefix .. "SpinAutoRotate"
    local spinHumanoid = RuntimeEnvironment[spinHumanoidKey]
    if spinHumanoid then
        pcall(function()
            spinHumanoid.AutoRotate = RuntimeEnvironment[spinAutoRotateKey]
        end)
        RuntimeEnvironment[spinHumanoidKey] = nil
        RuntimeEnvironment[spinAutoRotateKey] = nil
    end

    local spinRootKey = prefix .. "SpinRoot"
    local spinVelocityKey = prefix .. "SpinAngularVelocity"
    local spinRoot = RuntimeEnvironment[spinRootKey]
    if spinRoot then
        pcall(function()
            spinRoot.AssemblyAngularVelocity =
                RuntimeEnvironment[spinVelocityKey] or Vector3.new(0, 0, 0)
        end)
        RuntimeEnvironment[spinRootKey] = nil
        RuntimeEnvironment[spinVelocityKey] = nil
    end
end

-- Clean both the current build and the pre-rebrand build on reinjection.
cleanupRuntime("uorkee")
cleanupRuntime("Kesici")

local previousCameraSettings = RuntimeEnvironment.uorkeeOriginalCameraSettings
    or RuntimeEnvironment.KesiciOriginalCameraSettings
if type(previousCameraSettings) == "table" then
    pcall(function()
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = previousCameraSettings.MaxZoom
        LocalPlayer.CameraMinZoomDistance = previousCameraSettings.MinZoom
        LocalPlayer.CameraMode = previousCameraSettings.CameraMode
        Camera.CameraType = previousCameraSettings.CameraType
        Camera.CameraSubject = previousCameraSettings.CameraSubject
        UserInputService.MouseBehavior = previousCameraSettings.MouseBehavior
        UserInputService.MouseIconEnabled = previousCameraSettings.MouseIconEnabled
    end)
end
RuntimeEnvironment.uorkeeOriginalCameraSettings = nil
RuntimeEnvironment.KesiciOriginalCameraSettings = nil

for _, guiName in ipairs({"uorkeeHub", "KesiciHubV2"}) do
    local oldGui = CoreGui:FindFirstChild(guiName)
    if oldGui then oldGui:Destroy() end
end

pcall(function()
    for _, prefix in ipairs({"uorkee", "Kesici"}) do
        RunService:UnbindFromRenderStep(prefix .. "ESP")
        RunService:UnbindFromRenderStep(prefix .. "Aimlock")
        RunService:UnbindFromRenderStep(prefix .. "Triggerbot")
        RunService:UnbindFromRenderStep(prefix .. "TeleportBind")
        RunService:UnbindFromRenderStep(prefix .. "ForceThirdPerson")
        RunService:UnbindFromRenderStep(prefix .. "SpinBot")
        RunService:UnbindFromRenderStep(prefix .. "MovementBypass")
        RunService:UnbindFromRenderStep(prefix .. "FakeLag")
        RunService:UnbindFromRenderStep(prefix .. "MenuFX")
        RunService:UnbindFromRenderStep(prefix .. "AmbientMode")
    end
end)

local Settings = {
    TeamCheck = false,

    ESPEnabled = true,
    NamesESP = true,
    DeathStatueEnabled = true,
    DeathStatueText = "REST IN NEON — {player}",

    AimbotEnabled = true,
    TriggerbotEnabled = true,
    TriggerDelay = 0.001,
    HitSoundEnabled = true,
    HitSoundVolume = 0.65,
    HitSoundPitch = 1.0,
    HitSoundUseCustom = false,
    HitSoundCustomId = "",
    VictoryMusicEnabled = true,
    VictoryMusicVolume = 0.65,
    VictoryMusicId1 = "",
    VictoryMusicStartOffset1 = 0,
    VictoryMusicId2 = "",
    VictoryMusicStartOffset2 = 0,
    VictoryMusicId3 = "",
    VictoryMusicStartOffset3 = 0,
    VictoryMusicId4 = "",
    VictoryMusicStartOffset4 = 0,
    VictoryMusicId5 = "",
    VictoryMusicStartOffset5 = 0,
    AmbientModeEnabled = true,
    AmbientTintStrength = 0.24,
    AmbientParticleRate = 34,
    NoclipEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    InfiniteJumpEnabled = true,
    FakeLagEnabled = true,
    FakeLagHold = 0.25,
    FakeLagRelease = 0.04,
    WallCheck = true,
    ShowFOV = false,
    RainbowFOV = false,
    FOVRadius = 1000,
    AimSpeed = 10,

    MenuOpacity = 0.0,
    Red = 28,
    Green = 30,
    Blue = 234,
    MenuKey = Enum.KeyCode.RightShift,
    TeleportKey = Enum.KeyCode.T,
    TeleportBindMode = "Hold",
    AimbotKey = Enum.KeyCode.Q,
    AimbotBindMode = "Toggle",
    TriggerbotKey = Enum.KeyCode.E,
    TriggerbotBindMode = "Toggle",
    NoclipKey = Enum.KeyCode.N,
    NoclipBindMode = "Toggle",
    SpeedKey = Enum.KeyCode.V,
    SpeedBindMode = "Toggle",
    TeleportOffset = 3,
    TeleportWhitelist = {"fffdtrrrr","rivalsmaster_new"
    },
}

local ConfigRoot = "uorkeeHub"
local ConfigFolder = ConfigRoot .. "/configs"
local ConfigStatePath = ConfigRoot .. "/config_state.json"
local LegacyConfigRoot = "KesiciHub"
local LegacyConfigFolder = LegacyConfigRoot .. "/configs"
local LegacyConfigStatePath = LegacyConfigRoot .. "/config_state.json"
local ConfigState = {
    ActiveConfig = "default",
    AutoSave = true,
    LoadSection = "All",
}
local ConfigControls = {}
local ConfigApplying = false
local ConfigStatusLabel
local refreshKeyButtons
local autoSaveRevision = 0
local ConfigSessionToken = {}
RuntimeEnvironment.uorkeeConfigSessionToken = ConfigSessionToken
local TeleportBindHeld = false
local TeleportBindToggled = false
local AimbotBindHeld = false
local TriggerbotBindHeld = false
local nextTeleportBindAt = 0
local stopVictoryMusic
local updateVictoryMusicVolume
local updateVictoryMusicOffset
local requestVictoryMusicEvaluation

local ConfigKeys = {
    "TeamCheck",
    "ESPEnabled", "NamesESP", "DeathStatueEnabled", "DeathStatueText",
    "AimbotEnabled", "TriggerbotEnabled", "TriggerDelay",
    "HitSoundEnabled", "HitSoundVolume", "HitSoundPitch",
    "HitSoundUseCustom", "HitSoundCustomId",
    "VictoryMusicEnabled", "VictoryMusicVolume",
    "VictoryMusicId1", "VictoryMusicStartOffset1",
    "VictoryMusicId2", "VictoryMusicStartOffset2",
    "VictoryMusicId3", "VictoryMusicStartOffset3",
    "VictoryMusicId4", "VictoryMusicStartOffset4",
    "VictoryMusicId5", "VictoryMusicStartOffset5",
    "AmbientModeEnabled", "AmbientTintStrength", "AmbientParticleRate",
    "NoclipEnabled", "SpeedEnabled", "SpeedValue", "InfiniteJumpEnabled",
    "FakeLagEnabled", "FakeLagHold", "FakeLagRelease",
    "WallCheck", "ShowFOV", "RainbowFOV", "FOVRadius", "AimSpeed",
    "MenuOpacity", "Red", "Green", "Blue",
    "MenuKey", "TeleportKey", "TeleportBindMode",
    "AimbotKey", "AimbotBindMode", "TriggerbotKey", "TriggerbotBindMode",
    "NoclipKey", "NoclipBindMode", "SpeedKey", "SpeedBindMode",
    "TeleportOffset", "TeleportWhitelist",
}

RuntimeEnvironment.uorkeeConfigSections = {
    Combat = {
        TeamCheck = true,
        AimbotEnabled = true,
        TriggerbotEnabled = true,
        TriggerDelay = true,
        WallCheck = true,
        ShowFOV = true,
        RainbowFOV = true,
        FOVRadius = true,
        AimSpeed = true,
    },
    Audio = {
        HitSoundEnabled = true,
        HitSoundVolume = true,
        HitSoundPitch = true,
        HitSoundUseCustom = true,
        HitSoundCustomId = true,
        VictoryMusicEnabled = true,
        VictoryMusicVolume = true,
        VictoryMusicId1 = true,
        VictoryMusicStartOffset1 = true,
        VictoryMusicId2 = true,
        VictoryMusicStartOffset2 = true,
        VictoryMusicId3 = true,
        VictoryMusicStartOffset3 = true,
        VictoryMusicId4 = true,
        VictoryMusicStartOffset4 = true,
        VictoryMusicId5 = true,
        VictoryMusicStartOffset5 = true,
    },
    Visuals = {
        ESPEnabled = true,
        NamesESP = true,
        DeathStatueEnabled = true,
        DeathStatueText = true,
    },
    Movement = {
        NoclipEnabled = true,
        SpeedEnabled = true,
        SpeedValue = true,
        InfiniteJumpEnabled = true,
        FakeLagEnabled = true,
        FakeLagHold = true,
        FakeLagRelease = true,
        TeleportOffset = true,
        TeleportWhitelist = true,
    },
    Keybinds = {
        MenuKey = true,
        TeleportKey = true,
        TeleportBindMode = true,
        AimbotKey = true,
        AimbotBindMode = true,
        TriggerbotKey = true,
        TriggerbotBindMode = true,
        NoclipKey = true,
        NoclipBindMode = true,
        SpeedKey = true,
        SpeedBindMode = true,
    },
    Appearance = {
        MenuOpacity = true,
        Red = true,
        Green = true,
        Blue = true,
        AmbientModeEnabled = true,
        AmbientTintStrength = true,
        AmbientParticleRate = true,
    },
}
RuntimeEnvironment.uorkeeConfigSectionOrder = {
    "All", "Combat", "Audio", "Visuals", "Movement", "Keybinds", "Appearance",
}
RuntimeEnvironment.uorkeeConfigSectionLabels = {
    All = "ALL SETTINGS",
    Combat = "COMBAT",
    Audio = "AUDIO",
    Visuals = "VISUALS",
    Movement = "MOVEMENT",
    Keybinds = "KEYBINDS",
    Appearance = "APPEARANCE",
}

local BindingSettingKeys = {
    MenuKey = true,
    TeleportKey = true,
    AimbotKey = true,
    TriggerbotKey = true,
    NoclipKey = true,
    SpeedKey = true,
}

local BindModeSettingKeys = {
    TeleportBindMode = true,
    AimbotBindMode = true,
    TriggerbotBindMode = true,
    NoclipBindMode = true,
    SpeedBindMode = true,
}

local ExpectedSettingTypes = {}
for _, key in ipairs(ConfigKeys) do
    ExpectedSettingTypes[key] = type(Settings[key])
end

local function sanitizeConfigName(value)
    local name = tostring(value or "")
    name = name:gsub("[^%w_%- ]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", "_")
    if name == "" then name = "default" end
    return name:sub(1, 32)
end

local function ensureFolder(path)
    if type(IsFolder) == "function" then
        local checked, exists = pcall(IsFolder, path)
        if checked and exists then return true end
    end
    if type(MakeFolder) ~= "function" then return false end
    local made = pcall(MakeFolder, path)
    if made then return true end
    if type(IsFolder) == "function" then
        local checked, exists = pcall(IsFolder, path)
        return checked and exists
    end
    return false
end

local function ensureConfigFolders()
    return ensureFolder(ConfigRoot) and ensureFolder(ConfigFolder)
end

local function configPath(name)
    return ConfigFolder .. "/" .. sanitizeConfigName(name) .. ".json"
end

local function fileExists(path)
    if type(IsFile) == "function" then
        local success, exists = pcall(IsFile, path)
        if success then return exists end
    end
    if type(ReadFile) ~= "function" then return false end
    return pcall(ReadFile, path)
end

local function readJson(path)
    if type(ReadFile) ~= "function" or not fileExists(path) then
        return nil, "file not found"
    end
    local readSuccess, contents = pcall(ReadFile, path)
    if not readSuccess then return nil, tostring(contents) end
    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not decodeSuccess or type(data) ~= "table" then
        return nil, "invalid JSON"
    end
    return data
end

local function writeJson(path, data)
    if type(WriteFile) ~= "function" or not ensureConfigFolders() then
        return false, "filesystem API unavailable"
    end
    local encodeSuccess, contents = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not encodeSuccess then return false, tostring(contents) end
    local writeSuccess, writeError = pcall(WriteFile, path, contents)
    if not writeSuccess then return false, tostring(writeError) end
    return true
end

local function bindingFromName(value)
    if type(value) ~= "string" then return nil end

    if value == "MouseButton1" or value == "MouseButton2" or value == "MouseButton3" then
        local mouseSuccess, mouseButton = pcall(function()
            return Enum.UserInputType[value]
        end)
        if mouseSuccess then return mouseButton end
    end

    local success, keyCode = pcall(function()
        return Enum.KeyCode[value]
    end)
    if success and keyCode and keyCode ~= Enum.KeyCode.Unknown then
        return keyCode
    end

end

local function serializeSettings()
    local result = {}
    for _, key in ipairs(ConfigKeys) do
        local value = Settings[key]
        if BindingSettingKeys[key] then
            result[key] = value and value.Name or nil
        elseif key == "TeleportWhitelist" then
            local playerList = {}
            for _, playerIdentity in ipairs(value or {}) do
                if type(playerIdentity) == "string" or type(playerIdentity) == "number" then
                    playerList[#playerList + 1] = playerIdentity
                end
            end
            result[key] = playerList
        else
            result[key] = value
        end
    end
    return result
end

local function applySettings(data, updateControls, allowedKeys)
    if type(data) ~= "table" then return false end
    ConfigApplying = true
    if type(data.VictoryMusicStartOffset) == "number"
        and (not allowedKeys or allowedKeys.VictoryMusicStartOffset1) then
        for slot = 1, 5 do
            local offsetKey = "VictoryMusicStartOffset" .. tostring(slot)
            if data[offsetKey] == nil then
                Settings[offsetKey] = data.VictoryMusicStartOffset
            end
        end
    end
    for _, key in ipairs(ConfigKeys) do
        local value = data[key]
        if value ~= nil and (not allowedKeys or allowedKeys[key]) then
            if BindingSettingKeys[key] then
                local binding = bindingFromName(value)
                if binding then Settings[key] = binding end
            elseif BindModeSettingKeys[key] then
                if value == "Hold" or value == "Toggle" then
                    Settings[key] = value
                end
            elseif key == "TeleportWhitelist" and type(value) == "table" then
                local playerList = {}
                for _, playerIdentity in ipairs(value) do
                    if type(playerIdentity) == "string" or type(playerIdentity) == "number" then
                        playerList[#playerList + 1] = playerIdentity
                    end
                end
                Settings[key] = playerList
            elseif type(value) == ExpectedSettingTypes[key] then
                Settings[key] = value
            end
        end
    end

    if updateControls then
        for key, setter in pairs(ConfigControls) do
            if not allowedKeys or allowedKeys[key] then
                setter(Settings[key])
            end
        end
        if refreshKeyButtons then refreshKeyButtons() end
    end
    ConfigApplying = false
    return true
end

local function saveConfig(name)
    name = sanitizeConfigName(name or "default")
    return writeJson(configPath(name), {
        Version = 1,
        Settings = serializeSettings(),
    })
end

local function loadConfig(name, updateControls, sectionName)
    name = sanitizeConfigName(name or "default")
    local payload, loadError = readJson(configPath(name))
    if not payload then return false, loadError end
    local data = payload.Settings or payload
    local allowedKeys
    if sectionName then
        allowedKeys = RuntimeEnvironment.uorkeeConfigSections[sectionName]
        if type(allowedKeys) ~= "table" then
            return false, "unknown config section"
        end
    end
    if not applySettings(data, updateControls, allowedKeys) then
        return false, "invalid config data"
    end
    return true
end

local function saveConfigState()
    return writeJson(ConfigStatePath, {
        Version = 1,
        ActiveConfig = "default",
        AutoSave = ConfigState.AutoSave == true,
        LoadSection = ConfigState.LoadSection,
    })
end

do
    local state = readJson(ConfigStatePath)
    local migratedLegacyState = false
    ConfigState.PreviousActiveConfig = "default"
    if type(state) ~= "table" then
        state = readJson(LegacyConfigStatePath)
        migratedLegacyState = type(state) == "table"
    end
    if type(state) == "table" then
        ConfigState.PreviousActiveConfig = sanitizeConfigName(state.ActiveConfig)
        if type(state.AutoSave) == "boolean" then
            ConfigState.AutoSave = state.AutoSave
        end
        if state.LoadSection == "All"
            or RuntimeEnvironment.uorkeeConfigSections[state.LoadSection] then
            ConfigState.LoadSection = state.LoadSection
        end
    end
    ConfigState.ActiveConfig = "default"
    local loaded = false
    if ConfigState.PreviousActiveConfig ~= "default" then
        loaded = loadConfig(ConfigState.PreviousActiveConfig, false)
        if loaded then
            saveConfig("default")
            migratedLegacyState = true
        end
    end
    if not loaded then
        loaded = loadConfig("default", false)
    end
    if not loaded then
        local legacyPath = LegacyConfigFolder .. "/"
            .. (ConfigState.PreviousActiveConfig ~= "default" and ConfigState.PreviousActiveConfig or "default")
            .. ".json"
        local legacyPayload = readJson(legacyPath)
        if type(legacyPayload) == "table" then
            applySettings(legacyPayload.Settings or legacyPayload, false)
            saveConfig("default")
            migratedLegacyState = true
        end
    end
    ConfigState.PreviousActiveConfig = nil
    if migratedLegacyState then saveConfigState() end
end

local function setConfigStatus(message, success)
    if ConfigStatusLabel then
        ConfigStatusLabel.Text = " " .. tostring(message)
        ConfigStatusLabel.TextColor3 = success == false
            and Color3.fromRGB(255, 115, 115)
            or Color3.fromRGB(180, 235, 180)
    end
end

local function queueAutoSave()
    if ConfigApplying or not ConfigState.AutoSave then return end
    autoSaveRevision = autoSaveRevision + 1
    local revision = autoSaveRevision
    task.delay(0.35, function()
        if revision ~= autoSaveRevision then return end
        if RuntimeEnvironment.uorkeeConfigSessionToken ~= ConfigSessionToken then return end
        ConfigState.ActiveConfig = "default"
        local success, saveError = saveConfig("default")
        if success then
            saveConfigState()
            setConfigStatus("Auto-saved: default", true)
        else
            setConfigStatus("Auto-save failed: " .. tostring(saveError), false)
        end
    end)
end

local function themeColor()
    return Color3.fromRGB(Settings.Red, Settings.Green, Settings.Blue)
end

local function viewportCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = viewportCenter()
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Thickness = 1.5
FOVCircle.Color = themeColor()

local function create(className, parent, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function addCorner(parent, radius)
    return create("UICorner", parent, {
        CornerRadius = UDim.new(0, radius or 6),
    })
end

local function addStroke(parent, color, thickness, transparency)
    return create("UIStroke", parent, {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    })
end

local function glassTransparency()
    return math.clamp(0.12 + Settings.MenuOpacity * 0.7, 0.12, 0.82)
end

local function menuTransparency()
    -- Keep enough dark backing for readable text even over a bright scene.
    return 0.06 + math.clamp(Settings.MenuOpacity, 0, 1) * 0.22
end

local function liquidColors(accent, darkness)
    darkness = darkness or 0.72
    local dark = Color3.fromRGB(12, 15, 24)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, accent:Lerp(dark, darkness)),
        ColorSequenceKeypoint.new(0.48, dark),
        ColorSequenceKeypoint.new(1, accent:Lerp(dark, math.max(0.48, darkness - 0.12))),
    })
end

local function addLiquidGradient(parent, rotation)
    return create("UIGradient", parent, {
        Color = liquidColors(themeColor()),
        Rotation = rotation or 25,
        -- A gradient on a text object also multiplies its text color.
        Enabled = parent.ClassName ~= "TextButton" and parent.ClassName ~= "TextLabel"
            and parent.ClassName ~= "TextBox",
    })
end

local function addLiquidHover(object, normalTransparency, hoverTransparency)
    object.MouseEnter:Connect(function()
        TweenService:Create(object, TweenInfo.new(0.16, Enum.EasingStyle.Quint), {
            BackgroundTransparency = hoverTransparency,
        }):Play()
    end)
    object.MouseLeave:Connect(function()
        TweenService:Create(object, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
            BackgroundTransparency = normalTransparency,
        }):Play()
    end)
end

local ScreenGui = create("ScreenGui", CoreGui, {
    Name = "uorkeeHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local MenuButton = create("TextButton", ScreenGui, {
    Name = "MenuButton",
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 18, 0, 18),
    BackgroundColor3 = Color3.fromRGB(18, 21, 31),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Text = "u",
    TextColor3 = Color3.fromRGB(250, 250, 255),
    TextSize = 21,
    Font = Enum.Font.GothamBlack,
    AutoButtonColor = false,
})
addCorner(MenuButton, 17)
local MenuButtonStroke = addStroke(MenuButton, themeColor(), 1.4, 0.12)
local MenuButtonGradient = addLiquidGradient(MenuButton, 35)
local MenuButtonDot = create("Frame", MenuButton, {
    Size = UDim2.new(0, 7, 0, 7),
    Position = UDim2.new(1, -11, 0, 5),
    BackgroundColor3 = themeColor(),
    BorderSizePixel = 0,
})
addCorner(MenuButtonDot, 20)
addLiquidHover(MenuButton, 0.12, 0.02)

-- Use a Frame: CanvasGroup flattens children, so its gradient darkens all text.
local Main = create("Frame", ScreenGui, {
    Name = "Main",
    Size = UDim2.new(0.88, 0, 0.86, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    ZIndex = 20,
    Active = true,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = menuTransparency(),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
})
addCorner(Main, 20)
local MainStroke = addStroke(Main, themeColor(), 1.25, 0.22)
local MainGradient = addLiquidGradient(Main, 28)

local MainGlowA = create("Frame", Main, {
    Size = UDim2.new(0, 650, 0, 650),
    Position = UDim2.new(0, -260, 0, -330),
    BackgroundColor3 = themeColor(),
    BackgroundTransparency = 0.93,
    BorderSizePixel = 0,
    ZIndex = 1,
})
addCorner(MainGlowA, 999)
local MainGlowB = create("Frame", Main, {
    Size = UDim2.new(0, 800, 0, 800),
    Position = UDim2.new(1, -480, 1, -400),
    BackgroundColor3 = themeColor(),
    BackgroundTransparency = 0.95,
    BorderSizePixel = 0,
    ZIndex = 1,
})
addCorner(MainGlowB, 999)

local HeaderGlass = create("Frame", Main, {
    Name = "HeaderGlass",
    Size = UDim2.new(1, -32, 0, 78),
    Position = UDim2.new(0, 16, 0, 16),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 3,
})
addCorner(HeaderGlass, 14)
local HeaderStroke = addStroke(HeaderGlass, Color3.fromRGB(255, 255, 255), 1, 0.82)
local HeaderGradient = addLiquidGradient(HeaderGlass, 12)
local HeaderShine = create("Frame", HeaderGlass, {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.58,
    BorderSizePixel = 0,
    ZIndex = 4,
})
addCorner(HeaderShine, 2)

create("TextLabel", HeaderGlass, {
    Name = "Title",
    Size = UDim2.new(1, -58, 0, 28),
    Position = UDim2.new(0, 14, 0, 8),
    BackgroundTransparency = 1,
    Text = "uorkee hub",
    TextColor3 = Color3.fromRGB(250, 250, 255),
    TextSize = 23,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
})

local HeaderAccent = create("Frame", HeaderGlass, {
    Size = UDim2.new(0, 28, 0, 3),
    Position = UDim2.new(0, 14, 0, 36),
    BackgroundColor3 = themeColor(),
    BorderSizePixel = 0,
    ZIndex = 4,
})
addCorner(HeaderAccent, 4)

create("TextLabel", HeaderGlass, {
    Name = "Information",
    Size = UDim2.new(1, -28, 0, 26),
    Position = UDim2.new(0, 14, 0, 43),
    BackgroundTransparency = 1,
    Text = "by lev_usach  /  PERSONAL CONTROL SPACE",
    TextColor3 = Color3.fromRGB(172, 180, 198),
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
})

local MenuUI = {Open = false, Alive = true, Serial = 0, Tweens = {}, Pages = {}, Tabs = {}, Particles = {}}
local CloseButton = create("TextButton", HeaderGlass, {
    Name = "Close",
    Size = UDim2.new(0, 34, 0, 34),
    Position = UDim2.new(1, -42, 0, 8),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = Color3.fromRGB(222, 226, 238),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 5,
})
addCorner(CloseButton, 11)
addLiquidHover(CloseButton, 0.9, 0.76)
CloseButton.MouseButton1Click:Connect(function()
    MenuUI.setOpen(false)
end)

MenuUI.Scale = create("UIScale", Main, {Scale = 1})
MenuUI.Sidebar = create("ScrollingFrame", Main, {
    Name = "Navigation", Position = UDim2.new(0, 16, 0, 110),
    Size = UDim2.new(0, 210, 1, -126), BackgroundColor3 = Color3.fromRGB(12, 16, 26),
    BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 3,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 0,
})
addCorner(MenuUI.Sidebar, 18)
MenuUI.SideStroke = addStroke(MenuUI.Sidebar, themeColor(), 1, 0.75)
create("UIListLayout", MenuUI.Sidebar, {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder})
create("UIPadding", MenuUI.Sidebar, {
    PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
    PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18),
})
create("TextLabel", MenuUI.Sidebar, {
    Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
    Text = "WORKSPACE", TextSize = 10, Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(130, 144, 168), TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 0,
})
MenuUI.Body = create("Frame", Main, {
    Name = "PageHost", Position = UDim2.new(0, 242, 0, 110),
    Size = UDim2.new(1, -258, 1, -126), BackgroundColor3 = Color3.fromRGB(12, 16, 26),
    BackgroundTransparency = 0.12, BorderSizePixel = 0, ZIndex = 3, ClipsDescendants = true,
})
addCorner(MenuUI.Body, 18)
MenuUI.BodyStroke = addStroke(MenuUI.Body, themeColor(), 1, 0.82)
MenuUI.Heading = create("TextLabel", MenuUI.Body, {
    Position = UDim2.new(0, 22, 0, 16), Size = UDim2.new(1, -44, 0, 34),
    BackgroundTransparency = 1, Text = "", TextSize = 25, Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(240, 244, 255), TextXAlignment = Enum.TextXAlignment.Left,
})
MenuUI.Caption = create("TextLabel", MenuUI.Body, {
    Position = UDim2.new(0, 22, 0, 53), Size = UDim2.new(1, -44, 0, 32),
    BackgroundTransparency = 1, Text = "", TextSize = 13, TextWrapped = true,
    Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(192, 202, 221),
    TextXAlignment = Enum.TextXAlignment.Left,
})
MenuUI.Sweep = create("Frame", Main, {
    Name = "RevealSweep", Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = themeColor(),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6,
})

function MenuUI.tween(object, duration, properties)
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    MenuUI.Tweens[#MenuUI.Tweens + 1] = tween
    tween:Play()
end

function MenuUI.paintTabs()
    for id, tab in pairs(MenuUI.Tabs) do
        local selected = MenuUI.Selected == id
        tab.Button.BackgroundColor3 = selected and themeColor():Lerp(Color3.fromRGB(20, 25, 40), 0.65) or Color3.fromRGB(24, 28, 39)
        tab.Button.BackgroundTransparency = selected and 0.08 or 0.7
        tab.Button.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(198, 208, 228)
        tab.Bar.BackgroundColor3 = themeColor()
        tab.Bar.Visible = selected
    end
end

function MenuUI.select(id)
    if MenuUI.Selected == id then return end
    MenuUI.Selected = id
    if MenuUI.PageTween then MenuUI.PageTween:Cancel() end
    for name, page in pairs(MenuUI.Pages) do page.Visible = name == id end
    local tab, page = MenuUI.Tabs[id], MenuUI.Pages[id]
    MenuUI.Heading.Text = tab.Title
    MenuUI.Caption.Text = tab.Caption
    page.Position = UDim2.new(0, 14, 0, 108)
    MenuUI.PageTween = TweenService:Create(page, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 14, 0, 94),
    })
    MenuUI.PageTween:Play()
    MenuUI.paintTabs()
end

do
    local definitions = {
        {"combat", "Combat", "Aimbot, triggerbot and targeting preferences"},
        {"audio", "Audio", "Hit feedback and round victory music"},
        {"visuals", "Visuals", "Player highlights and visibility"},
        {"movement", "Movement", "Movement tools and timing"},
        {"binds", "Keybinds", "Choose a key, then Hold or Toggle for each feature"},
        {"theme", "Appearance", "Your color palette, glass and atmosphere"},
        {"configs", "Configs", "Save your setup and restore it next session"},
    }
    for index, definition in ipairs(definitions) do
        local id = definition[1]
        local button = create("TextButton", MenuUI.Sidebar, {
            Name = id, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = index,
            BackgroundColor3 = Color3.fromRGB(24, 28, 39), BackgroundTransparency = 0.7,
            BorderSizePixel = 0, Text = string.format("   %02d    %s", index, definition[2]),
            TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(158, 169, 192), AutoButtonColor = false,
        })
        addCorner(button, 12)
        local bar = create("Frame", button, {
            Size = UDim2.new(0, 3, 0, 22), Position = UDim2.new(0, 0, 0.5, -11),
            BorderSizePixel = 0, BackgroundColor3 = themeColor(),
        })
        addCorner(bar, 3)
        local page = create("ScrollingFrame", MenuUI.Body, {
            Name = id .. "Page", Position = UDim2.new(0, 14, 0, 94), Size = UDim2.new(1, -28, 1, -108),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = themeColor(), CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
        })
        create("UIListLayout", page, {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})
        create("UIPadding", page, {
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 18),
        })
        MenuUI.Pages[id] = page
        MenuUI.Tabs[id] = {Button = button, Bar = bar, Title = definition[2], Caption = definition[3]}
        button.MouseButton1Click:Connect(function() MenuUI.select(id) end)
        button.MouseEnter:Connect(function()
            if MenuUI.Selected ~= id then button.BackgroundTransparency = 0.4 end
        end)
        button.MouseLeave:Connect(MenuUI.paintTabs)
    end
    -- Layered translucent circles form asset-free soft particle halos.
    for index = 1, 28 do
        local size = math.random(3, 7)
        local particle = create("Frame", Main, {
            Name = "GlowParticle", Size = UDim2.new(0, size, 0, size),
            BackgroundColor3 = themeColor(), BackgroundTransparency = 0.4,
            BorderSizePixel = 0, ZIndex = 2, AnchorPoint = Vector2.new(0.5, 0.5),
        })
        addCorner(particle, 99)
        local halos = {}
        for layer = 1, 4 do
            local halo = create("Frame", particle, {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, size + layer * 8, 0, size + layer * 8),
                BackgroundColor3 = themeColor(), BackgroundTransparency = 0.94 + layer * 0.009,
                BorderSizePixel = 0, ZIndex = 2,
            })
            addCorner(halo, 99)
            halos[#halos + 1] = halo
        end
        MenuUI.Particles[index] = {Object = particle, Halos = halos, X = math.random(), Y = math.random(),
            Speed = 0.008 + math.random() * 0.018, Phase = math.random() * math.pi * 2}
    end
end

function MenuUI.resize()
    local width = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1280
    local sidebarWidth = math.clamp(math.floor(width * 0.88 * 0.18), 150, 220)
    MenuUI.Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -126)
    MenuUI.Body.Position = UDim2.new(0, sidebarWidth + 32, 0, 110)
    MenuUI.Body.Size = UDim2.new(1, -sidebarWidth - 48, 1, -126)
    MenuUI.Width = width
end

function MenuUI.setOpen(open)
    if not MenuUI.Alive or MenuUI.Open == open then return end
    if RuntimeEnvironment.uorkeeConfigSessionToken ~= ConfigSessionToken then return end
    MenuUI.Open = open
    MenuUI.Serial = MenuUI.Serial + 1
    local serial = MenuUI.Serial
    for _, tween in ipairs(MenuUI.Tweens) do tween:Cancel() end
    MenuUI.Tweens = {}
    if open then
        MenuUI.resize()
        Main.Visible = true
        MenuButton.Visible = false
        Main.Position = UDim2.new(0.5, 0, 0.5, 24)
        Main.BackgroundTransparency = 1
        MenuUI.Scale.Scale = 0.97
        MenuUI.Sidebar.Position = UDim2.new(0, -32, 0, 110)
        HeaderGlass.Position = UDim2.new(0, 16, 0, -24)
        MenuUI.Sweep.Position = UDim2.new(0, 0, 0, 0)
        MenuUI.Sweep.BackgroundTransparency = 0.3
        MenuUI.tween(Main, 0.36, {
            Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = menuTransparency(),
        })
        MenuUI.tween(MenuUI.Scale, 0.55, {Scale = 1})
        MenuUI.tween(MenuUI.Sidebar, 0.55, {Position = UDim2.new(0, 16, 0, 110)})
        MenuUI.tween(HeaderGlass, 0.45, {Position = UDim2.new(0, 16, 0, 16)})
        MenuUI.tween(MenuUI.Sweep, 0.8, {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
    else
        MenuUI.tween(Main, 0.22, {
            Position = UDim2.new(0.5, 0, 0.5, 18), BackgroundTransparency = 1,
        })
        MenuUI.tween(MenuUI.Scale, 0.22, {Scale = 0.985})
        task.delay(0.23, function()
            if RuntimeEnvironment.uorkeeConfigSessionToken ~= ConfigSessionToken then return end
            if MenuUI.Alive and MenuUI.Serial == serial and not MenuUI.Open then
                Main.Visible = false
                MenuButton.Visible = true
            end
        end)
    end
end

MenuUI.resize()
MenuUI.select("combat")
RunService:UnbindFromRenderStep("uorkeeMenuFX")
RunService:BindToRenderStep("uorkeeMenuFX", Enum.RenderPriority.Last.Value, function(delta)
    if not MenuUI.Alive or not Main.Visible then return end
    if RuntimeEnvironment.uorkeeConfigSessionToken ~= ConfigSessionToken then return end
    MenuUI.Time = (MenuUI.Time or 0) + math.min(delta, 0.05)
    local time = MenuUI.Time
    local currentCamera = workspace.CurrentCamera
    if currentCamera and MenuUI.Width ~= currentCamera.ViewportSize.X then MenuUI.resize() end
    for _, particle in ipairs(MenuUI.Particles) do
        particle.Object.Position = UDim2.new(
            (particle.X + math.sin(time * 0.19 + particle.Phase) * 0.055) % 1, 0,
            (particle.Y - time * particle.Speed) % 1, 0)
        particle.Object.BackgroundTransparency = 0.35 + (math.sin(time * 1.2 + particle.Phase) + 1) * 0.2
    end
    MainGradient.Rotation = 28 + math.sin(time * 0.1) * 18
end)

local Content = MenuUI.Pages.binds

local refreshers = {}
local function registerRefresh(callback)
    refreshers[#refreshers + 1] = callback
    callback()
end

local function refreshTheme()
    local color = themeColor()
    MenuButtonDot.BackgroundColor3 = color
    MenuButtonStroke.Color = color
    MenuButtonGradient.Color = liquidColors(color)
    MainStroke.Color = color
    MainGradient.Color = liquidColors(color, 0.76)
    HeaderGradient.Color = liquidColors(color, 0.7)
    HeaderAccent.BackgroundColor3 = color
    MainGlowA.BackgroundColor3 = color
    MainGlowB.BackgroundColor3 = color
    MenuUI.SideStroke.Color = color
    MenuUI.BodyStroke.Color = color
    MenuUI.Sweep.BackgroundColor3 = color
    MenuUI.paintTabs()
    for _, page in pairs(MenuUI.Pages) do page.ScrollBarImageColor3 = color end
    for _, particle in ipairs(MenuUI.Particles) do
        particle.Object.BackgroundColor3 = color
        for _, halo in ipairs(particle.Halos) do halo.BackgroundColor3 = color end
    end
    for _, callback in ipairs(refreshers) do
        callback(color)
    end
end

local function makeDraggable(handle, target)
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(MenuButton, MenuButton)

local function addSection(text)
    local cleanText = text:gsub("%-", ""):gsub("^%s+", ""):gsub("%s+$", "")
    local label = create("TextLabel", Content, {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(24, 28, 39),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Text = "     " .. cleanText,
        TextColor3 = themeColor():Lerp(Color3.fromRGB(255, 255, 255), 0.78),
        TextSize = 12,
        TextWrapped = true,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    addCorner(label, 10)
    local stroke = addStroke(label, themeColor(), 1, 0.82)
    local accent = create("Frame", label, {
        Size = UDim2.new(0, 3, 0, 14),
        Position = UDim2.new(0, 11, 0.5, -7),
        BackgroundColor3 = themeColor(),
        BorderSizePixel = 0,
    })
    addCorner(accent, 4)
    registerRefresh(function(color)
        color = color or themeColor()
        label.TextColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), 0.78)
        stroke.Color = color
        accent.BackgroundColor3 = color
    end)
    return label
end

local function addToggle(text, initialValue, changed, settingKey)
    local enabled = initialValue
    local button = create("TextButton", Content, {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(24, 28, 39),
        BackgroundTransparency = 0.38,
        BorderSizePixel = 0,
        Text = "   " .. text,
        TextColor3 = Color3.fromRGB(232, 236, 246),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    addCorner(button, 12)
    local buttonStroke = addStroke(button, themeColor(), 1, 0.78)
    local buttonGradient = addLiquidGradient(button, 8)
    addLiquidHover(button, 0.38, 0.24)

    local indicator = create("Frame", button, {
        Size = UDim2.new(0, 36, 0, 20),
        Position = UDim2.new(1, -48, 0.5, -10),
        BackgroundColor3 = themeColor(),
        BackgroundTransparency = enabled and 0.12 or 0.72,
        BorderSizePixel = 0,
    })
    addCorner(indicator, 12)
    local indicatorStroke = addStroke(indicator, themeColor(), 1, enabled and 0.18 or 0.62)
    local fill = create("Frame", indicator, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(248, 249, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    })
    addCorner(fill, 10)

    local function repaint(color)
        color = color or themeColor()
        buttonStroke.Color = color
        buttonStroke.Transparency = enabled and 0.58 or 0.8
        buttonGradient.Color = liquidColors(color, 0.84)
        indicatorStroke.Color = color
        indicatorStroke.Transparency = enabled and 0.18 or 0.62
        indicator.BackgroundColor3 = color
        indicator.BackgroundTransparency = enabled and 0.12 or 0.72
        fill.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end
    registerRefresh(repaint)

    local function setValue(value)
        enabled = value == true
        repaint()
        changed(enabled)
        queueAutoSave()
    end

    button.MouseButton1Click:Connect(function()
        setValue(not enabled)
    end)
    if settingKey then
        ConfigControls[settingKey] = setValue
    end
    return button, setValue
end

local function addSlider(text, minimum, maximum, initialValue, decimals, changed, settingKey)
    local value = initialValue
    local dragging = false
    local row = create("Frame", Content, {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    })
    addCorner(row, 12)
    local rowStroke = addStroke(row, themeColor(), 1, 0.82)
    local rowGradient = addLiquidGradient(row, 8)
    addLiquidHover(row, 0.4, 0.3)
    local label = create("TextLabel", row, {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(224, 229, 241),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local track = create("TextButton", row, {
        Size = UDim2.new(1, -20, 0, 8),
        Position = UDim2.new(0, 10, 0, 38),
        BackgroundColor3 = Color3.fromRGB(8, 11, 18),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    addCorner(track, 5)
    local fill = create("Frame", track, {
        BackgroundColor3 = themeColor(),
        BorderSizePixel = 0,
    })
    addCorner(fill, 5)
    local knob = create("Frame", track, {
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(248, 249, 255),
        BorderSizePixel = 0,
    })
    addCorner(knob, 8)
    local knobStroke = addStroke(knob, themeColor(), 1.5, 0.12)

    local function formattedValue()
        if decimals == 0 then
            return tostring(math.floor(value + 0.5))
        end
        return string.format("%." .. tostring(decimals) .. "f", value)
    end

    local function redraw(color)
        color = color or themeColor()
        local fraction = math.clamp((value - minimum) / (maximum - minimum), 0, 1)
        label.Text = "  " .. text .. formattedValue()
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        knob.Position = UDim2.new(fraction, 7 - fraction * 14, 0.5, 0)
        fill.BackgroundColor3 = color
        knobStroke.Color = color
        rowStroke.Color = color
        rowGradient.Color = liquidColors(color, 0.9)
    end

    local function setFromX(mouseX)
        local fraction = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = minimum + (maximum - minimum) * fraction
        if decimals == 0 then
            value = math.floor(raw + 0.5)
        else
            local scale = 10 ^ decimals
            value = math.floor(raw * scale + 0.5) / scale
        end
        redraw()
        changed(value)
        queueAutoSave()
    end

    local function setValue(newValue)
        local raw = math.clamp(newValue, minimum, maximum)
        if decimals == 0 then
            value = math.floor(raw + 0.5)
        else
            local scale = 10 ^ decimals
            value = math.floor(raw * scale + 0.5) / scale
        end
        redraw()
        changed(value)
        queueAutoSave()
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            setFromX(UserInputService:GetMouseLocation().X)
        end
    end)

    registerRefresh(redraw)
    if settingKey then
        ConfigControls[settingKey] = setValue
    end
    return row, setValue
end

local function addTextInput(labelText, initialValue, changed, settingKey, placeholderText)
    local row = create("Frame", Content, {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = Color3.fromRGB(24, 28, 39),
        BackgroundTransparency = 0.38,
        BorderSizePixel = 0,
    })
    addCorner(row, 12)
    local rowStroke = addStroke(row, themeColor(), 1, 0.78)
    local rowGradient = addLiquidGradient(row, 8)
    addLiquidHover(row, 0.38, 0.26)

    create("TextLabel", row, {
        Size = UDim2.new(1, -20, 0, 23),
        Position = UDim2.new(0, 10, 0, 3),
        BackgroundTransparency = 1,
        Text = "  " .. labelText,
        TextColor3 = Color3.fromRGB(224, 229, 241),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local box = create("TextBox", row, {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 29),
        BackgroundColor3 = Color3.fromRGB(8, 11, 18),
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        Text = tostring(initialValue or ""),
        PlaceholderText = placeholderText or "Enter value",
        PlaceholderColor3 = Color3.fromRGB(118, 124, 141),
        TextColor3 = Color3.fromRGB(238, 241, 249),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    addCorner(box, 9)
    local boxStroke = addStroke(box, themeColor(), 1, 0.68)

    local function clean(value)
        value = tostring(value or ""):gsub("[%c\r\n]", " ")
        value = value:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        return value:sub(1, 120)
    end

    local function setValue(value)
        value = clean(value)
        box.Text = value
        changed(value)
        queueAutoSave()
    end

    box.FocusLost:Connect(function()
        setValue(box.Text)
    end)
    registerRefresh(function(color)
        color = color or themeColor()
        rowStroke.Color = color
        boxStroke.Color = color
        rowGradient.Color = liquidColors(color, 0.88)
    end)
    if settingKey then ConfigControls[settingKey] = setValue end
    return row, setValue
end

local function addColorPicker()
    local pickerCard = create("Frame", Content, {
        Size = UDim2.new(1, 0, 0, 190),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    })
    addCorner(pickerCard, 12)
    local cardStroke = addStroke(pickerCard, themeColor(), 1, 0.7)
    local cardGradient = addLiquidGradient(pickerCard, 8)

    local title = create("TextLabel", pickerCard, {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = "  ACCENT COLOR",
        TextColor3 = Color3.fromRGB(230, 235, 246),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local wheel = create("ImageButton", pickerCard, {
        Name = "ColorWheel",
        Size = UDim2.new(0, 140, 0, 140),
        Position = UDim2.new(0, 10, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "rbxassetid://6020299385",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
    })

    local wheelCursor = create("Frame", wheel, {
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    addCorner(wheelCursor, 8)
    addStroke(wheelCursor, Color3.fromRGB(5, 7, 12), 2, 0.1)

    local brightness = create("TextButton", pickerCard, {
        Name = "Brightness",
        Size = UDim2.new(0, 22, 0, 140),
        Position = UDim2.new(0, 160, 0, 36),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    addCorner(brightness, 11)
    local brightnessGradient = create("UIGradient", brightness, {
        Rotation = 90,
    })
    local brightnessCursor = create("Frame", brightness, {
        Size = UDim2.new(1, 8, 0, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    addCorner(brightnessCursor, 4)
    addStroke(brightnessCursor, Color3.fromRGB(5, 7, 12), 1, 0.15)

    local preview = create("Frame", pickerCard, {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 194, 0, 42),
        BackgroundColor3 = themeColor(),
        BorderSizePixel = 0,
    })
    addCorner(preview, 22)
    local previewStroke = addStroke(preview, Color3.fromRGB(255, 255, 255), 2, 0.28)

    local hexLabel = create("TextLabel", pickerCard, {
        Size = UDim2.new(0, 64, 0, 24),
        Position = UDim2.new(0, 184, 0, 100),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(225, 230, 242),
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    create("TextLabel", pickerCard, {
        Size = UDim2.new(0, 64, 0, 40),
        Position = UDim2.new(0, 184, 0, 128),
        BackgroundTransparency = 1,
        Text = "DRAG\nTO PICK",
        TextColor3 = Color3.fromRGB(145, 153, 172),
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
    })

    local hue, saturation, brightnessValue = Color3.toHSV(themeColor())
    local wheelDragging = false
    local brightnessDragging = false
    local activeWheelTouch
    local activeBrightnessTouch
    local atan2 = math.atan2 or math.atan

    local function redrawPicker()
        local visualHue = (hue - 0.5) % 1
        local angle = visualHue * math.pi * 2
        local radius = saturation * 0.5
        wheelCursor.Position = UDim2.new(
            0.5 + math.cos(angle) * radius,
            0,
            0.5 - math.sin(angle) * radius,
            0
        )
        brightnessCursor.Position = UDim2.new(0.5, 0, 1 - brightnessValue, 0)
        local fullBrightness = Color3.fromHSV(hue, saturation, 1)
        brightnessGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, fullBrightness),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        })
        local color = Color3.fromHSV(hue, saturation, brightnessValue)
        preview.BackgroundColor3 = color
        hexLabel.Text = string.format(
            "#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
    end

    local function applyPickerColor()
        local color = Color3.fromHSV(hue, saturation, brightnessValue)
        Settings.Red = math.floor(color.R * 255 + 0.5)
        Settings.Green = math.floor(color.G * 255 + 0.5)
        Settings.Blue = math.floor(color.B * 255 + 0.5)
        redrawPicker()
        refreshTheme()
        queueAutoSave()
    end

    local function setFromSettings()
        hue, saturation, brightnessValue = Color3.toHSV(Color3.fromRGB(
            Settings.Red,
            Settings.Green,
            Settings.Blue
        ))
        redrawPicker()
        refreshTheme()
    end

    local function updateWheel(position)
        local center = wheel.AbsolutePosition + wheel.AbsoluteSize / 2
        local topLeftInset = ScreenGui.IgnoreGuiInset and Vector2.new(0, 0) or GuiService:GetGuiInset()
        local guiPosition = Vector2.new(
            position.X - topLeftInset.X,
            position.Y - topLeftInset.Y
        )
        local offset = guiPosition - center
        local radius = wheel.AbsoluteSize.X / 2
        local distance = math.min(offset.Magnitude, radius)
        saturation = math.clamp(distance / radius, 0, 1)
        hue = (atan2(-offset.Y, offset.X) / (math.pi * 2) + 0.5) % 1
        applyPickerColor()
    end

    local function updateBrightness(position)
        local topLeftInset = ScreenGui.IgnoreGuiInset and Vector2.new(0, 0) or GuiService:GetGuiInset()
        local fraction = math.clamp(
            (position.Y - topLeftInset.Y - brightness.AbsolutePosition.Y) / brightness.AbsoluteSize.Y,
            0,
            1
        )
        brightnessValue = 1 - fraction
        applyPickerColor()
    end

    wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            wheelDragging = true
            updateWheel(UserInputService:GetMouseLocation())
        elseif input.UserInputType == Enum.UserInputType.Touch then
            activeWheelTouch = input
            updateWheel(input.Position)
        end
    end)
    brightness.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            brightnessDragging = true
            updateBrightness(UserInputService:GetMouseLocation())
        elseif input.UserInputType == Enum.UserInputType.Touch then
            activeBrightnessTouch = input
            updateBrightness(input.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if wheelDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateWheel(UserInputService:GetMouseLocation())
        elseif input == activeWheelTouch then
            updateWheel(input.Position)
        end

        if brightnessDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateBrightness(UserInputService:GetMouseLocation())
        elseif input == activeBrightnessTouch then
            updateBrightness(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            wheelDragging = false
            brightnessDragging = false
        end
        if input == activeWheelTouch then activeWheelTouch = nil end
        if input == activeBrightnessTouch then activeBrightnessTouch = nil end
    end)

    ConfigControls.Red = setFromSettings
    ConfigControls.Green = setFromSettings
    ConfigControls.Blue = setFromSettings
    registerRefresh(function(color)
        color = color or themeColor()
        cardStroke.Color = color
        cardGradient.Color = liquidColors(color, 0.9)
        previewStroke.Color = color:Lerp(Color3.fromRGB(255, 255, 255), 0.45)
    end)
    redrawPicker()
    return pickerCard, setFromSettings
end

addSection("--- KEYBINDS ---")

local waitingForBindingSetting
local BindKeyButtons = {}
local BindModeButtons = {}
local BindLabels = {}

local function bindingDisplay(binding)
    local name = binding and binding.Name or "None"
    local aliases = {
        MouseButton1 = "M1",
        MouseButton2 = "M2",
        MouseButton3 = "M3",
    }
    return aliases[name] or name
end

local keyButton = create("TextButton", Content, {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(24, 28, 39),
    BackgroundTransparency = 0.38,
    BorderSizePixel = 0,
    Text = "   Toggle Menu: [" .. bindingDisplay(Settings.MenuKey) .. "]",
    TextColor3 = Color3.fromRGB(232, 236, 246),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    AutoButtonColor = false,
})
addCorner(keyButton, 12)
local KeyButtonStroke = addStroke(keyButton, themeColor(), 1, 0.78)
addLiquidHover(keyButton, 0.38, 0.24)
registerRefresh(function(color) KeyButtonStroke.Color = color or themeColor() end)
keyButton.MouseButton1Click:Connect(function()
    waitingForBindingSetting = "MenuKey"
    keyButton.Text = "   Press any key or mouse button..."
end)
BindKeyButtons.MenuKey = keyButton
BindLabels.MenuKey = "Toggle Menu"

local function addBindControl(label, bindingSetting, modeSetting)
    local row = create("Frame", Content, {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    local bindButton = create("TextButton", row, {
        Size = UDim2.new(0.68, -3, 1, 0),
        BackgroundColor3 = Color3.fromRGB(24, 28, 39),
        BackgroundTransparency = 0.38,
        BorderSizePixel = 0,
        Text = "   " .. label .. ": [" .. bindingDisplay(Settings[bindingSetting]) .. "]",
        TextColor3 = Color3.fromRGB(232, 236, 246),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    local modeButton = create("TextButton", row, {
        Size = UDim2.new(0.32, -3, 1, 0),
        Position = UDim2.new(0.68, 3, 0, 0),
        BackgroundColor3 = Color3.fromRGB(24, 28, 39),
        BackgroundTransparency = 0.38,
        BorderSizePixel = 0,
        Text = string.upper(Settings[modeSetting]),
        TextColor3 = themeColor(),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })
    addCorner(bindButton, 12)
    addCorner(modeButton, 12)
    local bindStroke = addStroke(bindButton, themeColor(), 1, 0.78)
    local modeStroke = addStroke(modeButton, themeColor(), 1, 0.62)
    addLiquidGradient(bindButton, 8)
    addLiquidGradient(modeButton, 8)
    addLiquidHover(bindButton, 0.38, 0.24)
    addLiquidHover(modeButton, 0.38, 0.24)
    registerRefresh(function(color)
        color = color or themeColor()
        bindStroke.Color = color
        modeStroke.Color = color
        modeButton.TextColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), 0.78)
    end)

    local function setMode(value)
        local mode = value == "Hold" and "Hold" or "Toggle"
        Settings[modeSetting] = mode
        modeButton.Text = string.upper(mode)
        if modeSetting == "TeleportBindMode" then
            TeleportBindHeld = false
            TeleportBindToggled = false
            nextTeleportBindAt = 0
        elseif modeSetting == "AimbotBindMode" then
            AimbotBindHeld = false
        elseif modeSetting == "TriggerbotBindMode" then
            TriggerbotBindHeld = false
        elseif modeSetting == "NoclipBindMode" then
            local state = RuntimeEnvironment.uorkeeMovementState
            if state then state.NoclipHeld = false end
        elseif modeSetting == "SpeedBindMode" then
            local state = RuntimeEnvironment.uorkeeMovementState
            if state then state.SpeedHeld = false end
        end
        queueAutoSave()
    end

    bindButton.MouseButton1Click:Connect(function()
        waitingForBindingSetting = bindingSetting
        bindButton.Text = "   Press any key or mouse button..."
    end)
    modeButton.MouseButton1Click:Connect(function()
        setMode(Settings[modeSetting] == "Hold" and "Toggle" or "Hold")
    end)

    BindKeyButtons[bindingSetting] = bindButton
    BindModeButtons[modeSetting] = modeButton
    BindLabels[bindingSetting] = label
    ConfigControls[modeSetting] = setMode
    return row
end

addBindControl("Teleport", "TeleportKey", "TeleportBindMode")
addBindControl("Aimbot", "AimbotKey", "AimbotBindMode")
addBindControl("Triggerbot", "TriggerbotKey", "TriggerbotBindMode")
addBindControl("Noclip", "NoclipKey", "NoclipBindMode")
addBindControl("Speed", "SpeedKey", "SpeedBindMode")

refreshKeyButtons = function()
    for settingKey, button in pairs(BindKeyButtons) do
        button.Text = "   " .. BindLabels[settingKey] .. ": ["
            .. bindingDisplay(Settings[settingKey]) .. "]"
    end
    for settingKey, button in pairs(BindModeButtons) do
        button.Text = string.upper(Settings[settingKey])
    end
end

local function addAction(text, callback)
    local button = create("TextButton", Content, {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(24, 28, 39),
        BackgroundTransparency = 0.34,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(236, 240, 249),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })
    addCorner(button, 12)
    local stroke = addStroke(button, themeColor(), 1, 0.62)
    addLiquidHover(button, 0.34, 0.18)
    registerRefresh(function(color)
        stroke.Color = color or themeColor()
    end)
    button.MouseButton1Click:Connect(callback)
    return button
end

Content = MenuUI.Pages.combat
addToggle("Team Check", Settings.TeamCheck, function(value)
    Settings.TeamCheck = value
end, "TeamCheck")

Content = MenuUI.Pages.movement
addSection("--- MOVEMENT ---")
addToggle("Noclip", Settings.NoclipEnabled, function(value)
    Settings.NoclipEnabled = value
end, "NoclipEnabled")
addToggle("Speed Boost", Settings.SpeedEnabled, function(value)
    Settings.SpeedEnabled = value
end, "SpeedEnabled")
addSlider("Walk Speed: ", 16, 100, Settings.SpeedValue, 0, function(value)
    Settings.SpeedValue = value
end, "SpeedValue")
addToggle("Infinite Jump", Settings.InfiniteJumpEnabled, function(value)
    Settings.InfiniteJumpEnabled = value
end, "InfiniteJumpEnabled")
addToggle("Fake Lag" .. (SetHiddenProperty and "" or " [unsupported]"), Settings.FakeLagEnabled, function(value)
    Settings.FakeLagEnabled = value
end, "FakeLagEnabled")
addSlider("Fake Lag Hold: ", 0.05, 0.8, Settings.FakeLagHold, 2, function(value)
    Settings.FakeLagHold = value
end, "FakeLagHold")
addSlider("Fake Lag Release: ", 0.01, 0.2, Settings.FakeLagRelease, 2, function(value)
    Settings.FakeLagRelease = value
end, "FakeLagRelease")

Content = MenuUI.Pages.visuals
addSection("--- ESP SETTINGS ---")
addToggle("Enable ESP", Settings.ESPEnabled, function(value) Settings.ESPEnabled = value end, "ESPEnabled")
addToggle("Names ESP", Settings.NamesESP, function(value) Settings.NamesESP = value end, "NamesESP")
addSection("--- DEATH STATUE ---")
addToggle("Neon Statue On Death", Settings.DeathStatueEnabled, function(value)
    Settings.DeathStatueEnabled = value
end, "DeathStatueEnabled")
addTextInput("Statue Text", Settings.DeathStatueText, function(value)
    Settings.DeathStatueText = value
end, "DeathStatueText", "Use {player} for the player's name")

Content = MenuUI.Pages.combat
addSection("--- AIMBOT SETTINGS / 360 TARGETING ---")
addToggle("Enable Aimbot", Settings.AimbotEnabled, function(value) Settings.AimbotEnabled = value end, "AimbotEnabled")
addToggle("Auto LMB (Triggerbot)", Settings.TriggerbotEnabled, function(value)
    Settings.TriggerbotEnabled = value
end, "TriggerbotEnabled")

Content = MenuUI.Pages.audio
addSection("--- HIT FEEDBACK ---")
addToggle("XP Orb Hit Sound", Settings.HitSoundEnabled, function(value)
    Settings.HitSoundEnabled = value
end, "HitSoundEnabled")
addSlider("Hit Sound Volume: ", 0, 1, Settings.HitSoundVolume, 2, function(value)
    Settings.HitSoundVolume = value
end, "HitSoundVolume")
addSlider("Hit Sound Pitch: ", 0.55, 1.25, Settings.HitSoundPitch, 2, function(value)
    Settings.HitSoundPitch = value
end, "HitSoundPitch")
addToggle("Use Custom Hit Sound (OFF = Default)", Settings.HitSoundUseCustom, function(value)
    Settings.HitSoundUseCustom = value
end, "HitSoundUseCustom")
addTextInput("Custom Sound ID", Settings.HitSoundCustomId, function(value)
    Settings.HitSoundCustomId = value
end, "HitSoundCustomId", "Example: 123456789 or rbxassetid://123456789")
addSection("--- ROUND VICTORY MUSIC ---")
addToggle("Play Music When All Enemies Are Dead", Settings.VictoryMusicEnabled, function(value)
    Settings.VictoryMusicEnabled = value
    if not value and stopVictoryMusic then stopVictoryMusic(false) end
    if value and requestVictoryMusicEvaluation then task.defer(requestVictoryMusicEvaluation) end
end, "VictoryMusicEnabled")
addSlider("Victory Music Volume: ", 0, 1, Settings.VictoryMusicVolume, 2, function(value)
    Settings.VictoryMusicVolume = value
    if updateVictoryMusicVolume then updateVictoryMusicVolume(value) end
end, "VictoryMusicVolume")
for slot = 1, 5 do
    local slotNumber = slot
    local settingKey = "VictoryMusicId" .. tostring(slot)
    local offsetKey = "VictoryMusicStartOffset" .. tostring(slot)
    addTextInput("Victory Song " .. tostring(slot) .. " ID", Settings[settingKey], function(value)
        Settings[settingKey] = value
        if requestVictoryMusicEvaluation then task.defer(requestVictoryMusicEvaluation) end
    end, settingKey, "Optional Roblox audio ID")
    addSlider("Song " .. tostring(slot) .. " Start (seconds): ", 0, 300, Settings[offsetKey], 1, function(value)
        Settings[offsetKey] = value
        if updateVictoryMusicOffset then updateVictoryMusicOffset(slotNumber, value) end
    end, offsetKey)
    addAction("Preview / Stop Song " .. tostring(slot), function()
        local preview = RuntimeEnvironment.uorkeePreviewVictoryMusic
        if preview then preview(slotNumber) end
    end)
end

Content = MenuUI.Pages.combat
addSection("--- TARGETING ---")
addToggle("Wall Check", Settings.WallCheck, function(value) Settings.WallCheck = value end, "WallCheck")
addToggle("Show FOV", Settings.ShowFOV, function(value)
    Settings.ShowFOV = value
    FOVCircle.Visible = value
end, "ShowFOV")
addToggle("Rainbow FOV", Settings.RainbowFOV, function(value) Settings.RainbowFOV = value end, "RainbowFOV")

addSlider("FOV Circle Radius (visual): ", 50, 2000, Settings.FOVRadius, 0, function(value)
    Settings.FOVRadius = value
    FOVCircle.Radius = value
end, "FOVRadius")
addSlider("Aim Speed (1=Legit, 10=Rage): ", 1, 10, Settings.AimSpeed, 0, function(value)
    Settings.AimSpeed = value
end, "AimSpeed")
Content = MenuUI.Pages.theme
addSection("--- LIQUID GLASS THEME ---")
addSlider("Glass Transparency: ", 0, 1, Settings.MenuOpacity, 1, function(value)
    Settings.MenuOpacity = value
    Main.BackgroundTransparency = menuTransparency()
end, "MenuOpacity")
addColorPicker()
addSection("--- WORLD AMBIENT ---")
addToggle("Ambient Mode (Tint + Air Particles)", Settings.AmbientModeEnabled, function(value)
    Settings.AmbientModeEnabled = value
    local setter = RuntimeEnvironment.uorkeeSetAmbientMode
    if setter then setter(value) end
end, "AmbientModeEnabled")
addSlider("Ambient Tint Strength: ", 0.05, 0.4, Settings.AmbientTintStrength, 2, function(value)
    Settings.AmbientTintStrength = value
    local updater = RuntimeEnvironment.uorkeeUpdateAmbient
    if updater then updater() end
end, "AmbientTintStrength")
addSlider("Ambient Particle Density: ", 10, 60, Settings.AmbientParticleRate, 0, function(value)
    Settings.AmbientParticleRate = value
    local updater = RuntimeEnvironment.uorkeeUpdateAmbient
    if updater then updater() end
end, "AmbientParticleRate")

Content = MenuUI.Pages.configs
addSection("--- CONFIGS ---")
local ConfigNameBox = create("TextBox", Content, {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(24, 28, 39),
    BackgroundTransparency = 0.34,
    BorderSizePixel = 0,
    Text = ConfigState.ActiveConfig,
    PlaceholderText = "Config name",
    ClearTextOnFocus = false,
    TextColor3 = Color3.fromRGB(235, 235, 235),
    PlaceholderColor3 = Color3.fromRGB(135, 135, 135),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
})
addCorner(ConfigNameBox, 12)
local ConfigNameStroke = addStroke(ConfigNameBox, themeColor(), 1, 0.62)
registerRefresh(function(color)
    ConfigNameStroke.Color = color or themeColor()
end)

local function selectedConfigName()
    local name = sanitizeConfigName(ConfigNameBox.Text)
    ConfigNameBox.Text = name
    return name
end

ConfigNameBox.FocusLost:Connect(function()
    selectedConfigName()
end)

addToggle("Auto Save", ConfigState.AutoSave, function(value)
    ConfigState.AutoSave = value
    local success, stateError = saveConfigState()
    if not success then
        setConfigStatus("State save failed: " .. tostring(stateError), false)
    elseif not value then
        setConfigStatus("Auto Save disabled", true)
    else
        queueAutoSave()
        setConfigStatus("Auto Save enabled: default", true)
    end
end)

addSection("--- LOAD SCOPE ---")
ConfigState.LoadSectionButton = addAction(
    "Load Mode: " .. RuntimeEnvironment.uorkeeConfigSectionLabels[ConfigState.LoadSection]
        .. "  (click to change)",
    function()
        local order = RuntimeEnvironment.uorkeeConfigSectionOrder
        local currentIndex = 1
        for index, sectionName in ipairs(order) do
            if sectionName == ConfigState.LoadSection then
                currentIndex = index
                break
            end
        end
        ConfigState.LoadSection = order[currentIndex % #order + 1]
        ConfigState.LoadSectionButton.Text = "Load Mode: "
            .. RuntimeEnvironment.uorkeeConfigSectionLabels[ConfigState.LoadSection]
            .. "  (click to change)"
        saveConfigState()
        setConfigStatus("Load mode: "
            .. RuntimeEnvironment.uorkeeConfigSectionLabels[ConfigState.LoadSection], true)
    end
)

addAction("Save Config", function()
    local name = selectedConfigName()
    local success, saveError = saveConfig(name)
    if success then
        saveConfigState()
        setConfigStatus("Saved preset: " .. name .. " (Auto Save -> default)", true)
    else
        setConfigStatus("Save failed: " .. tostring(saveError), false)
    end
end)

addAction("Load Config / Selected Section", function()
    local name = selectedConfigName()
    local sectionName = ConfigState.LoadSection ~= "All" and ConfigState.LoadSection or nil
    local success, loadError = loadConfig(name, true, sectionName)
    if success then
        ConfigState.ActiveConfig = "default"
        ConfigNameBox.Text = "default"
        saveConfigState()
        queueAutoSave()
        if sectionName then
            setConfigStatus(
                "Imported " .. RuntimeEnvironment.uorkeeConfigSectionLabels[sectionName]
                    .. " from " .. name .. " into default",
                true
            )
        else
            setConfigStatus("Loaded all from " .. name .. " into default", true)
        end
    else
        setConfigStatus("Load failed: " .. tostring(loadError), false)
    end
end)

addAction("Delete Config", function()
    local name = selectedConfigName()
    if name == "default" then
        setConfigStatus("Default is universal and cannot be deleted", false)
        return
    end
    if type(DeleteFile) ~= "function" then
        setConfigStatus("Delete API unavailable", false)
        return
    end
    local path = configPath(name)
    if not fileExists(path) then
        setConfigStatus("Config not found: " .. name, false)
        return
    end
    local success, deleteError = pcall(DeleteFile, path)
    if not success then
        setConfigStatus("Delete failed: " .. tostring(deleteError), false)
        return
    end
    setConfigStatus("Deleted: " .. name, true)
end)

ConfigStatusLabel = create("TextLabel", Content, {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1,
    Text = type(ReadFile) == "function" and type(WriteFile) == "function"
        and " Config system ready"
        or " Config filesystem unsupported",
    TextColor3 = type(ReadFile) == "function" and type(WriteFile) == "function"
        and Color3.fromRGB(180, 235, 180)
        or Color3.fromRGB(255, 115, 115),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
})

RuntimeEnvironment.uorkeeAmbientState = {
    Alive = true,
    Lighting = game:GetService("Lighting"),
}
RuntimeEnvironment.uorkeeAmbientState.ColorEffect = create(
    "ColorCorrectionEffect",
    RuntimeEnvironment.uorkeeAmbientState.Lighting,
    {
        Name = "uorkeeAmbientColor",
        Enabled = false,
        TintColor = Color3.new(1, 1, 1),
        Brightness = 0.018,
        Contrast = 0.025,
        Saturation = 0.075,
    }
)
RuntimeEnvironment.uorkeeAmbientState.ParticlePart = create("Part", workspace, {
    Name = "uorkeeAmbientParticles",
    Anchored = true,
    CanCollide = false,
    CanQuery = false,
    CanTouch = false,
    CastShadow = false,
    Transparency = 1,
    Size = Vector3.new(54, 28, 54),
    CFrame = Camera and Camera.CFrame or CFrame.new(),
})
RuntimeEnvironment.uorkeeAmbientState.Emitter = create(
    "ParticleEmitter",
    RuntimeEnvironment.uorkeeAmbientState.ParticlePart,
    {
        Name = "AmbientDust",
        Enabled = false,
        Texture = "rbxasset://textures/particles/sparkles_main.dds",
        Rate = Settings.AmbientParticleRate,
        Color = ColorSequence.new(themeColor():Lerp(Color3.new(1, 1, 1), 0.42), themeColor()),
        LightEmission = 0.82,
        LightInfluence = 0,
        EmissionDirection = Enum.NormalId.Top,
        SpreadAngle = Vector2.new(180, 180),
        Rotation = NumberRange and NumberRange.new(0, 360) or nil,
        RotSpeed = NumberRange and NumberRange.new(-18, 18) or nil,
        Shape = Enum.ParticleEmitterShape.Box,
        ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
        ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
        ZOffset = -0.15,
    }
)
RuntimeEnvironment.uorkeeAmbientState.GlowEmitter = create(
    "ParticleEmitter",
    RuntimeEnvironment.uorkeeAmbientState.ParticlePart,
    {
        Name = "AmbientGlow",
        Enabled = false,
        Texture = "rbxasset://textures/particles/flare_main.dds",
        Rate = math.max(4, Settings.AmbientParticleRate * 0.24),
        Color = ColorSequence.new(themeColor():Lerp(Color3.new(1, 1, 1), 0.62), themeColor()),
        LightEmission = 0.92,
        LightInfluence = 0,
        EmissionDirection = Enum.NormalId.Top,
        SpreadAngle = Vector2.new(180, 180),
        Rotation = NumberRange and NumberRange.new(0, 360) or nil,
        RotSpeed = NumberRange and NumberRange.new(-9, 9) or nil,
        Shape = Enum.ParticleEmitterShape.Box,
        ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
        ShapeInOut = Enum.ParticleEmitterShapeInOut.InAndOut,
        ZOffset = -0.2,
    }
)
pcall(function()
    local emitter = RuntimeEnvironment.uorkeeAmbientState.Emitter
    emitter.Lifetime = NumberRange.new(5, 8)
    emitter.Speed = NumberRange.new(0.18, 0.55)
    emitter.Drag = 0.3
    emitter.Acceleration = Vector3.new(0, 0.2, 0)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.045),
        NumberSequenceKeypoint.new(0.22, 0.23),
        NumberSequenceKeypoint.new(0.78, 0.14),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.16, 0.2),
        NumberSequenceKeypoint.new(0.8, 0.42),
        NumberSequenceKeypoint.new(1, 1),
    })

    local glow = RuntimeEnvironment.uorkeeAmbientState.GlowEmitter
    glow.Lifetime = NumberRange.new(4.5, 7.5)
    glow.Speed = NumberRange.new(0.06, 0.24)
    glow.Drag = 0.38
    glow.Acceleration = Vector3.new(0, 0.08, 0)
    glow.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.22, 0.36),
        NumberSequenceKeypoint.new(0.72, 0.25),
        NumberSequenceKeypoint.new(1, 0),
    })
    glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.24, 0.46),
        NumberSequenceKeypoint.new(0.74, 0.62),
        NumberSequenceKeypoint.new(1, 1),
    })
end)

RuntimeEnvironment.uorkeeSetAmbientMode = function(enabled)
    local state = RuntimeEnvironment.uorkeeAmbientState
    if not state or not state.Alive then return end
    state.Enabled = enabled == true
    if state.ColorEffect then state.ColorEffect.Enabled = state.Enabled end
    if state.Emitter then
        state.Emitter.Enabled = state.Enabled
        if state.Enabled then pcall(function() state.Emitter:Emit(24) end) end
    end
    if state.GlowEmitter then
        state.GlowEmitter.Enabled = state.Enabled
        if state.Enabled then pcall(function() state.GlowEmitter:Emit(8) end) end
    end
end
RuntimeEnvironment.uorkeeAmbientState.SetEnabled = RuntimeEnvironment.uorkeeSetAmbientMode

RuntimeEnvironment.uorkeeUpdateAmbient = function(color)
    local state = RuntimeEnvironment.uorkeeAmbientState
    if not state or not state.Alive then return end
    color = color or themeColor()
    local strength = math.clamp(Settings.AmbientTintStrength, 0.05, 0.4)
    if state.ColorEffect then
        state.ColorEffect.TintColor = Color3.new(1, 1, 1):Lerp(color, strength)
        state.ColorEffect.Saturation = 0.045 + strength * 0.14
    end
    if state.Emitter then
        state.Emitter.Rate = Settings.AmbientParticleRate
        state.Emitter.Color = ColorSequence.new(
            color:Lerp(Color3.new(1, 1, 1), 0.52),
            color:Lerp(Color3.new(1, 1, 1), 0.04)
        )
    end
    if state.GlowEmitter then
        state.GlowEmitter.Rate = math.max(4, Settings.AmbientParticleRate * 0.24)
        state.GlowEmitter.Color = ColorSequence.new(
            color:Lerp(Color3.new(1, 1, 1), 0.7),
            color:Lerp(Color3.new(1, 1, 1), 0.16)
        )
    end
end
RuntimeEnvironment.uorkeeAmbientState.Update = RuntimeEnvironment.uorkeeUpdateAmbient
registerRefresh(RuntimeEnvironment.uorkeeUpdateAmbient)

RunService:UnbindFromRenderStep("uorkeeAmbientMode")
RunService:BindToRenderStep("uorkeeAmbientMode", Enum.RenderPriority.Camera.Value + 5, function()
    local state = RuntimeEnvironment.uorkeeAmbientState
    if not state or not state.Alive or not state.Enabled or not state.ParticlePart then return end
    local currentCamera = workspace.CurrentCamera
    if currentCamera then
        state.ParticlePart.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -11)
    end
end)

RuntimeEnvironment.uorkeeAmbientModeCleanup = function()
    local state = RuntimeEnvironment.uorkeeAmbientState
    if not state then return end
    state.Alive = false
    pcall(function() RunService:UnbindFromRenderStep("uorkeeAmbientMode") end)
    if state.ColorEffect then pcall(function() state.ColorEffect:Destroy() end) end
    if state.ParticlePart then pcall(function() state.ParticlePart:Destroy() end) end
    if RuntimeEnvironment.uorkeeSetAmbientMode == state.SetEnabled then
        RuntimeEnvironment.uorkeeSetAmbientMode = nil
    end
    if RuntimeEnvironment.uorkeeUpdateAmbient == state.Update then
        RuntimeEnvironment.uorkeeUpdateAmbient = nil
    end
    if RuntimeEnvironment.uorkeeAmbientState == state then
        RuntimeEnvironment.uorkeeAmbientState = nil
        RuntimeEnvironment.uorkeeAmbientModeCleanup = nil
    end
end
RuntimeEnvironment.uorkeeSetAmbientMode(Settings.AmbientModeEnabled)

local PlayerESP = {}
local stopped = false
local MainInputConnection
local MainInputEndedConnection

local function createPlayerESP(player)
    if player == LocalPlayer or PlayerESP[player] then
        return
    end
    PlayerESP[player] = {}
end

local function hidePlayerESP(data)
    for _, object in ipairs({data.Highlight, data.HeadBillboard, data.NameBillboard}) do
        if object then
            pcall(function() object.Enabled = false end)
        end
    end
end

local function clearPlayerESP(data)
    for _, object in ipairs({data.Highlight, data.HeadBillboard, data.NameBillboard}) do
        if object then
            pcall(function() object:Destroy() end)
        end
    end
    data.Character = nil
    data.Highlight = nil
    data.HeadBillboard = nil
    data.HeadRingStroke = nil
    data.NameBillboard = nil
    data.NameLabel = nil
end

local function removePlayerESP(player)
    local data = PlayerESP[player]
    if not data then return end
    clearPlayerESP(data)
    PlayerESP[player] = nil
end

local function teamIDByte(player)
    if not player then return nil end
    local value = player:GetAttribute("TeamID")
    if type(value) == "string" and #value > 0 then
        return string.byte(value, 1)
    end
    if type(value) == "number" then
        return value
    end
    return nil
end

local function detectedSameTeam(player)
    if not player then
        return false
    end

    -- This game stores its actual side as a one-byte TeamID string. Compare
    -- against the local byte instead of hard-coding which byte is friendly,
    -- because the assigned side can change between rounds.
    local localTeamByte = teamIDByte(LocalPlayer)
    local otherTeamByte = teamIDByte(player)
    if localTeamByte ~= nil or otherTeamByte ~= nil then
        return localTeamByte ~= nil
            and otherTeamByte ~= nil
            and localTeamByte == otherTeamByte
    end

    -- Fallbacks used by games which implement teams without Player.Team.
    for _, key in ipairs({"Team", "TeamName", "Faction", "Squad", "Side"}) do
        local localValue = LocalPlayer:GetAttribute(key)
        local otherValue = player:GetAttribute(key)
        local valueType = type(localValue)
        local comparable = (valueType == "string" and localValue ~= "")
            or valueType == "number"
        if comparable and type(otherValue) == valueType and localValue == otherValue then
            return true
        end
    end

    -- Neutral players all report the same default white TeamColor, so it must
    -- never be treated as proof that they are allies.
    if LocalPlayer.Neutral or player.Neutral then
        return false
    end
    if LocalPlayer.Team ~= nil and player.Team ~= nil then
        return LocalPlayer.Team == player.Team
    end
    if LocalPlayer.TeamColor ~= nil and player.TeamColor ~= nil then
        return LocalPlayer.TeamColor == player.TeamColor
    end
    return false
end

local function sameTeam(player)
    return Settings.TeamCheck and detectedSameTeam(player) or false
end

local function characterInfo(player)
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    return character, root, humanoid
end

-- Local hit feedback. The built-in electronic ping is pitched like an XP-orb
-- pickup, so it does not depend on a third-party Roblox audio asset being public.
local HitSoundAlive = true
local ActiveHitSounds = {}
local LastAttackInputAt = -math.huge
local HitSoundAttackHeld = false
local LastHitSoundAt = -math.huge
local DEFAULT_HIT_SOUND_ID = "rbxassetid://118671160608385"

local function selectedHitSoundId()
    if not Settings.HitSoundUseCustom then
        return DEFAULT_HIT_SOUND_ID
    end
    local digits = tostring(Settings.HitSoundCustomId or ""):match("%d+")
    if not digits or #digits > 20 then
        return DEFAULT_HIT_SOUND_ID
    end
    return "rbxassetid://" .. digits
end

local function noteLocalAttack()
    LastAttackInputAt = os.clock()
end

local function destroyHitSound(sound)
    if not sound then return end
    ActiveHitSounds[sound] = nil
    pcall(function() sound:Destroy() end)
end

local function playHitSound()
    if not HitSoundAlive or stopped or not Settings.HitSoundEnabled then return end
    if Settings.HitSoundVolume <= 0 then return end

    local now = os.clock()
    -- Shotguns and multi-part damage can replicate several health changes in
    -- one frame; keep those as one clean confirmation sound.
    if now - LastHitSoundAt < 0.035 then return end
    LastHitSoundAt = now

    local sound = create("Sound", SoundService, {
        Name = "uorkeeXPOrbHit",
        SoundId = selectedHitSoundId(),
        Volume = math.clamp(Settings.HitSoundVolume, 0, 1),
        PlaybackSpeed = math.clamp(
            Settings.HitSoundPitch + math.random(-5, 5) / 100,
            0.5,
            2
        ),
    })
    ActiveHitSounds[sound] = true

    local endedConnection
    endedConnection = sound.Ended:Connect(function()
        if endedConnection then endedConnection:Disconnect() end
        destroyHitSound(sound)
    end)
    local played = pcall(function() sound:Play() end)
    if not played then
        if endedConnection then endedConnection:Disconnect() end
        destroyHitSound(sound)
        return
    end
    task.delay(2, function()
        if endedConnection then pcall(function() endedConnection:Disconnect() end) end
        destroyHitSound(sound)
    end)
end

local function damageCreatorIsLocal(humanoid)
    for _, name in ipairs({"creator", "Creator", "attacker", "Attacker", "damager", "Damager"}) do
        local tag = humanoid:FindFirstChild(name)
        if tag and tag:IsA("ObjectValue") then
            local value = tag.Value
            if value == LocalPlayer or value == LocalPlayer.Character then
                return true
            elseif value ~= nil then
                return false
            end
        end
    end
    return nil
end

local function observeHumanoidHealth(player, record, humanoid, health)
    local numericHealth = tonumber(health)
    if not numericHealth then return end
    local previousHealth = record.hitHealth[humanoid]
    record.hitHealth[humanoid] = numericHealth
    if previousHealth == nil or numericHealth >= previousHealth - 0.01 then return end
    if player == LocalPlayer or sameTeam(player) then return end

    local creatorIsLocal = damageCreatorIsLocal(humanoid)
    local recentLocalAttack = HitSoundAttackHeld or os.clock() - LastAttackInputAt <= 1.25
    if creatorIsLocal == true or (creatorIsLocal == nil and recentLocalAttack) then
        playHitSound()
    end
end

local function cleanupHitSound()
    if not HitSoundAlive then return end
    HitSoundAlive = false
    HitSoundAttackHeld = false
    for sound in pairs(ActiveHitSounds) do
        destroyHitSound(sound)
    end
    table.clear(ActiveHitSounds)
end

RuntimeEnvironment.uorkeeHitSoundCleanup = cleanupHitSound

-- Neon death statues. Humanoid death is the primary signal, while custom
-- replicated health/state values and character removal cover games which keep
-- Humanoid.Health above zero and implement elimination themselves.
local oldStatueFolder = workspace:FindFirstChild("uorkeeDeathStatues")
if oldStatueFolder then pcall(function() oldStatueFolder:Destroy() end) end
local DeathStatueFolder = create("Folder", workspace, {Name = "uorkeeDeathStatues"})
local ActiveStatues = {}
local DeathTrackers = {}
local DeathGlobalConnections = {}
local RecentCharacterRemovals = {}
local DeathStatuesAlive = true
local VictoryMusicState = {
    Alive = true,
    Triggered = false,
}

updateVictoryMusicVolume = function(value)
    local volume = math.clamp(tonumber(value) or 0, 0, 1)
    if VictoryMusicState.Sound then
        VictoryMusicState.Sound.Volume = volume
    end
    if VictoryMusicState.PreviewSound then
        VictoryMusicState.PreviewSound.Volume = volume
    end
end

VictoryMusicState.ApplyOffset = function(sound, value)
    if not sound then return end
    local offset = math.max(tonumber(value) or 0, 0)
    local duration = tonumber(sound.TimeLength) or 0
    if duration > 0 then offset = offset % duration end
    pcall(function() sound.TimePosition = offset end)
end

updateVictoryMusicOffset = function(slot, value)
    if VictoryMusicState.Slot == slot then
        VictoryMusicState.ApplyOffset(VictoryMusicState.Sound, value)
    end
    if VictoryMusicState.PreviewSlot == slot then
        VictoryMusicState.ApplyOffset(VictoryMusicState.PreviewSound, value)
    end
end

local function normalizedAudioAssetId(value)
    local digits = tostring(value or ""):match("%d+")
    if not digits or #digits > 20 then return nil end
    return "rbxassetid://" .. digits
end

local function configuredVictoryMusicIds()
    local ids = {}
    local seen = {}
    for slot = 1, 5 do
        local id = normalizedAudioAssetId(Settings["VictoryMusicId" .. tostring(slot)])
        if id and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = {Id = id, Slot = slot}
        end
    end
    return ids
end

VictoryMusicState.StopPreview = function()
    if VictoryMusicState.PreviewLoadedConnection then
        pcall(function() VictoryMusicState.PreviewLoadedConnection:Disconnect() end)
        VictoryMusicState.PreviewLoadedConnection = nil
    end
    if VictoryMusicState.PreviewEndedConnection then
        pcall(function() VictoryMusicState.PreviewEndedConnection:Disconnect() end)
        VictoryMusicState.PreviewEndedConnection = nil
    end
    if VictoryMusicState.PreviewSound then
        pcall(function() VictoryMusicState.PreviewSound:Stop() end)
        pcall(function() VictoryMusicState.PreviewSound:Destroy() end)
        VictoryMusicState.PreviewSound = nil
    end
    VictoryMusicState.PreviewSlot = nil
end

stopVictoryMusic = function(resetTrigger)
    VictoryMusicState.StopPreview()
    if VictoryMusicState.LoadedConnection then
        pcall(function() VictoryMusicState.LoadedConnection:Disconnect() end)
        VictoryMusicState.LoadedConnection = nil
    end
    if VictoryMusicState.Sound then
        pcall(function() VictoryMusicState.Sound:Stop() end)
        pcall(function() VictoryMusicState.Sound:Destroy() end)
        VictoryMusicState.Sound = nil
    end
    VictoryMusicState.Slot = nil
    if resetTrigger ~= false then
        VictoryMusicState.Triggered = false
    end
end

VictoryMusicState.Preview = function(slot)
    slot = math.floor(tonumber(slot) or 0)
    if slot < 1 or slot > 5 then return false end
    if VictoryMusicState.PreviewSound and VictoryMusicState.PreviewSlot == slot then
        VictoryMusicState.StopPreview()
        return false
    end

    stopVictoryMusic(true)
    local id = normalizedAudioAssetId(Settings["VictoryMusicId" .. tostring(slot)])
    if not id then return false end

    local sound = create("Sound", SoundService, {
        Name = "uorkeeVictoryMusicPreview",
        SoundId = id,
        Volume = math.clamp(Settings.VictoryMusicVolume, 0, 1),
        Looped = false,
    })
    VictoryMusicState.PreviewSound = sound
    VictoryMusicState.PreviewSlot = slot
    VictoryMusicState.PreviewLoadedConnection = sound.Loaded:Connect(function()
        if VictoryMusicState.PreviewSound == sound then
            VictoryMusicState.ApplyOffset(sound, Settings["VictoryMusicStartOffset" .. tostring(slot)])
        end
    end)
    VictoryMusicState.PreviewEndedConnection = sound.Ended:Connect(function()
        if VictoryMusicState.PreviewSound == sound then
            VictoryMusicState.StopPreview()
        end
    end)
    local played = pcall(function()
        sound:Play()
        VictoryMusicState.ApplyOffset(sound, Settings["VictoryMusicStartOffset" .. tostring(slot)])
    end)
    if not played then VictoryMusicState.StopPreview() end
    return played
end

RuntimeEnvironment.uorkeePreviewVictoryMusic = VictoryMusicState.Preview

local function playVictoryMusic()
    if not VictoryMusicState.Alive or stopped or VictoryMusicState.Triggered
        or not Settings.VictoryMusicEnabled then return end

    local ids = configuredVictoryMusicIds()
    if #ids == 0 then return end
    local selectedIndex = math.random(1, #ids)
    if #ids > 1 and ids[selectedIndex].Id == VictoryMusicState.LastId then
        selectedIndex = selectedIndex % #ids + 1
    end
    local selected = ids[selectedIndex]

    stopVictoryMusic(false)
    local sound = create("Sound", SoundService, {
        Name = "uorkeeRoundVictoryMusic",
        SoundId = selected.Id,
        Volume = math.clamp(Settings.VictoryMusicVolume, 0, 1),
        Looped = true,
    })
    VictoryMusicState.Sound = sound
    VictoryMusicState.Slot = selected.Slot
    VictoryMusicState.Triggered = true
    VictoryMusicState.LastId = selected.Id
    VictoryMusicState.LoadedConnection = sound.Loaded:Connect(function()
        if VictoryMusicState.Sound == sound then
            VictoryMusicState.ApplyOffset(sound, Settings["VictoryMusicStartOffset" .. tostring(selected.Slot)])
        end
    end)
    local played = pcall(function()
        sound:Play()
        VictoryMusicState.ApplyOffset(sound, Settings["VictoryMusicStartOffset" .. tostring(selected.Slot)])
    end)
    if not played then
        stopVictoryMusic(false)
    end
end

local function allTrackedEnemiesDead()
    local enemyCount = 0
    for player, tracker in pairs(DeathTrackers) do
        if player.Parent == Players and not detectedSameTeam(player) then
            local record = tracker.current
            if record and record.character and (record.character.Parent or record.dead) then
                enemyCount = enemyCount + 1
                if not record.dead then return false end
            end
        end
    end
    return enemyCount > 0
end

local function evaluateVictoryMusic()
    if VictoryMusicState.Triggered or not Settings.VictoryMusicEnabled then return end
    if allTrackedEnemiesDead() then playVictoryMusic() end
end

requestVictoryMusicEvaluation = evaluateVictoryMusic

local function cleanupVictoryMusic()
    if not VictoryMusicState.Alive then return end
    VictoryMusicState.Alive = false
    stopVictoryMusic(false)
    if RuntimeEnvironment.uorkeePreviewVictoryMusic == VictoryMusicState.Preview then
        RuntimeEnvironment.uorkeePreviewVictoryMusic = nil
    end
end

RuntimeEnvironment.uorkeeVictoryMusicCleanup = cleanupVictoryMusic

local function disconnectAll(connections)
    for _, connection in ipairs(connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(connections or {})
end

local function prepareNeonStatue(character)
    if not character then return nil end

    local archivable = {}
    local function makeArchivable(instance)
        local ok, value = pcall(function() return instance.Archivable end)
        if ok then
            archivable[instance] = value
            pcall(function() instance.Archivable = true end)
        end
    end
    makeArchivable(character)
    for _, instance in ipairs(character:GetDescendants()) do
        makeArchivable(instance)
    end
    local cloned, statue = pcall(function() return character:Clone() end)
    for instance, value in pairs(archivable) do
        pcall(function() instance.Archivable = value end)
    end
    if not cloned or not statue then return nil end

    statue.Name = "uorkeeDeathStatue"
    local color = themeColor()
    local partCount = 0
    for _, instance in ipairs(statue:GetDescendants()) do
        if instance:IsA("BasePart") then
            partCount = partCount + 1
            local lowerName = string.lower(instance.Name)
            local helperPart = lowerName == "humanoidrootpart"
                or string.find(lowerName, "hitbox", 1, true) ~= nil
                or lowerName == "fakemass"
            local wasVisible = instance.Transparency < 0.95 and not helperPart
            instance.Anchored = true
            instance.CanCollide = false
            instance.CanTouch = false
            instance.CanQuery = false
            instance.CastShadow = false
            instance.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            instance.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            instance.Material = Enum.Material.Neon
            instance.Color = color
            instance.Transparency = wasVisible and 0.08 or 1
            pcall(function() instance.LocalTransparencyModifier = 0 end)
            if instance:IsA("MeshPart") then
                pcall(function() instance.TextureID = "" end)
            end
        elseif instance:IsA("SpecialMesh") then
            pcall(function() instance.TextureId = "" end)
        elseif instance:IsA("Script") or instance:IsA("LocalScript")
            or instance:IsA("ModuleScript") or instance:IsA("Humanoid")
            or instance:IsA("Animator") or instance:IsA("AnimationController")
            or instance:IsA("Decal") or instance:IsA("Texture")
            or instance:IsA("SurfaceAppearance") or instance:IsA("ParticleEmitter")
            or instance:IsA("Trail") or instance:IsA("Beam")
            or instance:IsA("Smoke") or instance:IsA("Fire")
            or instance:IsA("Sparkles") or instance:IsA("Sound")
            or instance:IsA("Highlight") or instance:IsA("BillboardGui")
            or instance:IsA("ForceField") or instance:IsA("ProximityPrompt")
            or instance:IsA("ClickDetector") then
            pcall(function() instance:Destroy() end)
        end
    end

    if partCount == 0 then
        statue:Destroy()
        return nil
    end
    return statue
end

local function statueTextFor(player)
    local displayName = player.DisplayName
    if type(displayName) ~= "string" or displayName == "" then displayName = player.Name end
    local text = tostring(Settings.DeathStatueText or "")
    text = text:gsub("{player}", function() return displayName end)
    if text == "" then text = displayName end
    return text
end

local function showNeonStatue(player, statue, reason)
    if not statue or stopped or not DeathStatuesAlive then
        if statue then pcall(function() statue:Destroy() end) end
        return
    end

    statue.Name = "uorkeeDeathStatue_" .. tostring(player.UserId)
    statue.Parent = DeathStatueFolder
    local statueColor = themeColor()
    local outlineColor = statueColor:Lerp(Color3.new(0, 0, 0), 0.34)
    local outline = create("Highlight", statue, {
        Name = "uorkeeDeathOutline",
        Adornee = statue,
        DepthMode = Enum.HighlightDepthMode.Occluded,
        FillColor = statueColor,
        FillTransparency = 1,
        OutlineColor = outlineColor,
        OutlineTransparency = 0.08,
    })
    local adornee = statue:FindFirstChild("Head", true)
        or statue:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then
        statue:Destroy()
        return
    end

    local billboard = create("BillboardGui", adornee, {
        Name = "uorkeeDeathText",
        Adornee = adornee,
        AlwaysOnTop = true,
        LightInfluence = 0,
        MaxDistance = 10000,
        Size = UDim2.new(0, 280, 0, 48),
        StudsOffset = Vector3.new(0, 2.65, 0),
    })
    local label = create("TextLabel", billboard, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 11, 18),
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        Text = statueTextFor(player),
        TextColor3 = themeColor(),
        TextSize = 16,
        TextScaled = false,
        TextWrapped = true,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.08,
        Font = Enum.Font.GothamBlack,
    })
    addCorner(label, 12)
    local stroke = addStroke(label, themeColor(), 1.4, 0.2)

    local parts = {}
    for _, descendant in ipairs(statue:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Transparency < 0.95 then
            parts[#parts + 1] = descendant
        end
    end
    ActiveStatues[statue] = {
        player = player,
        parts = parts,
        label = label,
        stroke = stroke,
        outline = outline,
        reason = reason,
    }

end

local function clearActiveDeathStatues()
    for statue in pairs(ActiveStatues) do
        pcall(function() statue:Destroy() end)
    end
    table.clear(ActiveStatues)
end

registerRefresh(function(color)
    color = color or themeColor()
    for statue, data in pairs(ActiveStatues) do
        if not statue.Parent then
            ActiveStatues[statue] = nil
        else
            for _, part in ipairs(data.parts) do
                if part.Parent then part.Color = color end
            end
            if data.label and data.label.Parent then data.label.TextColor3 = color end
            if data.stroke and data.stroke.Parent then data.stroke.Color = color end
            if data.outline and data.outline.Parent then
                data.outline.FillColor = color
                data.outline.OutlineColor = color:Lerp(Color3.new(0, 0, 0), 0.34)
            end
        end
    end
end)

local function normalizedStateName(name)
    return string.lower(tostring(name or "")):gsub("[%s_%-]", "")
end

local function indicatesCustomDeath(name, value)
    local key = normalizedStateName(name)
    if (key == "health" or key == "hp" or key == "currenthealth"
        or key == "currenthp" or key == "healthpoints") and type(value) == "number" then
        return value <= 0
    end
    if key == "dead" or key == "isdead" or key == "eliminated"
        or key == "iseliminated" or key == "knockedout" then
        return value == true or value == 1
    end
    if key == "alive" or key == "isalive" then
        return value == false or value == 0
    end
    if key == "state" or key == "status" or key == "lifestate" then
        local state = string.lower(tostring(value or ""))
        return state == "dead" or state == "death" or state == "killed"
            or state == "eliminated" or state == "knockedout"
    end
    return false
end

local function isCustomHealthName(name)
    local key = normalizedStateName(name)
    return key == "health" or key == "hp" or key == "currenthealth"
        or key == "currenthp" or key == "healthpoints"
end

local function observeCustomHealth(player, record, source, name, value)
    if not isCustomHealthName(name) or type(value) ~= "number" then return end
    local previousHealth = record.hitHealth[source]
    record.hitHealth[source] = value
    if previousHealth == nil or value >= previousHealth - 0.01 then return end
    if player == LocalPlayer or sameTeam(player) then return end
    if HitSoundAttackHeld or os.clock() - LastAttackInputAt <= 1.25 then
        playHitSound()
    end
end

local function markDeath(player, character, record, reason, preparedStatue)
    if not DeathStatuesAlive or not record or record.dead then
        if preparedStatue then preparedStatue:Destroy() end
        return
    end
    record.dead = true
    if player ~= LocalPlayer and not detectedSameTeam(player) then
        task.defer(evaluateVictoryMusic)
    end
    if not Settings.DeathStatueEnabled or player == LocalPlayer or sameTeam(player) then
        if preparedStatue then preparedStatue:Destroy() end
        return
    end
    local statue = preparedStatue or prepareNeonStatue(character)
    showNeonStatue(player, statue, reason)
end

local function hookCustomValue(player, character, record, valueObject)
    if not valueObject:IsA("ValueBase") or record.values[valueObject] then return end
    local key = normalizedStateName(valueObject.Name)
    local relevant = key == "health" or key == "hp" or key == "currenthealth"
        or key == "currenthp" or key == "healthpoints" or key == "dead"
        or key == "isdead" or key == "alive" or key == "isalive"
        or key == "eliminated" or key == "iseliminated" or key == "knockedout"
        or key == "state" or key == "status" or key == "lifestate"
    if not relevant then return end
    record.values[valueObject] = true
    observeCustomHealth(player, record, valueObject, valueObject.Name, valueObject.Value)
    record.connections[#record.connections + 1] = valueObject.Changed:Connect(function(value)
        observeCustomHealth(player, record, valueObject, valueObject.Name, value)
        if indicatesCustomDeath(valueObject.Name, value) then
            markDeath(player, character, record, "custom_value:" .. valueObject.Name)
        end
    end)
end

local function hookDeathAttributes(player, character, record, instance)
    local attributeHealth = {}
    record.hitAttributes[instance] = attributeHealth
    local gotAttributes, attributes = pcall(function() return instance:GetAttributes() end)
    if gotAttributes and type(attributes) == "table" then
        for name, value in pairs(attributes) do
            if isCustomHealthName(name) and type(value) == "number" then
                attributeHealth[normalizedStateName(name)] = value
            end
        end
    end
    record.connections[#record.connections + 1] = instance.AttributeChanged:Connect(function(name)
        local ok, value = pcall(function() return instance:GetAttribute(name) end)
        if ok then
            local key = normalizedStateName(name)
            if isCustomHealthName(name) and type(value) == "number" then
                local previousHealth = attributeHealth[key]
                attributeHealth[key] = value
                if previousHealth ~= nil and value < previousHealth - 0.01
                    and player ~= LocalPlayer and not sameTeam(player)
                    and (HitSoundAttackHeld or os.clock() - LastAttackInputAt <= 1.25) then
                    playHitSound()
                end
            end
            if indicatesCustomDeath(name, value) then
                markDeath(player, character, record, "attribute:" .. tostring(name))
            end
        end
    end)
end

local function massRemovalNear(time)
    local count = 0
    for index = #RecentCharacterRemovals, 1, -1 do
        local record = RecentCharacterRemovals[index]
        if time - record.time > 0.8 then
            table.remove(RecentCharacterRemovals, index)
        elseif math.abs(time - record.time) <= 0.28 then
            count = count + 1
        end
    end
    local playerCount = #Players:GetPlayers()
    return count >= math.max(2, math.ceil(playerCount * 0.55))
end

local function noteCharacterRemoval(player)
    local removal = {time = os.clock(), player = player}
    RecentCharacterRemovals[#RecentCharacterRemovals + 1] = removal
    task.delay(0.3, function()
        if DeathStatuesAlive and massRemovalNear(removal.time) then
            clearActiveDeathStatues()
        end
    end)
    return removal
end

local function attachCharacterDeathTracker(player, tracker, character)
    if VictoryMusicState.Triggered and not detectedSameTeam(player) then
        stopVictoryMusic(true)
    end
    if tracker.current then disconnectAll(tracker.current.connections) end
    local record = {
        character = character,
        connections = {},
        values = setmetatable({}, {__mode = "k"}),
        hitHealth = setmetatable({}, {__mode = "k"}),
        hitAttributes = setmetatable({}, {__mode = "k"}),
        dead = false,
        startedAt = os.clock(),
    }
    tracker.current = record

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        record.hitHealth[humanoid] = humanoid.Health
        record.connections[#record.connections + 1] = humanoid.Died:Connect(function()
            markDeath(player, character, record, "humanoid_died")
        end)
        record.connections[#record.connections + 1] = humanoid.HealthChanged:Connect(function(health)
            observeHumanoidHealth(player, record, humanoid, health)
            if health <= 0 then markDeath(player, character, record, "humanoid_health") end
        end)
        hookDeathAttributes(player, character, record, humanoid)
    end
    hookDeathAttributes(player, character, record, character)
    for _, descendant in ipairs(character:GetDescendants()) do
        hookCustomValue(player, character, record, descendant)
    end
    for _, descendant in ipairs(player:GetDescendants()) do
        hookCustomValue(player, character, record, descendant)
    end
    record.connections[#record.connections + 1] = character.DescendantAdded:Connect(function(descendant)
        hookCustomValue(player, character, record, descendant)
        if descendant:IsA("Humanoid") and descendant ~= humanoid then
            record.hitHealth[descendant] = descendant.Health
            record.connections[#record.connections + 1] = descendant.Died:Connect(function()
                markDeath(player, character, record, "late_humanoid_died")
            end)
            record.connections[#record.connections + 1] = descendant.HealthChanged:Connect(function(health)
                observeHumanoidHealth(player, record, descendant, health)
                if health <= 0 then markDeath(player, character, record, "late_humanoid_health") end
            end)
            hookDeathAttributes(player, character, record, descendant)
        end
    end)
end

local function trackPlayerDeath(player)
    if player == LocalPlayer or DeathTrackers[player] then return end
    local tracker = {connections = {}, current = nil}
    DeathTrackers[player] = tracker

    tracker.connections[#tracker.connections + 1] = player.CharacterAdded:Connect(function(character)
        attachCharacterDeathTracker(player, tracker, character)
    end)
    tracker.connections[#tracker.connections + 1] = player.CharacterRemoving:Connect(function(character)
        local record = tracker.current
        if not record or record.character ~= character or record.dead
            or os.clock() - record.startedAt < 0.6 then return end

        local removal = noteCharacterRemoval(player)
        if not Settings.DeathStatueEnabled or sameTeam(player) then return end

        local prepared = prepareNeonStatue(character)
        if not prepared then return end
        task.delay(0.3, function()
            if not DeathStatuesAlive or record.dead then
                prepared:Destroy()
                return
            end
            local characterGone = player.Character ~= character or character.Parent == nil
            local roundReset = massRemovalNear(removal.time)
            if roundReset then clearActiveDeathStatues() end
            if player.Parent == Players and characterGone and not roundReset then
                markDeath(player, character, record, "character_removed", prepared)
            else
                prepared:Destroy()
            end
        end)
    end)
    tracker.connections[#tracker.connections + 1] = player.AttributeChanged:Connect(function(name)
        local record = tracker.current
        if not record then return end
        local ok, value = pcall(function() return player:GetAttribute(name) end)
        if ok and indicatesCustomDeath(name, value) then
            markDeath(player, record.character, record, "player_attribute:" .. tostring(name))
        end
    end)
    tracker.connections[#tracker.connections + 1] = player.DescendantAdded:Connect(function(descendant)
        local record = tracker.current
        if record then hookCustomValue(player, record.character, record, descendant) end
    end)
    if player.Character then attachCharacterDeathTracker(player, tracker, player.Character) end
end

local function untrackPlayerDeath(player)
    local tracker = DeathTrackers[player]
    if not tracker then return end
    disconnectAll(tracker.connections)
    if tracker.current then disconnectAll(tracker.current.connections) end
    DeathTrackers[player] = nil
end

local function cleanupDeathStatues()
    if not DeathStatuesAlive then return end
    DeathStatuesAlive = false
    disconnectAll(DeathGlobalConnections)
    for player in pairs(DeathTrackers) do untrackPlayerDeath(player) end
    clearActiveDeathStatues()
    if DeathStatueFolder and DeathStatueFolder.Parent then DeathStatueFolder:Destroy() end
end

RuntimeEnvironment.uorkeeDeathStatueCleanup = cleanupDeathStatues
for _, player in ipairs(Players:GetPlayers()) do trackPlayerDeath(player) end
DeathGlobalConnections[#DeathGlobalConnections + 1] = Players.PlayerAdded:Connect(trackPlayerDeath)
DeathGlobalConnections[#DeathGlobalConnections + 1] = Players.PlayerRemoving:Connect(untrackPlayerDeath)
local LocalCharacterWasRemoved = false
DeathGlobalConnections[#DeathGlobalConnections + 1] = LocalPlayer.CharacterRemoving:Connect(function()
    LocalCharacterWasRemoved = true
    noteCharacterRemoval(LocalPlayer)
end)
DeathGlobalConnections[#DeathGlobalConnections + 1] = LocalPlayer.CharacterAdded:Connect(function()
    stopVictoryMusic(true)
    if LocalCharacterWasRemoved then clearActiveDeathStatues() end
    LocalCharacterWasRemoved = false
end)
for _, attributeName in ipairs({"TeamID", "EnvironmentID"}) do
    DeathGlobalConnections[#DeathGlobalConnections + 1] =
        LocalPlayer:GetAttributeChangedSignal(attributeName):Connect(function()
            stopVictoryMusic(true)
            clearActiveDeathStatues()
        end)
end

local function isTeleportWhitelisted(player)
    for key, value in pairs(Settings.TeleportWhitelist) do
        -- Поддерживаются обе формы: {"Name", 123} и {Name = true, [123] = true}.
        local entry = value == true and key or value
        if type(entry) == "number" and player.UserId == entry then
            return true
        end
        if type(entry) == "string" then
            if string.lower(entry) == string.lower(player.Name) then
                return true
            end
            local numericId = tonumber(entry)
            if numericId and player.UserId == numericId then
                return true
            end
        end
    end
    return false
end

local function teleportToNearestPlayer()
    local localCharacter, localRoot = characterInfo(LocalPlayer)
    if not localCharacter or not localRoot then return false end

    local nearestRoot
    local nearestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and not sameTeam(player)
            and not isTeleportWhitelisted(player) then
            local _, root = characterInfo(player)
            if root then
                local distance = (root.Position - localRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestRoot = root
                end
            end
        end
    end

    if not nearestRoot then return false end
    localCharacter:PivotTo(nearestRoot.CFrame * CFrame.new(0, 0, Settings.TeleportOffset))
    return true
end

local function updatePlayerESP(player, data, color)
    if not Settings.ESPEnabled or sameTeam(player) then
        hidePlayerESP(data)
        return
    end

    local character = characterInfo(player)
    if not character then
        clearPlayerESP(data)
        return
    end

    local head = character:FindFirstChild("Head")
    if not head then
        clearPlayerESP(data)
        return
    end

    if data.Character ~= character or not data.Highlight then
        clearPlayerESP(data)
        data.Character = character

        data.Highlight = create("Highlight", ScreenGui, {
            Name = "uorkeePlayerHighlight",
            Adornee = character,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            FillTransparency = 0.5,
            OutlineTransparency = 0,
            Enabled = false,
        })

        data.HeadBillboard = create("BillboardGui", ScreenGui, {
            Name = "uorkeeHeadCircle",
            Adornee = head,
            AlwaysOnTop = true,
            LightInfluence = 0,
            MaxDistance = 10000,
            Size = UDim2.new(2.4, 0, 2.4, 0),
            Enabled = false,
        })
        local headRing = create("Frame", data.HeadBillboard, {
            Name = "Ring",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        addCorner(headRing, 999)
        data.HeadRingStroke = addStroke(headRing, color, 2, 0)

        data.NameBillboard = create("BillboardGui", ScreenGui, {
            Name = "uorkeePlayerName",
            Adornee = head,
            AlwaysOnTop = true,
            LightInfluence = 0,
            MaxDistance = 10000,
            Size = UDim2.new(0, 180, 0, 24),
            StudsOffset = Vector3.new(0, 1.85, 0),
            Enabled = false,
        })
        data.NameLabel = create("TextLabel", data.NameBillboard, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextStrokeTransparency = 0.15,
        })
    end

    local displayName = player.DisplayName
    if type(displayName) ~= "string" or displayName == "" then
        displayName = player.Name
    end
    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color
    data.HeadRingStroke.Color = color
    data.NameLabel.Text = displayName
    data.NameLabel.TextColor3 = color
    data.Highlight.Enabled = true
    data.HeadBillboard.Enabled = true
    data.NameBillboard.Enabled = Settings.NamesESP
end

for _, player in ipairs(Players:GetPlayers()) do
    createPlayerESP(player)
end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

local function isVisible(character, targetPart)
    if not Settings.WallCheck then
        return true
    end
    local ignore = {LocalPlayer.Character, character}
    local ok, obscuring = pcall(function()
        return Camera:GetPartsObscuringTarget({targetPart.Position}, ignore)
    end)
    return ok and obscuring and #obscuring == 0
end

local function closestTarget()
    local closestPart
    local bestAlignment = -math.huge
    local cameraPosition = Camera.CFrame.Position
    local cameraDirection = Camera.CFrame.LookVector

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not sameTeam(player) then
            local character = characterInfo(player)
            local head = character and character:FindFirstChild("Head")
            if head and isVisible(character, head) then
                -- World-space scoring deliberately has no on-screen/FOV gate.
                -- A target behind the camera is therefore still a valid target.
                local offset = head.Position - cameraPosition
                local distance = offset.Magnitude
                if distance > 0 then
                    local alignment = cameraDirection:Dot(offset / distance)
                    if alignment > bestAlignment then
                        bestAlignment = alignment
                        closestPart = head
                    end
                end
            end
        end
    end
    return closestPart
end

local function aimbotBindActive()
    if Settings.AimbotBindMode == "Hold" then
        return AimbotBindHeld
    end
    return Settings.AimbotEnabled
end

local function triggerbotBindActive()
    if Settings.TriggerbotBindMode == "Hold" then
        return TriggerbotBindHeld
    end
    return Settings.TriggerbotEnabled
end

local updateFeatureHUD
do
    -- Keep the status panel visible even when the settings menu is closed.
    local hud = create("Frame", ScreenGui, {
        Name = "FeatureHUD",
        Position = UDim2.new(0, 82, 0, 18),
        Size = UDim2.new(0, 190, 0, 90),
        BackgroundColor3 = Color3.fromRGB(18, 21, 31),
        BackgroundTransparency = glassTransparency(),
        BorderSizePixel = 0,
        ZIndex = 8,
    })
    addCorner(hud, 14)
    local stroke = addStroke(hud, themeColor(), 1, 0.4)
    local gradient = addLiquidGradient(hud, 25)
    local title = create("TextLabel", hud, {
        Name = "Title",
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text = "uorkee hub",
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
    })

    local function statusRow(name, y)
        return create("TextLabel", hud, {
            Name = name .. "Status",
            Position = UDim2.new(0, 14, 0, y),
            Size = UDim2.new(1, -28, 0, 24),
            BackgroundTransparency = 1,
            Text = "",
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 9,
        })
    end
    local aimLabel = statusRow("Aimbot", 30)
    local triggerLabel = statusRow("Triggerbot", 54)
    local onColor = Color3.fromRGB(127, 235, 170)
    local offColor = Color3.fromRGB(232, 154, 154)
    local previousAim, previousTrigger

    updateFeatureHUD = function()
        -- Use the same activation checks as the features, including held binds.
        local aimActive = aimbotBindActive()
        local triggerActive = triggerbotBindActive()
        if aimActive ~= previousAim then
            aimLabel.Text = "Aimbot: " .. (aimActive and "ON" or "OFF")
            aimLabel.TextColor3 = aimActive and onColor or offColor
            previousAim = aimActive
        end
        if triggerActive ~= previousTrigger then
            triggerLabel.Text = "Triggerbot: " .. (triggerActive and "ON" or "OFF")
            triggerLabel.TextColor3 = triggerActive and onColor or offColor
            previousTrigger = triggerActive
        end
    end
    registerRefresh(function(color)
        color = color or themeColor()
        title.TextColor3 = color
        stroke.Color = color
        gradient.Color = liquidColors(color, 0.76)
        hud.BackgroundTransparency = glassTransparency()
        updateFeatureHUD()
    end)
end

local function hoveredPlayer()
    local target = Mouse.Target
    local current = target

    while current and current ~= workspace do
        if current:IsA("Model") then
            local player = Players:GetPlayerFromCharacter(current)
            if player then
                return player
            end
        end
        current = current.Parent
    end
end

local function clickLeftMouse()
    local environment = _G
    pcall(function()
        if getgenv then
            environment = getgenv()
        end
    end)

    local activeCheck = rawget(environment, "isrbxactive") or rawget(_G, "isrbxactive")
    if type(activeCheck) == "function" and not activeCheck() then
        return false
    end

    local click = rawget(environment, "mouse1click") or rawget(_G, "mouse1click")
    if type(click) == "function" then
        noteLocalAttack()
        click()
        return true
    end

    local press = rawget(environment, "mouse1press") or rawget(_G, "mouse1press")
    local release = rawget(environment, "mouse1release") or rawget(_G, "mouse1release")
    if type(press) == "function" and type(release) == "function" then
        noteLocalAttack()
        press()
        task.delay(0.015, release)
        return true
    end

    -- Fallback for executors which expose Roblox's virtual input service.
    local point = UserInputService:GetMouseLocation()
    local ok = pcall(function()
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendMouseButtonEvent(point.X, point.Y, 0, true, game, 0)
        task.delay(0.015, function()
            virtualInput:SendMouseButtonEvent(point.X, point.Y, 0, false, game, 0)
        end)
    end)
    if ok then noteLocalAttack() end
    return ok
end

RunService:BindToRenderStep("uorkeeESP", Enum.RenderPriority.Camera.Value, function()
    updateFeatureHUD()
    Camera = workspace.CurrentCamera
    local color
    if Settings.RainbowFOV then
        color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    else
        color = themeColor()
    end

    FOVCircle.Position = viewportCenter()
    FOVCircle.Radius = Settings.FOVRadius
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Color = color

    for player, data in pairs(PlayerESP) do
        updatePlayerESP(player, data, color)
    end
end)

RunService:BindToRenderStep("uorkeeAimlock", Enum.RenderPriority.Camera.Value + 1, function()
    if not aimbotBindActive() then return end
    Camera = workspace.CurrentCamera
    if not Camera then return end
    local target = closestTarget()
    if not target then return end
    local goal = CFrame.new(Camera.CFrame.Position, target.Position)
    Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(Settings.AimSpeed / 10, 0, 1))
end)

local lastTrigger = -math.huge
RunService:BindToRenderStep("uorkeeTriggerbot", Enum.RenderPriority.Camera.Value + 2, function()
    if not triggerbotBindActive() then return end

    local player = hoveredPlayer()
    if not player or player == LocalPlayer or sameTeam(player) then return end

    local character = characterInfo(player)
    if not character then return end

    local now = os.clock()
    if now - lastTrigger < Settings.TriggerDelay then return end
    lastTrigger = now
    clickLeftMouse()
end)

RunService:BindToRenderStep("uorkeeTeleportBind", Enum.RenderPriority.Camera.Value + 3, function()
    local active
    if Settings.TeleportBindMode == "Hold" then
        active = TeleportBindHeld
    else
        active = TeleportBindToggled
    end
    if not active then return end

    local now = os.clock()
    if now < nextTeleportBindAt then return end
    nextTeleportBindAt = now + 0.18
    teleportToNearestPlayer()
end)

local InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJumpEnabled then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
RuntimeEnvironment.uorkeeInfiniteJumpConnection = InfiniteJumpConnection

do
    local state = {
        Alive = true,
        NoclipHeld = false,
        SpeedHeld = false,
        NoclipCharacter = nil,
        OriginalCollisions = setmetatable({}, {__mode = "k"}),
        SpeedHumanoid = nil,
        OriginalWalkSpeed = nil,
        Connection = nil,
    }
    RuntimeEnvironment.uorkeeMovementState = state

    state.NoclipActive = function()
        if Settings.NoclipBindMode == "Hold" then
            return state.NoclipHeld
        end
        return Settings.NoclipEnabled
    end

    state.SpeedActive = function()
        if Settings.SpeedBindMode == "Hold" then
            return state.SpeedHeld
        end
        return Settings.SpeedEnabled
    end

    state.RestoreNoclip = function()
        for part, originalCanCollide in pairs(state.OriginalCollisions) do
            pcall(function()
                if part.Parent then
                    part.CanCollide = originalCanCollide
                end
            end)
        end
        table.clear(state.OriginalCollisions)
        state.NoclipCharacter = nil
    end

    state.RestoreSpeed = function()
        if state.SpeedHumanoid and state.OriginalWalkSpeed ~= nil then
            pcall(function()
                if state.SpeedHumanoid.Parent then
                    state.SpeedHumanoid.WalkSpeed = state.OriginalWalkSpeed
                end
            end)
        end
        state.SpeedHumanoid = nil
        state.OriginalWalkSpeed = nil
    end

    state.Cleanup = function()
        if not state.Alive then return end
        state.Alive = false
        if state.Connection then
            pcall(function() state.Connection:Disconnect() end)
            state.Connection = nil
        end
        state.RestoreNoclip()
        state.RestoreSpeed()
        if RuntimeEnvironment.uorkeeMovementState == state then
            RuntimeEnvironment.uorkeeMovementState = nil
            RuntimeEnvironment.uorkeeMovementCleanup = nil
        end
    end
    RuntimeEnvironment.uorkeeMovementCleanup = state.Cleanup

    state.Connection = RunService.Stepped:Connect(function()
        if not state.Alive or stopped then return end

        local character = LocalPlayer.Character
        if state.NoclipActive() and character then
            if state.NoclipCharacter ~= character then
                state.RestoreNoclip()
                state.NoclipCharacter = character
            end
            for _, descendant in ipairs(character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    if state.OriginalCollisions[descendant] == nil then
                        state.OriginalCollisions[descendant] = descendant.CanCollide
                    end
                    descendant.CanCollide = false
                end
            end
        elseif state.NoclipCharacter then
            state.RestoreNoclip()
        end

        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if state.SpeedActive() and humanoid and humanoid.Health > 0 then
            if state.SpeedHumanoid ~= humanoid then
                state.RestoreSpeed()
                state.SpeedHumanoid = humanoid
                state.OriginalWalkSpeed = humanoid.WalkSpeed
            end
            humanoid.WalkSpeed = Settings.SpeedValue
        elseif state.SpeedHumanoid then
            state.RestoreSpeed()
        end
    end)
end

local FakeLagRoot
local fakeLagSleeping = false
local nextFakeLagSwitch = 0
local fakeLagWarningShown = false

local function warnFakeLag(message)
    if fakeLagWarningShown then return end
    fakeLagWarningShown = true
    warn("[uorkee hub] Fake Lag: " .. message)
end

local function restoreFakeLag()
    local root = FakeLagRoot or RuntimeEnvironment.uorkeeFakeLagRoot
    local setter = SetHiddenProperty or RuntimeEnvironment.uorkeeFakeLagSetter
    if root and type(setter) == "function" then
        pcall(setter, root, "NetworkIsSleeping", false)
    end
    FakeLagRoot = nil
    fakeLagSleeping = false
    nextFakeLagSwitch = 0
    RuntimeEnvironment.uorkeeFakeLagRoot = nil
    RuntimeEnvironment.uorkeeFakeLagSetter = nil
end

RunService:BindToRenderStep("uorkeeFakeLag", Enum.RenderPriority.Last.Value + 1, function()
    if not Settings.FakeLagEnabled then
        if FakeLagRoot or fakeLagSleeping then
            restoreFakeLag()
        end
        return
    end

    if type(SetHiddenProperty) ~= "function" then
        warnFakeLag("sethiddenproperty is not available in this executor build")
        return
    end

    local _, root = characterInfo(LocalPlayer)
    if not root then
        restoreFakeLag()
        return
    end

    if FakeLagRoot ~= root then
        restoreFakeLag()
        FakeLagRoot = root
        RuntimeEnvironment.uorkeeFakeLagRoot = root
        RuntimeEnvironment.uorkeeFakeLagSetter = SetHiddenProperty
    end

    local now = os.clock()
    if now < nextFakeLagSwitch then return end

    local sleeping = not fakeLagSleeping
    local success = pcall(SetHiddenProperty, root, "NetworkIsSleeping", sleeping)
    if not success then
        warnFakeLag("this executor cannot change NetworkIsSleeping")
        restoreFakeLag()
        return
    end

    fakeLagSleeping = sleeping
    nextFakeLagSwitch = now + (sleeping and Settings.FakeLagHold or Settings.FakeLagRelease)
end)

local function terminate()
    MenuUI.Alive = false
    for _, tween in ipairs(MenuUI.Tweens) do tween:Cancel() end
    if MenuUI.PageTween then MenuUI.PageTween:Cancel() end
    pcall(function() RunService:UnbindFromRenderStep("uorkeeMenuFX") end)
    if stopped then return end
    stopped = true
    if ConfigState.AutoSave then
        pcall(function() saveConfig("default") end)
    end
    pcall(saveConfigState)
    if RuntimeEnvironment.uorkeeConfigSessionToken == ConfigSessionToken then
        RuntimeEnvironment.uorkeeConfigSessionToken = nil
    end
    pcall(function() FOVCircle:Remove() end)
    pcall(function() RunService:UnbindFromRenderStep("uorkeeAimlock") end)
    pcall(function() RunService:UnbindFromRenderStep("uorkeeESP") end)
    pcall(function() RunService:UnbindFromRenderStep("uorkeeTriggerbot") end)
    pcall(function() RunService:UnbindFromRenderStep("uorkeeTeleportBind") end)
    pcall(function() RunService:UnbindFromRenderStep("uorkeeFakeLag") end)
    restoreFakeLag()
    if MainInputConnection then
        pcall(function() MainInputConnection:Disconnect() end)
        MainInputConnection = nil
    end
    if MainInputEndedConnection then
        pcall(function() MainInputEndedConnection:Disconnect() end)
        MainInputEndedConnection = nil
    end
    RuntimeEnvironment.uorkeeInputConnections = nil
    pcall(function() InfiniteJumpConnection:Disconnect() end)
    if RuntimeEnvironment.uorkeeInfiniteJumpConnection == InfiniteJumpConnection then
        RuntimeEnvironment.uorkeeInfiniteJumpConnection = nil
    end
    cleanupDeathStatues()
    if RuntimeEnvironment.uorkeeDeathStatueCleanup == cleanupDeathStatues then
        RuntimeEnvironment.uorkeeDeathStatueCleanup = nil
    end
    cleanupHitSound()
    if RuntimeEnvironment.uorkeeHitSoundCleanup == cleanupHitSound then
        RuntimeEnvironment.uorkeeHitSoundCleanup = nil
    end
    cleanupVictoryMusic()
    if RuntimeEnvironment.uorkeeVictoryMusicCleanup == cleanupVictoryMusic then
        RuntimeEnvironment.uorkeeVictoryMusicCleanup = nil
    end
    local ambientCleanup = RuntimeEnvironment.uorkeeAmbientModeCleanup
    if type(ambientCleanup) == "function" then pcall(ambientCleanup) end
    if type(RuntimeEnvironment.uorkeeMovementCleanup) == "function" then
        pcall(RuntimeEnvironment.uorkeeMovementCleanup)
    end
    for player in pairs(PlayerESP) do
        removePlayerESP(player)
    end
    ScreenGui:Destroy()
end

addAction("Terminate uorkee hub", terminate)

MenuButton.MouseButton1Click:Connect(function()
    MenuUI.setOpen(not MenuUI.Open)
end)

local function bindingFromInput(input)
    if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode
    end
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseButton1
        or inputType == Enum.UserInputType.MouseButton2
        or inputType == Enum.UserInputType.MouseButton3 then
        return inputType
    end
end

local function inputMatchesBinding(input, binding)
    return binding ~= nil
        and (input.KeyCode == binding or input.UserInputType == binding)
end

local function toggleFeatureSetting(settingKey)
    local value = not Settings[settingKey]
    local setter = ConfigControls[settingKey]
    if setter then
        setter(value)
    else
        Settings[settingKey] = value
        queueAutoSave()
    end
end

MainInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if stopped then return end

    -- Binding capture must run before the Roblox/UI processed-input guard.
    -- Mouse clicks made while the menu is open are otherwise discarded.
    if waitingForBindingSetting then
        local binding = bindingFromInput(input)
        if binding then
            Settings[waitingForBindingSetting] = binding
            waitingForBindingSetting = nil
            refreshKeyButtons()
            queueAutoSave()
        end
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        HitSoundAttackHeld = true
        noteLocalAttack()
    end
    if gameProcessed then return end

    if inputMatchesBinding(input, Settings.TeleportKey) then
        if Settings.TeleportBindMode == "Hold" then
            TeleportBindHeld = true
        else
            TeleportBindToggled = not TeleportBindToggled
        end
        nextTeleportBindAt = os.clock() + 0.18
        teleportToNearestPlayer()
    end

    if inputMatchesBinding(input, Settings.AimbotKey) then
        if Settings.AimbotBindMode == "Hold" then
            AimbotBindHeld = true
        else
            toggleFeatureSetting("AimbotEnabled")
        end
    end

    if inputMatchesBinding(input, Settings.TriggerbotKey) then
        if Settings.TriggerbotBindMode == "Hold" then
            TriggerbotBindHeld = true
        else
            toggleFeatureSetting("TriggerbotEnabled")
        end
    end

    if inputMatchesBinding(input, Settings.NoclipKey) then
        local state = RuntimeEnvironment.uorkeeMovementState
        if state then
            if Settings.NoclipBindMode == "Hold" then
                state.NoclipHeld = true
            else
                toggleFeatureSetting("NoclipEnabled")
            end
        end
    end

    if inputMatchesBinding(input, Settings.SpeedKey) then
        local state = RuntimeEnvironment.uorkeeMovementState
        if state then
            if Settings.SpeedBindMode == "Hold" then
                state.SpeedHeld = true
            else
                toggleFeatureSetting("SpeedEnabled")
            end
        end
    end

    if inputMatchesBinding(input, Settings.MenuKey) then
        MenuUI.setOpen(not MenuUI.Open)
    end
end)

MainInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        HitSoundAttackHeld = false
    end
    if stopped then return end
    if inputMatchesBinding(input, Settings.TeleportKey) then
        TeleportBindHeld = false
    end
    if inputMatchesBinding(input, Settings.AimbotKey) then
        AimbotBindHeld = false
    end
    if inputMatchesBinding(input, Settings.TriggerbotKey) then
        TriggerbotBindHeld = false
    end
    if inputMatchesBinding(input, Settings.NoclipKey) then
        local state = RuntimeEnvironment.uorkeeMovementState
        if state then state.NoclipHeld = false end
    end
    if inputMatchesBinding(input, Settings.SpeedKey) then
        local state = RuntimeEnvironment.uorkeeMovementState
        if state then state.SpeedHeld = false end
    end
end)
RuntimeEnvironment.uorkeeInputConnections = {MainInputConnection, MainInputEndedConnection}

refreshTheme()

task.defer(function()
    if RuntimeEnvironment.uorkeeConfigSessionToken ~= ConfigSessionToken then return end
    if ConfigState.AutoSave then
        ConfigState.ActiveConfig = "default"
        local success, saveError = saveConfig("default")
        if success then
            saveConfigState()
            setConfigStatus("Auto Save active: default", true)
        else
            setConfigStatus("Config unavailable: " .. tostring(saveError), false)
        end
    else
        saveConfigState()
        setConfigStatus("Auto Save disabled", true)
    end
end)

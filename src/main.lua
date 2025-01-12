local modDirectory = g_currentModDirectory
local modName = g_currentModName
local combinexp

local function isEnabled()
    -- Normally this code never runs if CombineXP was not active. However, in development mode
    -- this might not always hold true.
    return combinexp ~= nil
end

-- called after the map is async loaded from :load. has :loadMapData calls. NOTE: self.xmlFile is also deleted here. (Is map.xml)
local function loadedMission(mission, node)
    -- print("loadedMission(mission, superFunc, node)")
    if not isEnabled() then
        return
    end

    if mission.cancelLoading then
        return
    end

    combinexp:onMissionLoaded(mission)
end
local function load(mission)
    -- Ensure the combinexp variable is not already defined
    assert(combinexp == nil, "Error: combinexp is already initialized!")

    -- Create a new instance of CombineXP
    combinexp = CombineXP:new(mission, g_i18n, g_inputBinding, g_gui, g_soundManager, modDirectory, modName)

    -- Debug prints for verification
    print("_G:", _G)
    print("_G.g_combinexp before set:", _G.g_combinexp)

    -- Set the global reference for CombineXP
    _G.g_combinexp = combinexp

    -- Debug print to confirm initialization
    print("CombineXP initialized. g_combinexp set:", _G.g_combinexp)

    -- Register CombineXP as a mod event listener
    addModEventListener(combinexp)
end

local function validateTypes(manager)
    -- print("validateTypes()")
    CombineXP.installSpecializations(manager, g_specializationManager, modDirectory, modName)
end

-- Player clicked on start
local function startMission(mission)
    if not isEnabled() then return end

    combinexp:onMissionStart(mission)
end

local function unload()
    if not isEnabled() then return end

    removeModEventListener(combinexp)

    if combinexp ~= nil then
        combinexp:delete()
        combinexp = nil -- Allows garbage collecting
        getfenv(0).g_combinexp = nil
    end
end

local function init()
    -- print("init()")
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)
    -- FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, loadedMap)

    Mission00.load = Utils.prependedFunction(Mission00.load, load)
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadedMission)
    Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, startMission)

    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateTypes)
end

init()

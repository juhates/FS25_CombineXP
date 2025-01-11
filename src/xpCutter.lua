xpCutter = {};

xpCutter.debug = false --true --

-- Prevent combine threshing to start when starting the cutter if turnedOnByAttacherVehicle is true
function xpCutter:onLoad(superFunc, savegame)
    if xpCutter.debug then print("xpCutter:onLoad") end
    superFunc(self, savegame)
    local spec = self.spec_turnOnVehicle
    if spec then
        spec.turnedOnByAttacherVehicle = false
    end
end

Cutter.onLoad = Utils.overwrittenFunction(Cutter.onLoad, xpCutter.onLoad)

-- Store multiplier to compute yield depending on threshed area
function xpCutter:onEndWorkAreaProcessing(superFunc, dt, hasProcessed)
    -- if xpCutter.debug then print("xpCutter:onEndWorkAreaProcessing") end
    superFunc(self, dt, hasProcessed)
    if self.isServer then
        local spec = Utils.getNoNil(self.spec_cutter, 1)
        local lastRealArea = Utils.getNoNil(spec.workAreaParameters.lastArea, 1)
        local lastThreshedArea = Utils.getNoNil(spec.workAreaParameters.lastThreshedArea, 1)
        if spec.workAreaParameters.combineVehicle then
            local spec_xpCombine = Utils.getNoNil(spec.workAreaParameters.combineVehicle.spec_xpCombine, 1)
            if lastRealArea > 0 and lastThreshedArea > 0 then
                local multiplier = lastRealArea / lastThreshedArea
                -- print("multiplier : "..tostring(multiplier))
                spec_xpCombine.lastMultiplier = multiplier
            else
                spec_xpCombine.lastRealArea = 0
            end
        end
    end
end

Cutter.onEndWorkAreaProcessing = Utils.overwrittenFunction(Cutter.onEndWorkAreaProcessing,
    xpCutter.onEndWorkAreaProcessing)

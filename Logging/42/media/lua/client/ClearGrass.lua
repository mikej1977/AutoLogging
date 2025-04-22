JBLogging = JBLogging or {}
require("JB_SpeedKeeper")

JBLogging.ClearGrass = function(playerObj, worldObjects, selectedArea)
    if not selectedArea then return end
    for _, square in ipairs(selectedArea.squares) do
        for i = 1, square:getObjects():size() do
            local o = square:getObjects():get(i - 1)
            if o:getProperties() and o:getProperties():Is(IsoFlagType.canBeRemoved) then
                ISWorldObjectContextMenu.doRemoveGrass(playerObj, square)
            end
        end
    end
    
    JB_SpeedKeeper.KeepSpeed(playerObj)
    
end


return JBLogging
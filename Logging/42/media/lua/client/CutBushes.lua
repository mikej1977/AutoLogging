JBLogging = JBLogging or {}


JBLogging.ClearBushes = function(playerObj, worldObjects, selectedArea)
    if not selectedArea then return end
    for _, square in ipairs(selectedArea.squares) do
        for i = 1, square:getObjects():size() do
            local o = square:getObjects():get(i - 1)
            if o:getSprite() and o:getSprite():getProperties() and o:getSprite():getProperties():Is(IsoFlagType.canBeCut) then
                ISWorldObjectContextMenu.doRemovePlant(playerObj, square, false)
            end
        end
    end
    
    JB_SpeedKeeper.KeepSpeed(playerObj)
end


return JBLogging
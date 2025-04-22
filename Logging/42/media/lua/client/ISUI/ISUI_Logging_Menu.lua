JBLogging = JBLogging or {}
local JB_ASSUtils = require("JB_ASSUtils")
require("JB_ModOptions")

local old_ISChopTreeAction_new = ISChopTreeAction.new
function ISChopTreeAction:new(character, tree)
    local ret = old_ISChopTreeAction_new(self, character, tree)
    -- if "lower health" mod option then
    if not (character:getDescriptor():getProfession() == "lumberjack") or
        (character:HasTrait("Axeman")) then
        return ret
    end
    local lowerHealth = ret.tree:getHealth() * 0.8
    ret.tree:setHealth(lowerHealth)
    return ret
end

local function predicateChopTree(item)
    return not item:isBroken() and item:hasTag("ChopTree")
end

local function predicateCutPlant(item)
    return not item:isBroken() and item:hasTag("CutPlant")
end

JBLogging.doWorldContextMenu = function(playerIndex, context, worldObjects, test)
    if test then
        if ISWorldObjectContextMenu.Test then return true end
        return ISWorldObjectContextMenu.setTest()
    end

    local playerObj = getSpecificPlayer(playerIndex)
    if playerObj:getVehicle() then return end

    local playerInv = playerObj:getInventory()
    local axe = playerInv:getFirstEvalRecurse(predicateChopTree)
    local hasCuttingTool = playerInv:containsEvalRecurse(predicateCutPlant)

    local clickedFlags = {
        tree = false,
        logs = false,
        plank = false,
        twig = false,
        bush = false,
        grass = false
    }

    local subMenu = ISContextMenu:getNew(context)

    local modOptions = PZAPI.ModOptions:getOptions("JBLoggingModOptions")
    local alwaysShowMenu = modOptions:getOption("Always_Show_Menu"):getValue(1)
    local keepOnTop = modOptions:getOption("Keep_Menu_At_Top"):getValue(1)
    local highlightColorData = modOptions:getOption("Select_Color"):getValue()

    JB_ASSUtils.highlightColorData = { red = highlightColorData.r, green = highlightColorData.g, blue = highlightColorData.b }
    playerObj:getModData().highlightColorData = { red = highlightColorData.r, green = highlightColorData.g, blue = highlightColorData.b }
    
    local sq = worldObjects[1]:getSquare()
    local z = sq:getZ()
    local squares = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            table.insert(squares, getSquare(sq:getX() + dx, sq:getY() + dy, z))
        end
    end

    local function processSquare(square)
        local wobs = square:getWorldObjects()
        local obs = square:getObjects()
        local twigs = { 
            ["Base.LargeBranch"] = true, 
            ["Base.Sapling"] = true, 
            ["Base.TreeBranch2"] = true, 
            ["Base.Twigs"] = true, 
            ["Base.Splinters"] = true 
        }

        for i = 0, wobs:size() - 1 do
            local o = wobs:get(i)
            if instanceof(o, "IsoWorldInventoryObject") then
                local fullType = o:getItem():getFullType()
                if fullType == "Base.Log" then
                    clickedFlags.logs = true
                elseif fullType == "Base.Plank" then
                    clickedFlags.plank = true
                elseif twigs[fullType] then
                    clickedFlags.twig = true
                end
            end
        end

        for i = 0, obs:size() - 1 do
            local o = obs:get(i)
            if o:getProperties() and o:getProperties():Is(IsoFlagType.canBeRemoved) then
                clickedFlags.grass = true
            elseif o:getSprite() and o:getSprite():getProperties() and o:getSprite():getProperties():Is(IsoFlagType.canBeCut) then
                clickedFlags.bush = true
            end
        end

        if square:HasTree() then
            clickedFlags.tree = true
        end
    end

    for _, square in ipairs(squares) do
        processSquare(square)
    end

    local menuOptions = {
        { condition = clickedFlags.tree, translate = "UI_JBLogging_Menu_Identify", action = JBLogging.doTreeInfo },
        { condition = clickedFlags.logs, translate = "UI_JBLogging_Menu_Gather_Logs", action = JBLogging.doGatherLogs },
        { condition = clickedFlags.twig, translate = "UI_JBLogging_Menu_Gather_Branches", action = JBLogging.doGatherTwigsAndBranches },
        { condition = axe and clickedFlags.tree, translate = "UI_JBLogging_Menu_Clear_Trees", action = JBLogging.doClearTrees },
        { condition = hasCuttingTool and clickedFlags.bush, translate = "UI_JBLogging_Menu_Clear_Bushes", action = JBLogging.doClearBushes },
        { condition = hasCuttingTool and clickedFlags.grass, translate = "UI_JBLogging_Menu_Clear_Grass", action = JBLogging.doClearGrass }
    }

    local showMenu = false
    for i = 1, #menuOptions do
        local option = menuOptions[i]
        if option.condition or alwaysShowMenu then
            subMenu:addOption(getText(option.translate), worldObjects, option.action, playerObj)
            showMenu = true
        end
    end

    if showMenu then
        local loggingMenu
        if keepOnTop then
            loggingMenu = context:addOptionOnTop(getText("UI_JBLogging_Menu_Name"))
        else
            loggingMenu = context:insertOptionAfter(getText("ContextMenu_SitGround"), getText("UI_JBLogging_Menu_Name"), worldObjects, nil)
        end
        context:addSubMenu(loggingMenu, subMenu)
    end
end


JBLogging.doInvContextMenu = function(playerIndex, context, items)
    -- this function purposely left blank for future use
    -- items = ISInventoryPane.getActualItems(items)
    return
end

JBLogging.doTreeInfo = function(worldObjects, playerObj)
    JB_ASSUtils.SelectSingleSquare(worldObjects, playerObj, JBLogging.treeInfo)
end

JBLogging.doGatherLogs = function(worldObjects, playerObj)
    JB_ASSUtils.SelectSquareAndArea(worldObjects, playerObj, JBLogging.gatherItems, "Base.Log")
end

JBLogging.doClearTrees = function(worldObjects, playerObj)
    JB_ASSUtils.SelectArea(worldObjects, playerObj, JBLogging.clearTrees)
end

JBLogging.doClearBushes = function(worldObjects, playerObj)
    JB_ASSUtils.SelectArea(worldObjects, playerObj, JBLogging.ClearBushes)
end

JBLogging.doClearGrass = function(worldObjects, playerObj)
    JB_ASSUtils.SelectArea(worldObjects, playerObj, JBLogging.ClearGrass)
end

JBLogging.doGatherTwigsAndBranches = function(worldObjects, playerObj)
    JB_ASSUtils.SelectSquareAndArea(worldObjects, playerObj, JBLogging.gatherTwigsAndBranches)
end

Events.OnFillWorldObjectContextMenu.Add(JBLogging.doWorldContextMenu)
-- Events.OnFillInventoryObjectContextMenu.Add(JBLogging.doInvContextMenu)

return JBLogging
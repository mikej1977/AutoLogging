local function JBLoggingOptions()
    
    local config = {
        checkBox = nil,
        colorPicker = nil,
    }

    local options = PZAPI.ModOptions:create("JBLoggingModOptions", "")

    local colors = { 0.2, 0.5, 0.7, 1 }
    local title = getText("UI_options_JBLogging_Title")
    local desc = string.format("<H1><LEFT><ORANGE> %s",title)

    options:addDescription(desc)
    options:addDescription("<SIZE:SMALL><LEFT>Deforestation Simulator")
    options:addDescription("<H2><LEFT> Menu Options")
    options:addSeparator()

    config.checkBox = options:addTickBox("Always_Show_Menu", getText("UI_options_JBLogging_Always_Show_Menu"), true)
    config.checkBox = options:addTickBox("Keep_Menu_At_Top", getText("UI_options_JBLogging_Keep_Menu_At_Top"), false)

    options:addSeparator()
    options:addDescription("<H2><LEFT> Cursor Options")
    config.colorPicker = options:addColorPicker("Select_Color", getText("UI_options_JBLogging_Select_Color"), colors)
    options:addSeparator()

end

return JBLoggingOptions()
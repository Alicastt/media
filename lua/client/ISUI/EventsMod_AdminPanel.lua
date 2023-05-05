require "ISUI/ISAdminPanelUI"

EventsMod_Override = {}
EventsMod_Override.ISAdminPanelUI = {}
EventsMod_Override.ISAdminPanelUI.create = ISAdminPanelUI.create


local function UpdateJsons()
    local player = getPlayer()
    sendClientCommand(player, "EventsMod", "UpdateJsons", {})

    
    player:Say("Updated Vehicles JSON")

end



function ISAdminPanelUI:create()

    local y = 210
    local btnWid = 180
    local btnHgt = 30

    self.updateEventsModJsons = ISButton:new(btnWid, y, btnWid, btnHgt, getText("IGUI_AdminPanel_UpdateEventsModJsons"), self, UpdateJsons)
    self.updateEventsModJsons:initialise()
    self.updateEventsModJsons:instantiate()
    self.updateEventsModJsons.borderColor = self.buttonBorderColor
    self:addChild(self.updateEventsModJsons)
    self.updateEventsModJsons.tooltip = getTextOrNull("IGUI_AdminPanel_TooltipUpdateEventsModJsons")


    -- print("DEBUG")
    -- print("y = " .. y)
    -- print("btnWid = " .. btnWid)
    -- print("10 + btwWid + 20 = " .. tostring(10 + btnWid + 20))
    -- print("btnHgt = " .. btnHgt)

    EventsMod_Override.ISAdminPanelUI.create(self)
end



require "ISUI/ISAdminPanelUI"

DMM_Override = {}
DMM_Override.ISAdminPanelUI = {}
DMM_Override.ISAdminPanelUI.create = ISAdminPanelUI.create


local function UpdateJsons()
    local player = getPlayer()
    sendClientCommand(player, "DMM", "UpdateJsons", {})

    
    player:Say("Updated Vehicles JSON")

end



function ISAdminPanelUI:create()

    local y = 210
    local btnWid = 180
    local btnHgt = 30

    self.updateDmmJsons = ISButton:new(btnWid, y, btnWid, btnHgt, getText("IGUI_AdminPanel_UpdateDmmJsons"), self, UpdateJsons)
    self.updateDmmJsons:initialise()
    self.updateDmmJsons:instantiate()
    self.updateDmmJsons.borderColor = self.buttonBorderColor
    self:addChild(self.updateDmmJsons)
    self.updateDmmJsons.tooltip = getTextOrNull("IGUI_AdminPanel_TooltipUpdateDmmJsons")


    -- print("DEBUG")
    -- print("y = " .. y)
    -- print("btnWid = " .. btnWid)
    -- print("10 + btwWid + 20 = " .. tostring(10 + btnWid + 20))
    -- print("btnHgt = " .. btnHgt)

    DMM_Override.ISAdminPanelUI.create(self)
end



-- Import section
Widget = require("api.gui.widget")
Colors = require("graphics.colors")

local multiBlockAddresses = require("config.addresses.multi-blocks")
local getMultiblockStatus = require("domain.multiblock.get-multiblock-status-usecase")
local toggleMultiblockWork = require("domain.multiblock.toggle-multiblock-work")

--

--[[
|gla| overview  |
|wid| w | w | w |
|hel| w | w | w |
|sto| w | w | w |
|not| power |b|f|
--]]
local overview = {
    title = "Overview",
    pageIndex = 1,
    widgets = {
        active = {}
    }
}
local machinesNotFound = {}

local function createMachineWidget(address, name)
    local function update(self, statuses)
        local status = statuses.machineStatus.multiblockStatus[address]

        if not status then
            machinesNotFound[address] = "not found"
            local nMachinesNotFound = 0
            for _, _ in pairs(machinesNotFound) do
                nMachinesNotFound = nMachinesNotFound + 1
            end

            Term.setCursor(1, 1)
            Term.gpu().setBackground(Colors.black)
            Term.gpu().setForeground(Colors.errorColor)
            print("Failed to find the machine " .. address .. ". " .. nMachinesNotFound .. " machines not found.")

            return
        end

        machinesNotFound[address] = nil
        for key, value in pairs(status) do
            self[key] = value
        end
    end

    local function onClick(self)
        toggleMultiblockWork(address, self.name)
    end

    local machineWidget = {
        name = name,
        type = Widget.types.MULTIBLOCK,
        update = update,
        onClick = onClick,
        getMiddleString = function()
        end,
        draw = Widget.draw
    }

    machineWidget:update({machineStatus = {multiblockStatus = {[address] = getMultiblockStatus(address, name)}}})

    return machineWidget
end

for name, address in pairs(multiBlockAddresses) do
    table.insert(overview.widgets, createMachineWidget(address, name))
end

return overview

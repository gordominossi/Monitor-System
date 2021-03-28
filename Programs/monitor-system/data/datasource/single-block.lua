-- Import section
Parser = require("utils.parser")
Component = require("component")
New = require("utils.new")
Term = require("term")

local mock = require("data.mock.mock-single-block")
--

local SingleBlock = {
    mock = mock,
    name = "SingleBlock"
}

local nMachinesNotFound = 0

function SingleBlock:new(partialAdress, name)
    local machine = {}

    local successfull =
        pcall(
        function()
            machine = New(self, Component.proxy(Component.get(partialAdress)))
        end
    )
    if (not successfull) then
        nMachinesNotFound = nMachinesNotFound + 1
        Term.setCursor(1, 1)
        print("Failed to find the machine " .. partialAdress .. ". Failed " .. nMachinesNotFound .. " times.")
        machine = New(self, self.mock:new(partialAdress, name))
    end

    return machine
end

function Parser.parseProgress(progressString)
    local current = string.sub(progressString, string.find(progressString, "%ba§"))
    current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

    local maximum = string.sub(progressString, string.find(progressString, "%be§", (string.find(progressString, "/"))))
    maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

    return {current = current, maximum = maximum}
end

function SingleBlock:getNumberOfProblems()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseProblems(sensorInformation[5])
end

function SingleBlock:getProgress()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseProgress(sensorInformation[1])
end

function SingleBlock:getEfficiencyPercentage()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseEfficiency(sensorInformation[5])
end

function SingleBlock:getEnergyUsage() -- EU/t
    local maxProgress = self:getWorkMaxProgress() or 0
    if maxProgress > 0 then
        local sensorInformation = self:getSensorInformation()
        return Parser.parseProbablyUses(sensorInformation[3])
    else
        return 0
    end
end

return SingleBlock

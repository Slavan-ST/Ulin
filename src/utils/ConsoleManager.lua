-- src/utils/ConsoleManager.lua
local ConsoleManager = {
    commands = {},
    commandHistory = {},
    historyIndex = 0
}


-- Локальная функция для обрезки пробелов
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function ConsoleManager:registerCommand(name, description, handler)
    assert(type(name) == "string", "Command name must be a string")
    assert(not self.commands[name], "Command '"..name.."' already exists")
    
    self.commands[name] = {
        desc = description,
        exec = handler,
        name = name
    }
end

function ConsoleManager:execute(input)
    local DebugLog = require("src.utils.debuglog")
    DebugLog.print("> start")
    if not input or trim(input) == "" then 
        return false, "Empty command" 
    end
    
    DebugLog.print("> normal")
    -- Нормализация ввода
    input = trim(input:gsub("%s+", " "))
    table.insert(self.commandHistory, input)
    self.historyIndex = #self.commandHistory + 1

    local parts = {}
    for part in input:gmatch("%S+") do
        table.insert(parts, part)
    end

    local cmdName = parts[1]
    local cmd = self.commands[cmdName]
    
    DebugLog.print("> main execute")
    if not cmd then
        local suggestions = {}
        for name in pairs(self.commands) do
            if name:find(cmdName or "") then
                table.insert(suggestions, name)
            end
        end
        local suggestionText = #suggestions > 0 and "\nDid you mean: "..table.concat(suggestions, ", ") or ""
        return false, "Unknown command: "..(cmdName or "")..suggestionText
    end

    table.remove(parts, 1) -- Удаляем имя команды

    local success, result = pcall(function()
        return cmd.exec(unpack(parts))
    end)

    if not success then
        return false, "Error: "..result.."\nUsage: "..cmd.name.." "..cmd.desc
    end

    return true, result
end




function ConsoleManager:getHistory(offset)
    self.historyIndex = math.max(1, math.min(#self.commandHistory, self.historyIndex + offset))
    return self.commandHistory[self.historyIndex] or ""
end

-- Базовая команда help
ConsoleManager:registerCommand("help", "Show help [command]", function(cmdName)
    if cmdName then
        local cmd = self.commands[cmdName]
        if not cmd then return "Command not found" end
        return string.format("%s - %s\nUsage: %s %s", 
               cmd.name, cmd.desc, cmd.name, cmd.desc)
    end

    local result = {"Available commands:"}
    for _, cmd in pairs(self.commands) do
        table.insert(result, string.format("%-10s - %s", cmd.name, cmd.desc))
    end
    return table.concat(result, "\n")
end)

return ConsoleManager
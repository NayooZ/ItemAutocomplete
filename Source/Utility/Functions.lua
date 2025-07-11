select(2, ...) 'Utility.Functions'

-- Imports
local utf8 = require 'Shared.UTF8'

------------------------------------------
-- Constants
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local GetNumAddOns = C_AddOns.GetNumAddOns or GetNumAddOns
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded;
local IsAddOnLoadOnDemand = C_AddOns.IsAddOnLoadOnDemand or IsAddOnLoadOnDemand;
local GetAddOnInfo = C_AddOns.GetAddOnInfo or GetAddOnInfo
local GetAddOnDependencies = C_AddOns.GetAddOnDependencies or GetAddOnDependencies
------------------------------------------

local addonName = select(1, ...)

------------------------------------------
-- Exports
------------------------------------------

-- Returns the addon's name
function export.GetAddonName()
  return addonName
end

-- Returns a field's value from the addon's meta data
function export.GetAddonMetadata(field)
  return GetAddOnMetadata(addonName, field)
end

-- Prints an addon message to the default chat frame
function export.PrettyPrint(...)
  local args = table.concat({ ... }, ' ')
  local message = string.format('|cFFFFA500[%s]|r: %s', addonName, args)
  DEFAULT_CHAT_FRAME:AddMessage(message)
end

-- Dumps a value to console
local function Dump(table, indent)
  if not indent then
    indent = 0
  end

  for k, v in pairs(table) do
    local formatting = string.rep('  ', indent) .. k .. ': '

    if type(v) == 'table' then
      print(formatting)
      Dump(v, indent + 1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

export.Dump = Dump

-- Registers an in-game slash command
function export.RegisterSlashCommand(command, callback)
  local identifier = (addonName .. '_' .. command):upper()
  _G['SLASH_' .. identifier .. '1'] = '/' .. command
  _G.SlashCmdList[identifier] = callback
end

-- Returns whether the current client is WOTLK or not
function export.IsWotlk()
  return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MISTS_CLASSIC
end

-- Returns whether the current client is Season of Mastery or not
function export.IsSom()
  return C_Seasons ~= nil and C_Seasons.HasActiveSeason() and
           (C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfMastery)
end

-- Returns whether the current client is Season of Discovery or not
function export.IsSod()
  return C_Seasons ~= nil and C_Seasons.HasActiveSeason() and
           (C_Seasons.GetActiveSeason() == Enum.SeasonID.Placeholder)
end

-- Merges zero or more tables
function export.Merge(...)
  local output = {}

  for _, targ in ipairs({ ... }) do
    for key, value in pairs(targ) do
      output[key] = value
    end
  end

  return output
end

-- Returns true if a string is nil or empty
function export.IsNilOrEmpty(string)
  return string == nil or string == ''
end

-- Returns a read only version of a table
function export.ReadOnly(table)
  return setmetatable({}, {
    __index = table,
    __newindex = function()
      error('Attempt to modify read-only table')
    end,
    __metatable = false,
  })
end

-- Returns a table which exposes context bound methods
function export.ContextBinder(context)
  return setmetatable({}, {
    __index = function(self, key)
      local method = context[key]

      if type(method) ~= 'function' then
        error('Unknown method ' .. key)
      end

      self[key] = function(...)
        return method(context, ...)
      end

      return rawget(self, key)
    end,
    __metatable = false,
  })
end

-- Returns whether a string contains uppercase or not
function export.ContainsUppercase(text)
  for _, codePoint in utf8.CodePoints(text) do
    if utf8.IsUpperCaseLetter(codePoint) then
      return true
    end
  end
  return false
end

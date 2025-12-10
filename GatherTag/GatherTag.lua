-- GatherTag.lua
local addonName, GatherTag = ...
local G = {}
local frame = CreateFrame("Frame")
frame:Hide()

-- 本插件版本
local ADDON_VERSION = "0.1.0"

local NODE_TYPE_MINE = "MINE"
local NODE_TYPE_HERB = "HERB"
local NODE_TYPE_GAS  = "GAS"

GatherTag.NODE_TYPE_MINE = NODE_TYPE_MINE
GatherTag.NODE_TYPE_HERB = NODE_TYPE_HERB
GatherTag.NODE_TYPE_GAS = NODE_TYPE_GAS

local EventListeners = {}

local string = string
local table = table
local ipairs = ipairs
local pairs = pairs
local print = print
local tostring = tostring
local C_Map = C_Map

local function dumpTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dumpTable(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
--============= Function =============--

local function APICheck()
  local result = true
  local invalidFuns = "GatherTag: 错误：当前游戏版本不支持 "
  -- 检测 C_Map API
  if not C_Map then
    invalidFuns = invalidFuns .. "C_Map "
    result = false
  elseif not C_Map.GetBestMapForUnit then
    invalidFuns = invalidFuns .. "C_Map.GetBestMapForUnit "
    result = false
  elseif not C_Map.GetPlayerMapPosition then
    invalidFuns = invalidFuns .. "C_Map.GetPlayerMapPosition "
    result = false
  elseif not C_Map.GetMapInfo then
    invalidFuns = invalidFuns .. "C_Map.GetMapInfo "
    result = false
  end

  if not result then
    print(invalidFuns)
  end

  return result
end

local function HandlePlayerLogin()
  -- print("GatherTag: 初始化")
  -- 初始化保存变量
  if not GatherTagDB then 
    GatherTagDB = {
      profile = { enabled = true,},
      version = ADDON_VERSION,
    } 
  end
  GatherTagHerbDB = GatherTagHerbDB or {}
  GatherTagMineDB = GatherTagMineDB or {}
  GatherTagGasDB = GatherTagGasDB or {}

  GatherTag.NodeDB = {
    [NODE_TYPE_MINE] = GatherTagMineDB,
    [NODE_TYPE_HERB] = GatherTagHerbDB,
    [NODE_TYPE_GAS] = GatherTagGasDB,
  }

  GatherTag.trace = false
end

-- ZONE_CHANGED_NEW_AREA 事件可能会触发多次，例如出副本或者跨大陆、跨世界切换
-- 会遵循进入大陆触发一次，进入地区触发一次，不过这个不影响我们的处理。
-- 只是会在我们数据中保存一些空表，比如(1415)东部王国，会包含一个key为 1415 的空表
-- 当然也可以通过进一步调用 C_Map.GetMapInfo 获取地图信息，根据返回值中的 mapType 来判断，只是似乎没这个必要
local function HandleAreaChanged()
  -- 更新当前地图 ID
  local mapID = C_Map.GetBestMapForUnit("player")

  -- 进入副本时可能会出现获取不到地图ID的情况.
  if not mapID then
    return
  end

  -- print("GatherTag: 进入(", mapID, ")", C_Map.GetMapInfo(mapID).name)

  GatherTag.currentMapID = mapID

  GatherTagHerbDB[mapID] = GatherTagHerbDB[mapID] or {}
  GatherTagMineDB[mapID] = GatherTagMineDB[mapID] or {}
  GatherTagGasDB[mapID] = GatherTagGasDB[mapID] or {}

  -- print("GatherTag: 当前地图资源点数量 ->", #(GatherTag:GetNodesByMapID(mapID)))

  -- 如果世界地图正在显示，刷新它
  if WorldMapFrame:IsVisible() then
    -- print("GatherTag: World map is visible, triggering refresh")
    WorldMapFrame:RefreshAll()
  end
end

function GatherTag:Initialize()
  -- 注册事件监听
  GatherTag:RegisterEvent("PLAYER_LOGIN", HandlePlayerLogin)
  GatherTag:RegisterEvent("PLAYER_ENTERING_WORLD", HandleAreaChanged)
  GatherTag:RegisterEvent("ZONE_CHANGED_NEW_AREA", HandleAreaChanged)
  frame:SetScript("OnEvent", function(self, event, ...)
    for _, cb in ipairs(EventListeners[event]) do
      cb(...)
    end
  end)
  -- print("GatherTag: 初始化完成")
end

function GatherTag:RegisterEvent(event, callback)
  if not EventListeners[event] then
    EventListeners[event] = {}
  end
  table.insert(EventListeners[event], callback)  
  frame:RegisterEvent(event)  
end

-- 从数组中移除指定元素
local function RemoveElementFromArray(array, element)
  for i, v in ipairs(array) do
    if v == element then
      table.remove(array, i)
      break
    end
  end
end
function GatherTag:UnregisterEvent(event, callback)
  if not callback then
    print("GatherTag: UnregisterEvent 缺少回调函数")
    return
  end
  if EventListeners[event] then
    RemoveElementFromArray(EventListeners[event], callback)
    if #EventListeners[event] == 0 then
      frame:UnregisterEvent(event)
      EventListeners[event] = nil
    end
  end
end

GatherTag.LEVEL = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}

function GatherTag.Logger( msg, level )
  if GatherTag.trace then
    local levelColor = {"ffcccccc", "ffffffff", "ffffff00", "ffff0000"}

    local l = tonumber(level) or GatherTag.LEVEL.INFO
    local color = levelColor[level] or levelColor[2]
    print("|cFF00FF00GatherTag:|r|c"..color..msg.."|r")
  end
end

--======================== SlashCmdList Function =========================

function GatherTag.PrintUsage()
  print("|cFF00FF00GatherTag 命令帮助:|r")
  print("/gathertag - 显示帮助信息")
  print("/gathertag count - 显示当前地图采集点数量")
  print("/gathertag on  - 打开世界地图上的采集点的显示")
  print("/gathertag off - 关闭世界地图上的采集点的显示")
  print("/gathertag help - 显示帮助信息")
end

-- 显示当前地图的采集点数量
function GatherTag.PrintCurrentMapNodeInfo()
  local count = 0;
  count = count + #GatherTagMineDB[GatherTag.currentMapID]
  count = count + #GatherTagHerbDB[GatherTag.currentMapID]
  count = count + #GatherTagGasDB[GatherTag.currentMapID]
  local mapInfo = C_Map.GetMapInfo(GatherTag.currentMapID)
  local mapName = mapInfo and mapInfo.name or "未知地图"
  print("|cFF00FF00GatherTag:|r 当前地图 (" .. GatherTag.currentMapID .. ")" .. mapName .. ") 采集点数量: " .. count)
  return count
end

-- on 打开采集点显示， off 关闭采集点显示。
function GatherTag.EnableShowNode(args)
  local enable = args[1] == "on"
  GatherTagCharCfgDB.trace[NODE_TYPE_MINE] = enable
  GatherTagCharCfgDB.trace[NODE_TYPE_HERB] = enable
  GatherTagCharCfgDB.trace[NODE_TYPE_GAS] = enable

  if WorldMapFrame:IsVisible() then
    WorldMapFrame:RefreshAll()
  end
  local switch = enable and "打开" or "关闭"
  print("|cFF00FF00GatherTag:|r "..switch.." 采集点显示")
end

-- clear 清除当前地图所有采集点， clear all 清除所有地图所有采集点
function GatherTag.ClearNode(args)
  local isAllClear = args[2] and args[2] == "all"
  if isAllClear then
    GatherTagMineDB = {}
    GatherTagHerbDB = {}
    GatherTagGasDB = {}
    GatherTag.NodeDB = {
      [NODE_TYPE_MINE] = GatherTagMineDB,
      [NODE_TYPE_HERB] = GatherTagHerbDB,
      [NODE_TYPE_GAS] = GatherTagGasDB,
    }
    print("|cFFFF0000GatherTag:|r 已清除所有地图的采集点数据")
  else
    GatherTagMineDB[GatherTag.currentMapID] = {}
    GatherTagHerbDB[GatherTag.currentMapID] = {}
    GatherTagGasDB[GatherTag.currentMapID] = {}
    print("|cFFFFFF00GatherTag:|r 已清除当前地图的采集点数据")
  end

  if WorldMapFrame:IsVisible() then
    WorldMapFrame:RefreshAll()
  end
end

function GatherTag.Debug( args )
  GatherTag.trace = not GatherTag.trace
  print("|cFF00FF00GatherTag:|r 调试功能 " .. (GatherTag.trace and "打开" or "关闭"))
end

local SLASH_COMMAND_FUNCTIONS = {
  ["count"] = GatherTag.PrintCurrentMapNodeInfo,
  ["on"] = GatherTag.EnableShowNode,
  ["off"] = GatherTag.EnableShowNode,
  ["clear"] = GatherTag.ClearNode,
  ["debug"] = GatherTag.Debug,
  ["help"] = GatherTag.PrintUsage,
}

GatherTag:Initialize()

-- 注册斜杠命令
local function SplitString(text, regex)
  local result = {}
  for w in string.gmatch(text, regex) do
    table.insert(result, w)
  end
  return result
end
local function HandleSlashCommand(msg)
  local args = SplitString(string.lower(msg), "%S+")
  local command = args[1] or "help"
  
  if SLASH_COMMAND_FUNCTIONS[command] then
    SLASH_COMMAND_FUNCTIONS[command](args)
  else
    GatherTag.PrintUsage()
  end
end

_G.SLASH_GATHERTAG1 = "/gathertag"
_G.SLASH_GATHERTAG2 = "/gt"
SlashCmdList["GATHERTAG"] = HandleSlashCommand

-- 导出公共接口表，方便将来扩展或被其他文件引用
-- _G.GatherTag = G

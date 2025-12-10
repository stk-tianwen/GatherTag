
local _, GatherTag = ...

local Collector = {}
GatherTag.Collector = Collector

local pairs = pairs
local tonumber = tonumber
local string = string
local print = print
local time = time
local abs = math.abs

local C_Map = C_Map

local LEVEL = GatherTag.LEVEL
local Logger = GatherTag.Logger

local NODE_TYPE_MINE = GatherTag.NODE_TYPE_MINE
local NODE_TYPE_HERB = GatherTag.NODE_TYPE_HERB
local NODE_TYPE_GAS = GatherTag.NODE_TYPE_GAS

-- 白名单条目（优先使用这些物品的图标作为采集标记图标）
-- [itemID] = {nodeType, iconID}
local ITEM_WHITELIST = {
	-- 矿
  [2770] = {nodeType = NODE_TYPE_MINE, icon = 134566},  -- Copper Ore (铜矿石)
  [2771] = {nodeType = NODE_TYPE_MINE, icon = 134579},  -- Tin Ore (锡矿石)
  [2772] = {nodeType = NODE_TYPE_MINE, icon = 134572},  -- Iron Ore (铁矿石)
  [2775] = {nodeType = NODE_TYPE_MINE, icon = 135242},  -- Silver Ore (银矿石)
  [2776] = {nodeType = NODE_TYPE_MINE, icon = 134571},  -- Gold Ore (金矿石)
  [3858] = {nodeType = NODE_TYPE_MINE, icon = 134576},  -- Mithril Ore (秘银矿石)
  [7911] = {nodeType = NODE_TYPE_MINE, icon = 134580},  -- Truesilver Ore (真银矿石)
  [10620] = {nodeType = NODE_TYPE_MINE, icon = 134578}, -- Thorium Ore (瑟银矿石)
  [23424] = {nodeType = NODE_TYPE_MINE, icon = 134569}, -- Fel Iron Ore ( 魔铁矿石 )
  [23425] = {nodeType = NODE_TYPE_MINE, icon = 134561}, -- Adamantite Ore (精金矿石)
  [23426] = {nodeType = NODE_TYPE_MINE, icon = 134573}, -- Khorium Ore (氪金矿石)
  -- [23427] = {29354, 134566}, -- Eternium Ore (恒金矿石) 是伴生矿
  [11370] = {nodeType = NODE_TYPE_MINE, icon = 134575}, -- Dark Iron Ore (黑铁矿石)
  [36909] = {nodeType = NODE_TYPE_MINE, icon = 134565}, -- Cobalt Ore (钴矿石)
  [36910] = {nodeType = NODE_TYPE_MINE, icon = 237426}, -- Titanium Ore (泰坦神铁矿石)
  [36912] = {nodeType = NODE_TYPE_MINE, icon = 237437}, -- Saronite Ore (萨隆邪铁矿石)

	-- 草药
	[2447] = {nodeType = NODE_TYPE_HERB, icon = 133939}, -- 宁神花
	[765] = {nodeType = NODE_TYPE_HERB, icon = 134190}, -- 银叶草
	[2449] = {nodeType = NODE_TYPE_HERB, icon = 134187}, -- 地根草
	[785] = {nodeType = NODE_TYPE_HERB, icon = 134436}, -- 魔皇草
	[2450] = {nodeType = NODE_TYPE_HERB, icon = 134412}, -- 石楠草
	-- [2452] = {nodeType = NODE_TYPE_HERB, icon = 134184}, -- 雨燕草，伴生草
	[3820] = {nodeType = NODE_TYPE_HERB, icon = 134191}, -- 荆棘藻
	[2453] = {nodeType = NODE_TYPE_HERB, icon = 134181}, -- 跌打草
	[3355] = {nodeType = NODE_TYPE_HERB, icon = 133938}, -- 野钢花
	[3356] = {nodeType = NODE_TYPE_HERB, icon = 134183}, -- 皇血草
	[3357] = {nodeType = NODE_TYPE_HERB, icon = 134413}, -- 活根草
	[3358] = {nodeType = NODE_TYPE_HERB, icon = 134188}, -- 卡德加的胡须
	[3369] = {nodeType = NODE_TYPE_HERB, icon = 133849}, -- 墓地苔
	[3818] = {nodeType = NODE_TYPE_HERB, icon = 134193}, -- 枯叶草
	[3819] = {nodeType = NODE_TYPE_HERB, icon = 133940}, -- 冬刺草
	[3821] = {nodeType = NODE_TYPE_HERB, icon = 134196}, -- 金棘草
	[4625] = {nodeType = NODE_TYPE_HERB, icon = 134200}, -- 火焰花
	-- [8153] = {nodeType = NODE_TYPE_HERB, icon = 134183}, -- 野葡萄藤，伴生和掉落？和皇血草的图标是一样的，在游戏里是增加了一个绿色的边框
	[8831] = {nodeType = NODE_TYPE_HERB, icon = 134198}, -- 紫莲花
	[8836] = {nodeType = NODE_TYPE_HERB, icon = 134194}, -- 阿尔萨斯之泪
	[8838] = {nodeType = NODE_TYPE_HERB, icon = 134199}, -- 太阳花
	[8839] = {nodeType = NODE_TYPE_HERB, icon = 134195}, -- 盲目草
	[8845] = {nodeType = NODE_TYPE_HERB, icon = 134529}, -- 幽灵菇
	[8846] = {nodeType = NODE_TYPE_HERB, icon = 134197}, -- 格罗姆之血
	[13463] = {nodeType = NODE_TYPE_HERB, icon = 134204}, -- 梦叶草
	[13464] = {nodeType = NODE_TYPE_HERB, icon = 134221}, -- 黄金参
	[13465] = {nodeType = NODE_TYPE_HERB, icon = 134215}, -- 山鼠草
	[13466] = {nodeType = NODE_TYPE_HERB, icon = 134219}, -- 天灾花
	[13467] = {nodeType = NODE_TYPE_HERB, icon = 134212}, -- 冰盖草
	-- [13468] = {nodeType = NODE_TYPE_HERB, icon = 134202}, -- 黑莲花，伴生草药
	[22785] = {nodeType = NODE_TYPE_HERB, icon = 134208}, -- 魔草
	[22786] = {nodeType = NODE_TYPE_HERB, icon = 134205}, -- 梦露花
	[22787] = {nodeType = NODE_TYPE_HERB, icon = 134220}, -- 邪雾草
	[22789] = {nodeType = NODE_TYPE_HERB, icon = 134223}, -- 泰罗果
	[22790] = {nodeType = NODE_TYPE_HERB, icon = 134201}, -- 远古苔
	[22791] = {nodeType = NODE_TYPE_HERB, icon = 134216}, -- 虚空花
	[22792] = {nodeType = NODE_TYPE_HERB, icon = 134218}, -- 噩梦藤
	[22793] = {nodeType = NODE_TYPE_HERB, icon = 134214}, -- 法力蓟
	[22794] = {nodeType = NODE_TYPE_HERB, icon = 134207}, -- 魔莲花
	[36901] = {nodeType = NODE_TYPE_HERB, icon = 134211}, -- 金苜蓿
	[36903] = {nodeType = NODE_TYPE_HERB, icon = 237376}, -- 蛇信草
	[36904] = {nodeType = NODE_TYPE_HERB, icon = 134224}, -- 卷丹
	[36905] = {nodeType = NODE_TYPE_HERB, icon = 134225}, -- 巫妖花
	[36906] = {nodeType = NODE_TYPE_HERB, icon = 134213}, -- 冰棘草
	[36907] = {nodeType = NODE_TYPE_HERB, icon = 134222}, -- 塔兰德拉的玫瑰
	-- [36921] = {nodeType = NODE_TYPE_HERB, icon = 237191}, -- 死亡荨麻
	[36921] = {nodeType = NODE_TYPE_HERB, icon = 237191}, -- 死亡荨麻
	[36908] = {nodeType = NODE_TYPE_HERB, icon = 134210}, -- 雪莲花

  -- 元素微粒
  [22572] = {nodeType = NODE_TYPE_GAS, icon = 132837}, -- (空气微粒)
  --[22573] = {nodeType = ‘other’, icon = 132838}, -- 土之微粒是采矿伴生的，不能通过提炼气团获得，所以不处理
  [22574] = {nodeType = NODE_TYPE_GAS, icon = 132839}, -- (火焰微粒)
  --[22575] = {nodeType = ‘other’, icon = 132840}, -- 生命微粒是采药伴生的，不能通过提炼气团获得，所以不处理
  [22577] = {nodeType = NODE_TYPE_GAS, icon = 132843}, -- (暗影微粒)
  [22578] = {nodeType = NODE_TYPE_GAS, icon = 132844}, -- (水之微粒)

  ---- 诺森德的结晶可以是矿和草药的伴生，也可以是采集气体获得
  [37700] = {nodeType = NODE_TYPE_GAS, icon = 237001}, -- 空气结晶
  --[37701] = {nodeType = "Other", icon = 237002}, -- 土之结晶，采矿伴生。没有气团
  [37702] = {nodeType = NODE_TYPE_GAS, icon = 237003}, -- (火焰结晶)
	[37703] = {nodeType = NODE_TYPE_GAS, icon = 237005}, -- 暗影结晶
  [37705] = {nodeType = NODE_TYPE_GAS, icon = 237006}, -- (水之结晶)
}

-- 各类资源的采集技能 spellID 列表
local GATHER_SPELL_IDS = {
  [NODE_TYPE_MINE] = {
		[2575] = true, -- 采矿 初级
		[2576] = true, -- 采矿 中级
		[3564] = true, -- 采矿 高级
		[10248] = true, -- 采矿 专家级
		[29354] = true, -- 采矿 大师级
		[50310] = true, -- 采矿(宗师级)
	},
	[NODE_TYPE_HERB] = {
		[2366] = true, -- 采药 初级
		[2368] = true, -- 采药 中级
		[2369] = true, -- 采药 高级
		[2371] = true, -- 采药 专家级
		[3570] = true, -- 采药 大师级
		[11993] = true, -- 采药(宗师级)
	},
	[NODE_TYPE_GAS] = {
  	[30427] = true, -- 提炼气体
	},
  -- [7731] = true, -- 钓鱼
}

-- 寻找草药
local SPELL_FIND_HERB = 2383

local cachePin = nil

local MIN_SAME_DIST = 0.01
function Collector:AddNode(nodeType, node)
  Logger("" .. nodeType .. node.x .. node.y .. GatherTag.currentMapID, LEVEL.DEBUG)

  local nodes = GatherTag.NodeDB[nodeType][GatherTag.currentMapID]
  -- print("GatherTag: 资源点数量 ->", #nodes)
  -- 检查是否已经存在相同位置的标记
  for i, p in ipairs(nodes) do
    if abs(node.x - p.x) < MIN_SAME_DIST and abs(node.y - p.y) < MIN_SAME_DIST then
      nodes[i] = node
      return
    end
  end

  nodes[#nodes + 1] = node
  Logger("添加后资源点数量 ->" .. #nodes, LEVEL.INFO)
end

local function GetNodeTypeBySpellID(spellID)
  for key, value in pairs(GATHER_SPELL_IDS) do
		if value[spellID] then
			return key
		end
	end
	return nil
end

local function HandleUnitSpellcastSucceeded(_, _, spellID)
	Logger("UNIT_SPELLCAST_SUCCEEDED (" .. spellID .. ")" .. GetSpellInfo(spellID), LEVEL.DEBUG)
	local nodeType = GetNodeTypeBySpellID(spellID)
  if nodeType then
    -- 获取当前地图 ID
    local mapID = C_Map.GetBestMapForUnit("player")
    -- 获取当前地图位置
    local mapPosition = C_Map.GetPlayerMapPosition(mapID, "player")

		-- 如果没有获取到地图位置(比如玩家在副本中，可能没有地图信息)，则返回
		if not mapPosition then
			return
		end

    local time = time()
    -- print("GatherTag: 获取当前地图信息 ->", mapID, mapInfo.name, mapInfo.parentMapID, mapInfo.mapType, mapPosition.x, mapPosition.y, time)
    local x, y = mapPosition:GetXY()
    cachePin = {
      x = x,
      y = y,
      time = time,
			nodeType = nodeType,
    }
		
    Logger("UNIT_SPELLCAST_SUCCEEDED (" .. spellID .. ")" .. GetSpellInfo(spellID), LEVEL.DEBUG)
  end
end

-- 
local function HandleChatMsgLoot(text)
  -- 在采矿时系统消息是“你得到了物品|cffffffff|Hitem:2770:0:0:0:0:0:0:0:70|h[铜矿石]|h|rx2。” 这里是“你得到了”
	-- 在提炼气团的时候消息是“你获得了物品|cffffffff|Hitem:36909:0:0:0:0:0:0:0:70|h[空气微粒]|h|rx2。” 这里是“你获得了”
  -- 如果要适配更多采集类型和适配多语言，就需要采取更宽泛的匹配模式。
	Logger(text:gsub("|", "||"))
  local itemID = tonumber(string.match(text, "^你.-了.-Hitem:(%d+)"))
  Logger(itemID, LEVEL.DEBUG)
  local item = ITEM_WHITELIST[itemID]
  Logger("item type:" .. (item and item.nodeType or "nil") .. " cachePin.nodeType: ".. (cachePin and cachePin.nodeType or "nil"), LEVEL.DEBUG)
  if itemID and item and cachePin and cachePin.nodeType == item.nodeType then
    cachePin.itemID = itemID
    cachePin.itemIcon = item.icon
    Collector:AddNode(cachePin.nodeType, cachePin)

    cachePin = nil
  end
end

local function HandleChatMsgSytem(...)
  local text = ...
  -- print("CHAT_MSG_SYSTEM: ", text)
	-- print("CHAT_MSG_SYSTEM: 参数数量 ", select("#", ...))
end


--============= Event Listeners =============--
local EVENT_LISTENERS = {
  -- 采集相关事件（采矿/采药检测）
  ["UNIT_SPELLCAST_SUCCEEDED"] = HandleUnitSpellcastSucceeded,
  ["CHAT_MSG_LOOT"] = HandleChatMsgLoot,
  ['CHAT_MSG_SYSTEM'] = HandleChatMsgSytem
}

for event, handler in pairs(EVENT_LISTENERS) do
  GatherTag:RegisterEvent(event, handler)
end

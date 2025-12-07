-- GatherTag_Display.lua
local _, GatherTag = ...

-- function alias ------------------------
local ipairs = ipairs
local pairs = pairs
local time = time
local tostring = tostring
local math = math
local print = print

local CreateFromMixins = CreateFromMixins

-- 创建显示模块
local Display = {}
GatherTag.Display = Display

-- 返回相对时间的友好字符串（中文）
local function TimeSince(ts)
	if not ts then return "未知" end
	local diff = time() - ts
	if diff < 5 then return "刚刚" end
	if diff < 60 then return tostring(math.floor(diff)) .. "秒前" end
	if diff < 3600 then return tostring(math.floor(diff / 60)) .. "分钟前" end
	if diff < 86400 then return tostring(math.floor(diff / 3600)) .. "小时前" end
	return tostring(math.floor(diff / 86400)) .. "天前"
end

function Display:GetNodesByMapID(mapID)
  local nodes = {}
  for key, db in pairs(GatherTag.NodeDB) do
    if GatherTagCharCfgDB.trace[key] == true then
      local resourceNodes = db[mapID] or {}
      for _, node in ipairs(resourceNodes) do
        nodes[#nodes + 1] = node
      end
    end
  end

  return nodes
end
------------------------------------ WorldMapDataProvider ------------------------------------

Display.WorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin)

function Display.WorldMapDataProvider:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("GatherTagPinTemplate")
end

function Display.WorldMapDataProvider:RefreshAllData(fromOnShow)
	local map = self:GetMap()
	local uiMapID = map:GetMapID()
	local nodes = Display:GetNodesByMapID(uiMapID)

	-- 清除现有的标记
	self:RemoveAllData()

	-- 添加采集点标记
	for _, pinData in ipairs(nodes) do
		map:AcquirePin("GatherTagPinTemplate", pinData)
	end
	-- print("GatherTag: Refreshed all data. " .. #nodes .. " nodes added")
end

function Display.WorldMapDataProvider:OnMapChanged()
	-- 当地图改变时调用此方法
	-- print("GatherTag: OnMapChanged called")

	-- 调用基类方法确保基本功能正常
	MapCanvasDataProviderMixin.OnMapChanged(self)

	-- 刷新数据以显示新地图的标记
	self:RefreshAllData()
end

--[[ GatherTag WorldMap Pin ]] --
GatherTagPinMixin = CreateFromMixins(MapCanvasPinMixin)

function GatherTagPinMixin:OnLoad()
	-- 创建纹理
	self.texture = self:CreateTexture(nil, "ARTWORK")
	self.texture:SetAllPoints()

	-- 设置帧层级
	self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
	self:SetScalingLimits(1, 1.0, 1.2)
end

function GatherTagPinMixin:OnAcquired(pinData)

	self.pinData = pinData
	-- 设置图标
	self.texture:SetTexture(pinData.itemIcon)

	self:SetPosition(pinData.x, pinData.y)
	-- 启用鼠标交互
	self:EnableMouse(true)

end

function GatherTagPinMixin:OnReleased()
    -- 清理Pin对象的资源
    self.pinData = nil
    if self.texture then
        self.texture:SetTexture(nil)
    end
end

function GatherTagPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText("距上次采集: " .. TimeSince(self.pinData.time))
	GameTooltip:Show()
end

function GatherTagPinMixin:OnMouseLeave()
	GameTooltip:Hide()
end

function GatherTagPinMixin:GetPosition()
	print("GatherTag: Pin GetPosition called")
	if self.pinData then
		return self.pinData.x, self.pinData.y
	end
	return 0, 0
end

function GatherTagPinMixin:OnClick(button)
	-- if button == "RightButton" then
	-- 	print("GatherTag: Right-clicked pin at", self.pinData.x, self.pinData.y)
	-- else
	-- 	print("GatherTag: Left-clicked pin at", self.pinData.x, self.pinData.y)
	-- end
end


function Display:UpdateWorldMap()
	self.WorldMapDataProvider:RefreshAllData()
end

function Display:Init()
	WorldMapFrame:AddDataProvider(Display.WorldMapDataProvider)
end

Display:Init()
-- Config.lua - Configuration Interface
local _, GatherTag = ...

local pairs = pairs
local CreateFrame = CreateFrame

-- 确保在ADDON_LOADED事件之后再创建设置界面
function Config_OnLoad(addonName, ...)
  if not addonName == "GatherTag" then
    return
  end

  GatherTagCharCfgDB = GatherTagCharCfgDB or {
    trace = {
      [GatherTag.NODE_TYPE_MINE] = true,
      [GatherTag.NODE_TYPE_HERB] = true,
      [GatherTag.NODE_TYPE_GAS]  = true,
    }
  }
  
  -- 创建插件设置界面
  GatherTag_CreateConfigPanel()
end

local function AddTraceCheckButtons(parent, relativeTo)
  local buttonWidth = 80
  local gap = 20
  local keys = {[GatherTag.NODE_TYPE_MINE] = "矿点", [GatherTag.NODE_TYPE_HERB] = "草药", [GatherTag.NODE_TYPE_GAS] = "气团"}
  local i = 1
  for k, v in pairs(keys) do 
    local key = k
    local lable = v
    local button = CreateFrame("CheckButton", "GatherTag_Config_trace_"..key, parent, "InterfaceOptionsCheckButtonTemplate")
    button:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", (i-1)*(buttonWidth+gap), -16)
    button.Text:SetText("显示"..lable)
    button:SetChecked(GatherTagCharCfgDB.trace[key])
    button:SetScript("OnClick", function(self)
      GatherTagCharCfgDB.trace[key] = self:GetChecked()
    end)
    button:SetScript("OnShow", function(self)
      self:SetChecked(GatherTagCharCfgDB.trace[key])
    end)
    i = i + 1
  end
end

-- 创建设置面板框架
local function CreateSettingsPanel()
  local frame = CreateFrame("Frame", "GatherTagSettingsPanel", UIParent)
  -- frame:SetSize(400, 300)
  
  -- 添加标题
  local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("GatherTag")
  
  -- 添加描述文本
  local description = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
  description:SetText("请选择需要在地图上显示的资源类型:")
  description:SetJustifyH("LEFT")
  description:SetWidth(350)
  
  AddTraceCheckButtons(frame, description)
  
  return frame
end

function GatherTag_CreateConfigPanel()
  -- 创建一个画布布局的分类
  local settingsFrame = CreateSettingsPanel()
  local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, "GatherTag")
  
  -- 注册分类到插件设置区域
  Settings.RegisterAddOnCategory(category)
end

GatherTag:RegisterEvent("PLAYER_LOGIN", Config_OnLoad)
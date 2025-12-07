PlusLogger = {}

function PlusLogger:Init(options)
  self.options = {
    logLevel = "debug",
    logFrameName = "PlusLogger",
    msgPrefix = "PlusLogger: ",
  }
  local o = options or {}
  for k, v in pairs(o) do
    self.options[k] = v
  end

  local frameName = nil
  local frameIndex = 0
  for i=3, 10 do
    local frameName = GetChatWindow(i)
    if frameName == self.options.logFrameName  or frameName == "" then
      frameIndex = i
      break
    end
  end
  if frameIndex == 0 then
    frameIndex = CreateChatWindow(self.options.logFrameName)
  end
end
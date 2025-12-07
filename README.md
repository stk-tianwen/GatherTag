# GatherTag

GatherTag 是一个魔兽世界资源点标记插件，适配游戏版本 3.80.0。
之前使用过GahterMeta2，但是没有发现魔兽世界时光服3.80.0版本的适配版本，所以自己试着写了一个。
参考了GahterMeta2的结构和代码，非常感谢GatherMeta2插件的作者。插件非常好用。
第一次写插件，以前也没用过Lua，很多代码看不明白。所以采用了不同的标记方法。
这个插件能使用，特别需要感谢通义灵码给了很多帮助 ：）

## 功能特点

- 当前版本只支持矿点、草点、气点资源点标记，其他的鱼点、宝箱还不支持。

## 安装方法

1. 将 `GatherTag` 文件夹放入你的 `World of Warcraft/_classic_titan_/Interface/AddOns/` 目录。
2. 启动游戏并在插件管理中启用 `GatherTag`。

## 使用说明

- 在游戏中输入命令：`/gathertag help` 获取帮助。

## 开发说明

### 项目结构

GatherTag/ 
  ├── GatherTag.toc # 插件信息文件 
  ├── GatherTag.lua # 主程序入口 
  ├── Collector.lua # 数据收集模块 
  ├── Display.lua # 显示模块 
  ├── Config.lua # 配置模块 
  ├── PlusLogger.lua # 日志模块 
  ├── GatherTag.xml # UI定义文件
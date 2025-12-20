VR策划2 GDD
📄 游戏设计文档 (GDD)

项目名称：VR策划2 (Project: VR_Planner_2)

类型：On-Rails Shooter / Arcade / Comedy

视角：第一人称 (First Person)

引擎：Godot Engine 4.x

核心标语："需求已驳回" (Feature: DENIED) —— 用你的物理手段，“解决”那些不靠谱的策划案。


1. 核心概念 (Core Concept)

1.1 设定背景

玩家扮演一名被过度压榨的游戏开发者。在年终上线前的最后冲刺阶段，你进入了公司的“虚拟代码空间”。你的任务是清除那些源源不断涌来的 Bug、糟糕的策划点子和无限蔓延的需求，以保护岌岌可危的“上线日期”。

1.2 核心循环 (Core Loop)

10秒/房间 的极速循环：

1. 滑行 (Rail Move)：摄像机沿轨道自动快速滑行至下一个房间（工位/会议室）。
    
2. 破门 (Breach)：摄像机猛烈撞击/踹开门（屏幕震动 + 巨响）。
    
3. 子弹时间 (Bullet Time)：破门瞬间，时间流速降至 10% (Engine.time_scale = 0.1)。
    
4. 识别与清除 (Identify & Purge)：
    
    - 敌人 (红色)：新的需求、Bug、改动建议 -> 射击销毁。
        
    - 人质 (绿色)：上线日期、服务器、年终奖 -> 绝对不能碰。
        
5. 结算 (Clear)：清空敌人后，恢复正常速度，滑向下一区域。
    

2. 视觉与美术 (Visuals & Art)

风格参考：_Superhot_ x _Mirror's Edge_ x _Cyberpunk Glitch_

2.1 场景 (Environment)

● 色调：纯白/浅灰为主，高曝光，营造一种“无菌开发环境”的压抑感。
    
● 材质：无纹理，强调光影 (SSAO) 和反射。
    
● 物体：低多边形的办公桌、服务器机柜、白板。重要物体（如门框）使用鲜艳的橙色高亮。
    

2.2 角色 (Characters)

● 敌人 (The Scope Creepers)：
    
    - 外观：红色的、破碎的晶体人形。
        
    - 头顶文字（随机）："加个联机"、"换个引擎"、"要五彩斑斓的黑"、"这里再改改"。
        
    - 死亡特效：像玻璃一样炸裂成无数红色碎片 (GPU Particles)。
        
● 人质 (The Assets)：
    
    - 外观：绿色的线框/全息人形，抱头蹲防。
        
    - 头顶文字："稳定版本"、"核心玩法"、"美术资产"。
        

2.3 UI 设计 (Diegetic UI)

● 准星：简单的白色圆点。瞄准敌人时变红并扩散，瞄准人质时变绿并打叉。
    
● GameOver：蓝屏死机 (BSOD) 风格，显示错误代码："FATAL_ERROR: PRODUCER_WON" (致命错误：制作人赢了)。
    

3. 音效设计 (Audio)

● Kick (踹门)：低频重音 + 门锁断裂声。
    
● Shoot (射击)：类似订书机按下 + 机械键盘青轴的混合音效，短促有力。
    
● Shatter (击杀)：极度清脆的玻璃破碎声（爽感来源）。
    
● Voice (语音)：
    
    - 敌人出现时播放经过 Glitch 处理的语音："我有个点子..."、"很简单..."。
        
    - 通关时："Build Success."
        

4. 开发待办列表 (Project To-Do List)

这是基于 3周 (21天) 的敏捷开发计划。

✅ Week 1: 核心骨架 (The Greybox & Rails)

目标：方块人，能在轨道上跑，能开枪，有子弹时间。

 Day 1: 项目搭建
    
    - 创建 Godot 项目。
        
    - 设置 Input Map (鼠标左键: Fire, R: Reload)。
        
    - 搭建测试场景 (WorldEnvironment, DirectionalLight)。
        
 Day 2: 轨道系统 (On-Rails)
    
    - 实现 `Path3D` 和 `PathFollow3D`。
        
    - 编写脚本：让摄像机在节点 A 移动到节点 B，然后暂停等待信号。
        
 Day 3: 射击机制
    
    - 实现 3D 射线检测 (`PhysicsRayQuery`)。
        
    - 实现“点击 -> 销毁物体”的基础逻辑。
        
    - 关键：实现 `Engine.time_scale` 的平滑过渡控制（踹门时变慢，清场后变快）。
        
 Day 4: 敌人基础逻辑
    
    - 创建一个 `Enemy` 类。
        
    - 状态机：Spawn -> Idle -> Aim -> Shoot (Game Over)。
        
 Day 5: 破门流程
    
    - 把 移动、暂停、踹门动画、子弹时间 串联起来，跑通一个房间的循环。
        

🎨 Week 2: 美术资产与逻辑填充 (Assets & Logic)

目标：看起来像《VR策划2》，而不是方块游戏。

 Day 6-7: 模型制作 (Blender)
    
    - 制作通用低模人形 (Low Poly Human)。
        
    - 制作门 (分门框和门板)、办公桌、电脑。
        
    - 导入 Godot 并设置材质 (StandardMaterial3D, Emission开启)。
        
 Day 8: 敌人 AI 升级
        
    - 实现随机文本生成器 (从数组里随机取“策划语录”贴在敌人头上)。
        
 Day 9: 特效制作 (VFX)
    
    - `GPUParticles3D`：敌人碎裂效果 (红色方块雨)。
        
    - `GPUParticles3D`：枪口火焰。
        
 Day 10: 关卡搭建
    
    - 使用 `GridMap` 或手动摆放，搭建 3-4 个连续的房间。
        
    - 配置好轨道路径点。
        

✨ Week 3: 打磨与果汁 (Juice & Polish)

目标：手感调试，音效植入，搞笑元素。

 Day 11: 摄像机手感 (Game Feel)
    
    - Screen Shake：编写震动管理器。踹门是大震，开枪是小震。
        
    - FOV Trick：滑行时 FOV 拉大 (速度感)，子弹时间 FOV 缩小 (聚焦感)。
        
 Day 12: 顿帧 (Hit Stop)
    
    - 击杀敌人瞬间，让游戏完全冻结 0.05~0.1秒。这是打击感的灵魂。
        
 Day 13: 音效整合
    
    - 导入所有音效。
        
    - 编写 `AudioManager`，处理 Pitch 随 TimeScale 变化的效果。
        
 Day 14: UI 与 流程完善
    
    - 制作主菜单 ("Start Debugging", "Exit to Desktop")。
        
    - 制作结算界面 ("Code Coverage: 100%", "Bugs Fixed: 24")。
        
 Day 15: Bug 修复与打包
    
    - 调整数值（敌人开枪速度，子弹时间长度）。
        
    - 导出 Windows/Mac 版本测试。
        



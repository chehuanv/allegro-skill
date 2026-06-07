;; ============================================================
;; 文件名: auto_net_silk.il
;; 功能说明: 丝印工具 - 自动网络丝印模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 丝印工具-自动网络丝印 - 自动为网络添加丝印标注
;; 文件路径 : modules/text_silk/auto_net_silk.il
;; 编码格式 : GBK/GB18030 (支持中文注释)
;; 依赖关系 : 依赖源文件中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

;;#############################################################################
;;#  模块: 自动网络丝印 (Auto Net Silkscreen)                                     #
;;#  命令: AST_Text_AutoNetSilk                                                     #
;;#  功能: 自动为指定网络添加丝印标注，显示网络名称和走线信息                      #
;;#  API:  axlDBGetNet, axlDBCreateText, axlHighlightObject                         #
;;#############################################################################

axlCmdRegister("AST_Text_AutoNetSilk" 'AST_Text_AutoNetSilk ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 自动网络丝印主函数
;; 功能说明: 自动为选中的网络或所有网络添加丝印标注
;; 操作步骤: 1) 获取目标网络列表(用户选择或全部网络)
;;           2) 遍历每个网络，获取其走线路径
;;           3) 在走线中点位置添加网络名称丝印
;;           4) 设置丝印层和文本属性
;; 返回值:   添加的丝印数量
;; 使用方式: 在Allegro命令行输入 AST_Text_AutoNetSilk 执行
;; 注意事项:
;;   - 丝印将添加在 SILKSCREEN_TOP 或 SILKSCREEN_BOTTOM 层
;;   - 文本大小和方向可配置
;;   - 避免在密集区域添加丝印，防止重叠
;;   - 建议在添加后检查丝印可读性
;;=========================================================================

procedure( AST_Text_AutoNetSilk()
  prog((nets selNets count textHeight textLayer midPt textObj)  ;; 开始局部变量作用域块
    
    ;; 步骤1: 获取网络列表
    nets = axlDBGetNets()    ;; 获取设计中所有网络
    
    unless(nets  ;; 条件为假时执行
      axlMsgPut("[AST] 设计中没有找到任何网络。")  ;; 输出消息到Allegro命令窗口
      return(0)  ;; 从当前函数返回
    )
    
    ;; 提示用户选择网络或全部处理
    axlMsgPut("[AST] 找到 %d 个网络，准备添加丝印标注..." length(nets))  ;; 输出消息到Allegro命令窗口
    
    ;; 设置丝印参数
    textHeight = 25.0    ;; 文本高度(单位:mils)
    textLayer = "SILKSCREEN_TOP"    ;; 默认丝印层
    
    ;; 步骤2: 遍历网络并添加丝印
    count = 0
    selNets = nil
    
    ;; 过滤掉电源/地网络(可选)
    foreach(net nets  ;; 遍历列表中的每个元素
      ;; 跳过电源和地网络(名称包含VCC/GND/POWER等)
      unless(rexMatchp("^(VCC|VDD|GND|PGND|AGND|DGND|POWER)" net->name)  ;; 正则表达式匹配检查
        selNets = cons(net selNets)  ;; 将元素添加到列表头部
      )
    )
    
    axlMsgPut("[AST] 排除电源/地网络后，剩余 %d 个网络需要添加丝印。" length(selNets))  ;; 输出消息到Allegro命令窗口
    
    ;; 步骤3: 为每个网络添加丝印
    foreach(net selNets  ;; 遍历列表中的每个元素
      ;; 获取网络的走线中点作为丝印位置
      midPt = _AST_GetNetMidpoint(net)
      
      when(midPt  ;; 条件为真时执行
        ;; 创建丝印文本对象
        textObj = axlDBCreateText(  ;; 在指定位置创建文本对象
          net->name                    ;; 文本内容:网络名称
          midPt                        ;; 放置位置:走线中点
          textLayer                    ;; 目标层:丝印层
          textHeight                   ;; 文本高度
          0.0                          ;; 旋转角度
          "center"                     ;; 对齐方式:居中
          nil                          ;; 镜像标志
        )
        
        when(textObj  ;; 条件为真时执行
          count = count + 1
          ;; 高亮显示已添加丝印的网络(便于检查)
          axlHighlightObject(net)  ;; 高亮显示指定对象，便于视觉识别
        )
      )
    )
    
    ;; 步骤4: 输出结果报告
    axlMsgPut("[AST] 已为 %d 个网络添加丝印标注。" count)  ;; 输出消息到Allegro命令窗口
    axlUIConfirm(sprintf(nil "自动网络丝印完成！\n已为 %d 个网络添加丝印标注。\n请检查丝印位置和可读性。" count))  ;; 弹出确认对话框显示信息
    
    return(count)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; 辅助函数: 获取网络走线的中点位置
;; 功能说明: 计算指定网络所有走线的几何中心点
;; 参数说明:
;;   net - 网络对象(dbid)
;; 返回值: 中点坐标(x:y) 或 nil(无走线)
;;=========================================================================

procedure( _AST_GetNetMidpoint(net)
  prog((clines bbox minX minY maxX maxY midX midY)  ;; 开始局部变量作用域块
    
    ;; 获取网络的所有cline
    clines = net->clines
    unless(clines return(nil))  ;; 条件为假时执行
    
    ;; 计算所有走线的边界框
    minX = nil
    minY = nil
    maxX = nil
    maxY = nil
    
    foreach(cline clines  ;; 遍历列表中的每个元素
      bbox = cline->bbox
      when(bbox  ;; 条件为真时执行
        ;; 更新最小/最大坐标
        when(or(null(minX) <(caar(bbox) minX)) minX = caar(bbox))  ;; 条件为真时执行
        when(or(null(minY) <(cadar(bbox) minY)) minY = cadar(bbox))  ;; 条件为真时执行
        when(or(null(maxX) >(caadr(bbox) maxX)) maxX = caadr(bbox))  ;; 条件为真时执行
        when(or(null(maxY) >(cadadr(bbox) maxY)) maxY = cadadr(bbox))  ;; 条件为真时执行
      )
    )
    
    ;; 计算中点
    when(and(minX minY maxX maxY)  ;; 条件为真时执行
      midX = (minX + maxX) / 2.0
      midY = (minY + maxY) / 2.0
      return(list(midX midY))  ;; 从当前函数返回
    )
    
    return(nil)  ;; 从当前函数返回
  )
)

;;=========================================================================
;; 辅助函数: 检查网络是否为电源/地网络
;; 功能说明: 根据网络名称判断是否为电源或地网络
;; 参数说明:
;;   netName - 网络名称字符串
;; 返回值: t(是电源/地) / nil(普通信号)
;;=========================================================================

procedure( _AST_IsPowerNet(netName)
  prog((powerPatterns)  ;; 开始局部变量作用域块
    ;; 定义电源/地网络名称模式
    powerPatterns = '(
      "^VCC" "^VDD" "^VEE" "^VSS"
      "^GND" "^PGND" "^AGND" "^DGND"
      "^POWER" "^HV" "^LV" "^BAT"
    )
    
    ;; 检查是否匹配任何模式
    foreach(pattern powerPatterns  ;; 遍历列表中的每个元素
      when(rexMatchp(pattern netName)  ;; 正则表达式匹配检查
        return(t)  ;; 从当前函数返回
      )
    )
    
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(nil)  ;; 从当前函数返回
  )
)

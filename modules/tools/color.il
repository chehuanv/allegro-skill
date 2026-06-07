;; ============================================================
;; 文件名: color.il
;; 功能说明: 通用工具 - 颜色管理模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 辅助工具-颜色预设 - 应用预定义的颜色方案到各层
;; 文件路径 : modules/tools/color.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Color Preset                                                                #
#  Command: AST_Tools_Color                                                            #
#  Desc:    Apply predefined color schemes to layers                                   #
#  API:     axlColorSet, axlLayerSet, axlVisibleUpdate                                #  ;; 设置指定层的颜色
#########################################################################################
*/

axlCmdRegister("AST_Tools_Color" 'AST_Tools_Color ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)
axlCmdRegister("AST_Tools_Color1" 'AST_Tools_Color1 ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 颜色预设主函数
;; 功能说明: 应用预定义的颜色方案到各层
;; 颜色方案: 包含Placement(布局)、Routing(布线)、Review(检查)等预设
;; 使用方式: 在Allegro命令行输入 AST_Tools_Color 执行
;;=========================================================================

procedure( AST_Tools_Color()
  prog((etchLayers colors i layer pinLayer etchLayer)  ;; 开始局部变量作用域块
    ;; Get all etch layers
    etchLayers = axlGetParam("paramLayerGroup:ETCH")->groupMembers  ;; 获取所有蚀刻层
    colors = list(12 5 40 43 36 53 41 65 73 80 111 119 6 10 18 24)
    
    ;; Set etch and pin colors
    i = 0
    foreach( layer etchLayers  ;; 遍历列表中的每个元素
      when( i < length(colors)  ;; 条件为真时执行
        pinLayer = sprintf(nil "PIN/%s" layer)  ;; 格式化字符串
        etchLayer = sprintf(nil "ETCH/%s" layer)  ;; 格式化字符串
        
        ;; Set PIN color
        when( axlLayerGet(pinLayer)  ;; 条件为真时执行
          let((cr)  ;; 绑定局部变量
            cr = axlLayerGet(pinLayer)
            cr->color = nth(i colors)
            axlLayerSet(cr)  ;; 设置层的属性
          )
        )
        
        ;; Set ETCH color
        when( axlLayerGet(etchLayer)  ;; 条件为真时执行
          let((cr)  ;; 绑定局部变量
            cr = axlLayerGet(etchLayer)
            cr->color = nth(i colors)
            axlLayerSet(cr)  ;; 设置层的属性
          )
        )
        i = i + 1
      )
    )
    
    ;; Set DRC color
    foreach( layer axlGetParam("paramLayerGroup:Drc Error Class")->groupMembers  ;; 获取Allegro参数值
      let((cr)  ;; 绑定局部变量
        cr = axlLayerGet(sprintf(nil "Drc Error Class/%s" layer))  ;; 格式化字符串
        when( cr  ;; 条件为真时执行
          cr->color = 150
          axlLayerSet(cr)  ;; 设置层的属性
        )
      )
    )
    
    ;; Set Via Class color
    foreach( layer axlGetParam("paramLayerGroup:Via Class")->groupMembers  ;; 获取Allegro参数值
      let((cr)  ;; 绑定局部变量
        cr = axlLayerGet(sprintf(nil "Via Class/%s" layer))  ;; 格式化字符串
        when( cr  ;; 条件为真时执行
          cr->color = 28
          axlLayerSet(cr)  ;; 设置层的属性
        )
      )
    )
    
    ;; Set Boundary color
    foreach( layer axlGetParam("paramLayerGroup:Boundary")->groupMembers  ;; 获取Allegro参数值
      let((cr)  ;; 绑定局部变量
        cr = axlLayerGet(sprintf(nil "Boundary/%s" layer))  ;; 格式化字符串
        when( cr  ;; 条件为真时执行
          cr->color = 9
          axlLayerSet(cr)  ;; 设置层的属性
        )
      )
    )
    
    ;; Set Anti Etch color
    foreach( layer axlGetParam("paramLayerGroup:Anti Etch")->groupMembers  ;; 获取Allegro参数值
      let((cr)  ;; 绑定局部变量
        cr = axlLayerGet(sprintf(nil "Anti Etch/%s" layer))  ;; 格式化字符串
        when( cr  ;; 条件为真时执行
          cr->color = 22
          axlLayerSet(cr)  ;; 设置层的属性
        )
      )
    )
    
    ;; Set silkscreen colors
    let((q)  ;; 绑定局部变量
      q = axlLayerGet("PACKAGE GEOMETRY/SILKSCREEN_TOP")
      when( q  q->color = 34  axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM")
      when( q  q->color = 28  axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("BOARD GEOMETRY/SILKSCREEN_TOP")
      when( q  q->color = 24  axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("BOARD GEOMETRY/SILKSCREEN_BOTTOM")
      when( q  q->color = 28  axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("BOARD GEOMETRY/OUTLINE")
      when( q  q->color = 120 axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("REF DES/SILKSCREEN_TOP")
      when( q  q->color = 24  axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("REF DES/SILKSCREEN_BOTTOM")
      when( q  q->color = 28  axlLayerSet(q) )  ;; 设置层的属性
      q = axlLayerGet("ROUTE KEEPIN/ALL")
      when( q  q->color = 200 axlLayerSet(q) )  ;; 设置层的属性
    )
    
    axlVisibleUpdate(t)
    AST_Msg("INFO" "Color preset applied (Scheme 1).")
    return(t)  ;; 从当前函数返回
  )
)

procedure( AST_Tools_Color1()
  prog((etchLayers colors i layer pinLayer etchLayer)  ;; 开始局部变量作用域块
    etchLayers = axlGetParam("paramLayerGroup:ETCH")->groupMembers  ;; 获取所有蚀刻层
    colors = list(64 5 43 36 53 45 65 73 80 111 119 6 10 18 24 40)
    
    i = 0
    foreach( layer etchLayers  ;; 遍历列表中的每个元素
      when( i < length(colors)  ;; 条件为真时执行
        pinLayer = sprintf(nil "PIN/%s" layer)  ;; 格式化字符串
        etchLayer = sprintf(nil "ETCH/%s" layer)  ;; 格式化字符串
        when( axlLayerGet(pinLayer)  ;; 条件为真时执行
          let((cr) cr = axlLayerGet(pinLayer) cr->color = nth(i colors) axlLayerSet(cr) )  ;; 设置层的属性
        )
        when( axlLayerGet(etchLayer)  ;; 条件为真时执行
          let((cr) cr = axlLayerGet(etchLayer) cr->color = nth(i colors) axlLayerSet(cr) )  ;; 设置层的属性
        )
        i = i + 1
      )
    )
    axlVisibleUpdate(t)
    AST_Msg("INFO" "Color preset applied (Scheme 2).")
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)

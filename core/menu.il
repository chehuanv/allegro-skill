;; ============================================================
;; 文件名: menu.il
;; 功能说明: 菜单管理模块，负责注册和显示工具箱菜单
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 菜单管理器 - 根据配置构建Allegro菜单和工具栏
;; 文件路径 : core/menu.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Menu Manager - Config-driven menu builder for AllegroSkillToolbox                   #
#########################################################################################
*/

;;=========================================================================
;; Parse menu config file and build Allegro menu list
;; TODO: implement full cfg parser when needed. Currently using AST_BuildMenuList.
;;=========================================================================
procedure( AST_BuildMenuFromConfig()
  nil
)

;;=========================================================================
;; Simplified menu builder using direct SKILL list (recommended)
;;=========================================================================
procedure( AST_BuildMenuList()
  list(
    '(popup "&AllegroSkillToolbox")
      '(popup "布局")
        '("对齐" "AST_Layout_Align")
        '("分布" "AST_Layout_Distribute")
        '("改线宽" "AST_Layout_ChangeWidth")
        '("替换过孔" "AST_Layout_ReplaceVia")
        '("切线" "AST_Layout_CutCline")
        '("镜像" "AST_MirrorElem")
        '("选择栅格" "AST_ChooseGrid")
        '("区域内放置" "AST_PlaceInside")
      '(end)
      '(separator)
      '(popup "布线")
        '("线转铜皮" "AST_ClineToShape")
        '("走线交叉检查" "AST_ClineCrossCheck")
        '("跨平面检查" "AST_CheckCrossPlane")
        '("创建禁布区" "AST_CreateKeepout")
        '("创建差分禁布区" "AST_CreateDiffKeepout")
      '(end)
      '(separator)
      '(popup "封装")
        '("改原点" "AST_Pkg_ChangeOrigin")
        '("重命名引脚" "AST_Pkg_RenamePin")
        '("导出封装" "AST_ExportSymbol")
        '("椭圆热焊盘" "AST_Pkg_OblongThermal")
      '(end)
      '(separator)
      '(popup "丝印")
        '("丝印集成工具" "AST_Text_SilkTool")
        '("自动调整丝印" "AST_Text_AutoSilk")
        '("设置文字大小" "AST_Text_SetSize")
        '("添加中文" "AST_Text_AddChinese")
        '("网络丝印" "AST_CreateNetSilk")
      '(end)
      '(separator)
      '(popup "检查DFM")
        '("锐角检查" "AST_Check_Acute")
        '("跨分割检查" "AST_Check_CrossSplit")
        '("位号方向检查" "AST_Check_RefDir")
        '("无位号检查" "AST_CheckNoRefdes")
      '(end)
      '(separator)
      '(popup "清理")
        '("删除悬空" "AST_DelDangling")
      '(end)
      '(separator)
      '(popup "输出")
        '("输出Gerber" "AST_Out_Gerber")
        '("输出PDF" "AST_Out_PDF")
        '("输出DXF" "AST_Out_DXF")
        '("输出坐标" "AST_Out_Coords")
        '("导出器件" "AST_ExportDevice")
      '(end)
      '(separator)
      '(popup "工具")
        '("计算器" "AST_Tools_Calculator")
        '("单位转换" "AST_Tools_UnitConvert")
        '("颜色设置" "AST_ColorSetting")
        '("阻抗计算" "AST_Special_Impedance")
        '("颜色预览1" "AST_Tools_Color")
        '("颜色预览2" "AST_Tools_Color1")
        '("快捷键设置" "AST_Tools_Hotkeys")
      '(end)
      '(separator)
      '(popup "系统")
        '("关于" "AST_About")
        '("重新加载" "AST_Reload")
        '(separator)
        '("备份当前代码" "AST_Backup")
        '("回滚到上一版本" "AST_Rollback")
        '("查看备份列表" "AST_ListBackups")
        '(separator)
        '("卸载" "AST_Uninstall")
      '(end)
    '(end)
  )
)

;;=========================================================================
;; Parse a single menu item line: "Label","command"
;;=========================================================================
procedure( AST_ParseMenuItem(line)
  prog((parts label cmd)  ;; 开始局部变量作用域块
    parts = parseString(line "\",")
    label = AST_StringTrim(car(parts))  ;; 取列表第一个元素
    cmd = AST_StringTrim(cadr(parts))  ;; 取列表第二个元素
    return(list(label cmd))  ;; 从当前函数返回
  )
)

;;=========================================================================
;; String utilities (minimal)
;;=========================================================================
procedure( AST_StringTrim(str)
  prog((start end len ch)  ;; 开始局部变量作用域块
    len = strlen(str)
    start = 0
    end = len
    
    ;; Trim leading whitespace
    when( start < len  ;; 条件为真时执行
      ch = substring(str start + 1 start + 1)
      while( and(start < len or(ch == " " ch == "\t" ch == "\n" ch == "\r"))
        start = start + 1
        when( start < len  ;; 条件为真时执行
          ch = substring(str start + 1 start + 1)
        )
      )
    )
    
    ;; Trim trailing whitespace
    when( end > start  ;; 条件为真时执行
      ch = substring(str end end)
      while( and(end > start or(ch == " " ch == "\t" ch == "\n" ch == "\r"))
        end = end - 1
        when( end > start  ;; 条件为真时执行
          ch = substring(str end end)
        )
      )
    )
    
    return(substring(str start + 1 end))  ;; 从当前函数返回
  )
)

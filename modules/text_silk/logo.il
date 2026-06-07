;; ============================================================
;; 文件名: logo.il
;; 功能说明: 丝印工具 - Logo处理模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 丝印工具-Logo导入 - 将1位BMP图片转换为PCB线段/铜皮元素
;; 文件路径 : modules/text_silk/logo.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Import Logo                                                                 #
#  Command: AST_Text_Logo                                                              #
#  Desc:    Import 1-bit BMP and convert to PCB line/shape elements                    #
#########################################################################################
*/

axlCmdRegister("AST_Text_Logo" 'AST_Text_Logo ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; Logo导入主函数
;; 功能说明: 将1位BMP图片转换为PCB线段/铜皮元素
;; 操作方式: 1) 准备1位BMP图片 2) 选择插入点 3) 生成PCB元素
;; 使用方式: 在Allegro命令行输入 AST_Text_Logo 执行
;;=========================================================================

procedure( AST_Text_Logo()
  prog((bmpFile pt)  ;; 开始局部变量作用域块
    bmpFile = "logo.bmp"  ; TODO: file browser  ;; 默认Logo文件名(TODO: 文件浏览器)
    AST_Msg("INFO" sprintf(nil "Import logo: %s" bmpFile))  ;; 格式化字符串
    pt = axlEnterPoint(?prompts '("Pick logo insertion point"))  ;; 启动交互点选模式，等待用户点击位置
    when( pt  ;; 条件为真时执行
      ;; TODO: parse BMP pixels and generate lines/shapes
      axlUIConfirm("Logo import stub: implement BMP parser.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
    )
  )
)

;; ============================================================
;; 文件名: add_chinese.il
;; 功能说明: 丝印工具 - 添加中文字符模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 丝印工具-添加中文 - 将中文字符串转换为线段并放置到PCB
;; 文件路径 : modules/text_silk/add_chinese.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Add Chinese Text                                                            #
#  Command: AST_Text_AddChinese                                                        #
#  Desc:    Convert Chinese string to line segments and place on PCB                   #
#  Note:    Requires external ttf2lin/exe or freetype.dll for glyph extraction         #
#########################################################################################
*/

axlCmdRegister("AST_Text_AddChinese" 'AST_Text_AddChinese ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 添加中文字符主函数
;; 功能说明: 将中文字符串转换为线段并放置到PCB上
;; 操作方式: 1) 输入中文字符串 2) 选择放置点 3) 生成线段文字
;; 依赖说明: 需要外部ttf2lin.exe或freetype.dll进行字形提取
;; 使用方式: 在Allegro命令行输入 AST_Text_AddChinese 执行
;;=========================================================================

procedure( AST_Text_AddChinese()
  prog((str pt)  ;; 开始局部变量作用域块
    str = "示例中文"  ; TODO: prompt via form  ;; 默认示例文字(TODO: 通过表单输入)
    AST_Msg("INFO" sprintf(nil "Add Chinese: '%s'" str))  ;; 格式化字符串
    pt = axlEnterPoint(?prompts '("Pick text placement point"))  ;; 获取用户点击的放置点
    when( pt  ;; 条件为真时执行
      ;; TODO: convert glyphs to line segments using freetype.dll or pre-calculated strokes
      axlUIConfirm("Chinese text stub: implement glyph-to-line conversion.")  ;; 弹出确认对话框显示信息
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
    )
  )
)

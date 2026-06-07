;; ============================================================
;; 文件名: oblong_thermal.il
;; 功能说明: 封装工具 - 椭圆形散热焊盘模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 封装工具-椭圆花焊盘 - GUI工具创建椭圆/长圆形热焊盘Flash
;; 文件路径 : modules/package/oblong_thermal.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Create Oblong Thermal (Flash)                                               #
#  Command: AST_Pkg_OblongThermal                                                      #
#  Desc:    GUI tool to create oblong/oval thermal relief flash symbol                 #
#########################################################################################
*/

axlCmdRegister("AST_Pkg_OblongThermal" 'AST_Pkg_OblongThermal ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 椭圆形散热焊盘主函数
;; 功能说明: 创建椭圆形/长方形散热焊盘Flash符号
;; 操作方式: 通过表单设置内外径、辐条宽度、角度等参数
;; 使用方式: 在Allegro命令行输入 AST_Pkg_OblongThermal 执行
;;=========================================================================

procedure( AST_Pkg_OblongThermal()
  prog((fp)  ;; 开始局部变量作用域块
    ;; TODO: create form for inner/outer diameter, spoke width, angle
    AST_Msg("INFO" "Oblong Thermal: open form to configure flash parameters.")
    axlUIConfirm("Oblong Thermal creator stub.")  ;; 弹出确认对话框显示信息
    return(t)  ;; 从当前函数返回
  )
)

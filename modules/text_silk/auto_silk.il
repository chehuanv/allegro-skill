;; ============================================================
;; 文件名: auto_silk.il
;; 功能说明: 丝印工具 - 自动丝印模块
;; 编码格式: GBK (简体中文)
;; 注意事项: 本文件使用GBK编码保存，请勿用UTF-8编码打开
;; ============================================================
;; ================================================================================
;; 文件说明 : 丝印工具-自动调整位号 - 将所有REFDES移动到器件外框顶部中心
;; 文件路径 : modules/text_silk/auto_silk.il
;; 编码格式 : GBK/GB18030 (中文注释支持)
;; 调用命令 : 参见源码中的 axlCmdRegister 注册命令
;; 注意事项 : 本文件使用GB编码保存，请勿使用UTF-8编码直接保存，否则中文会乱码
;; ================================================================================

/*
#########################################################################################
#  Module: Auto Adjust Silkscreen                                                      #
#  Command: AST_Text_AutoSilk                                                          #
#  Desc:    Move all REFDES to center-top of component bounding box                    #
#  API:     axlTransformObject, axlDBChangeText                                        #  ;; 对对象进行变换操作(移动/旋转/镜像)
#########################################################################################
*/

axlCmdRegister("AST_Text_AutoSilk" 'AST_Text_AutoSilk ?cmdType "interactive" ?doneCmd 'AST_DummyDone ?cancelCmd 'AST_DummyCancel)

;;=========================================================================
;; 自动调整丝印主函数
;; 功能说明: 将所有REFDES位号自动移动到器件边界框的中心顶部
;; 操作方式: 自动遍历所有器件，调整位号位置和方向
;; 使用方式: 在Allegro命令行输入 AST_Text_AutoSilk 执行
;;=========================================================================

procedure( AST_Text_AutoSilk()
  prog((comps count sym bbox cx cy topY textObjs layerPrefix)  ;; 开始局部变量作用域块
    comps = axlDBGetDesign()->components  ;; 获取所有器件
    count = 0
    layerPrefix = "REF DES/SILKSCREEN_"  ;; 丝印层前缀
    
    foreach( comp comps  ;; 遍历列表中的每个元素
      when( comp  ;; 条件为真时执行
        sym = car(axlSelectByName("COMPONENT" comp->refdes))  ;; 启动交互选择模式，等待用户选择对象
        when( sym  ;; 条件为真时执行
          bbox = sym->bBox
          cx = (caar(bbox) + caadr(bbox)) / 2
          cy = (cadar(bbox) + cadr(cadr(bbox))) / 2  ;; 取列表第二个元素
          topY = cadr(cadr(bbox)) + 20.0  ;; 20 mils above top edge
          
          ;; Find REFDES text children
          foreach( child sym->children  ;; 遍历列表中的每个元素
            when( child->objType == "text"  ;; 条件为真时执行
              when( index(child->layer layerPrefix)  ;; 条件为真时执行
                ;; Move text to center-top
                let((dx dy orient)  ;; 绑定局部变量
                  dx = cx - car(child->xy)  ;; 取列表第一个元素
                  dy = topY - cadr(child->xy)  ;; 取列表第二个元素
                  orient = make_axlTextOrientation(
                    ?textBlock child->textBlock
                    ?rotation 0
                    ?mirrored child->isMirrored
                    ?justify "center"
                  )
                  axlDBChangeText(child child->text ?orientation orient)
                  axlTransformObject(child ?move list(dx dy))  ;; 移动对象到指定位置
                  count++
                )
              )
            )
          )
        )
      )
    )
    
    AST_Msg("INFO" sprintf(nil "Auto silk adjusted for %d components." count))  ;; 格式化字符串
        axlDisplayFlush()  ;; 刷新显示，更新画布
return(t)  ;; 从当前函数返回
  )
)

;; ============================================================
;; File: core/trans.il
;; Purpose: Transaction control and command registration
;; Encoding: ASCII
;; ============================================================

defvar(ASTB_REGISTERED_COMMANDS nil)

procedure( ASTB_SafeExec(proc args @optional (errMsgOut nil))
  prog((result errMsg ret)
    when( null(proc)
      ASTB_LogError("ASTB_SafeExec: proc is nil")
      return(nil)
    )
    ret = errset(result = apply(proc args) t)
    if( ret
    then
      return(car(ret))
    else
      errMsg = "Execution error"
      ASTB_LogError(errMsg)
      when( errMsgOut
        errMsgOut->value = errMsg
      )
      return(nil)
    )
  )
)

procedure( ASTB_DBTransaction(proc args @optional (errMsgOut nil))
  prog((result errMsg ret txId)
    when( null(proc)
      ASTB_LogError("ASTB_DBTransaction: proc is nil")
      return(nil)
    )
    txId = ASTB_TxnStart("ASTB")
    ret = errset(result = apply(proc args) t)
    if( ret
    then
      ASTB_TxnCommit(txId)
      return(car(ret))
    else
      errMsg = "DB transaction failed, rolled back"
      ASTB_TxnRollback(txId)
      ASTB_LogError(errMsg)
      when( errMsgOut
        errMsgOut->value = errMsg
      )
      return(nil)
    )
  )
)

procedure( ASTB_ToSymbol(x)
  cond(
    ( symbolp(x) x )
    ( stringp(x) stringToSymbol(x) )
    ( t nil )
  )
)

procedure( ASTB_RegisterCommand(cmdName procName @key (cmdType "general"))
  prog((procSym ret cmdStr)
    procSym = ASTB_ToSymbol(procName)
    cmdStr = if( stringp(cmdName) then cmdName else sprintf(nil "%s" cmdName) )
    unless( procSym
      ASTB_LogWarn(sprintf(nil "Command %s target is invalid" cmdStr))
      return(nil)
    )
    unless( fboundp(procSym)
      ASTB_LogWarn(sprintf(nil "Command %s target %s not defined" cmdStr procName))
      return(nil)
    )
    ret = ASTB_CmdRegisterSafe(cmdStr procSym ?cmdType cmdType)
    unless( ret
      ASTB_LogWarn(sprintf(nil "Failed to register command %s" cmdStr))
      return(nil)
    )
    ASTB_REGISTERED_COMMANDS = cons(list(cmdStr procName cmdType) ASTB_REGISTERED_COMMANDS)
    ASTB_LogInfo(sprintf(nil "Registered command: %s -> %s" cmdStr procName))
    return(t)
  )
)

procedure( ASTB_CreateStub(cmdName)
  prog((procSym code ret)
    procSym = ASTB_ToSymbol(cmdName)
    when( null(procSym)
      return(nil)
    )
    when( fboundp(procSym)
      return(nil)
    )
    code = list('procedure procSym '()
                 list('prog '()
                       list('ASTB_MsgBox sprintf(nil "Feature [%s] is under development" cmdName))
                       list('return 't)
                 )
           )
    ret = errset(eval(code) t)
    when( ret
      ASTB_LogInfo(sprintf(nil "Created stub: %s" cmdName))
    )
  )
)

printf("[ASTB] core/trans.il loaded.\n")

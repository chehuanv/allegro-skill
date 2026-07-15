;; ============================================================
;; File: core/version_adapter.il
;; Purpose: Version compatibility (16.6/17.4/24.1)
;; Encoding: ASCII
;; ============================================================

defvar(ASTB_VERSION_INFO nil)

procedure( ASTB_ExtractVersionString(ver)
  prog((keys k ret)
    when( stringp(ver)
      return(ver)
    )
    ret = errset(axlVersion('fullVersion) t)
    when( ret && car(ret)
      return(car(ret))
    )
    ret = errset(axlVersion('version) t)
    when( ret && car(ret)
      return(car(ret))
    )
    when( ver
      keys = '(fullVersion version release productVersion progVersion buildDate)
      foreach( k keys
        ret = errset(ver->k t)
        when( ret && car(ret)
          return(car(ret))
        )
      )
    )
    return("")
  )
)

procedure( ASTB_VersionInit()
  prog((ver verStr ret)
    ret = errset(ver = axlVersion() t)
    unless( ret
      ASTB_LogWarn("axlVersion() failed.")
      return(nil)
    )
    ver = car(ret)
    ASTB_VERSION_INFO = ver
    verStr = ASTB_ExtractVersionString(ver)
    ASTB_LogInfo(sprintf(nil "Allegro version: %s" verStr))
  )
)

procedure( ASTB_GetVersion()
  ASTB_ExtractVersionString(ASTB_VERSION_INFO)
)

procedure( ASTB_VersionContains(sub)
  prog((verStr)
    verStr = ASTB_GetVersion()
    when( verStr
      rexMatchp(sub verStr)
    )
  )
)

procedure( ASTB_IsVersion166()
  ASTB_VersionContains("16.6")
)

procedure( ASTB_IsVersion174()
  ASTB_VersionContains("17.4")
)

procedure( ASTB_IsVersion241()
  ASTB_VersionContains("24.1")
)

procedure( ASTB_ModernUI()
  not(ASTB_IsVersion166())
)

procedure( ASTB_TimerAdd(window delay obj procSym)
  prog((tid ret)
    ret = errset(tid = axlUIWTimerAdd(window delay obj procSym) t)
    if( ret then tid else nil)
  )
)

procedure( ASTB_TimerRemove(timerId)
  errset(axlUIWTimerRemove(timerId) t)
  t
)

procedure( ASTB_TxnStart(@optional (name "ASTB"))
  prog((txId ret)
    ret = errset(txId = axlDBTransactionStart(name) t)
    if( ret
    then
      return(txId)
    else
      ret = errset(txId = axlBeginTransaction() t)
      when( ret
        return(txId)
      )
      ASTB_LogError("ASTB_TxnStart: both APIs failed")
      return(nil)
    )
  )
)

procedure( ASTB_TxnCommit(txId)
  prog((ret)
    ret = errset(axlDBTransactionCommit(txId) t)
    unless( ret
      errset(axlEndTransaction() t)
    )
    t
  )
)

procedure( ASTB_TxnRollback(txId)
  prog((ret)
    ret = errset(axlDBTransactionRollback(txId) t)
    unless( ret
      ASTB_LogWarn("Rollback not supported in 16.6")
      errset(axlEndTransaction() t)
    )
    t
  )
)

procedure( ASTB_MenuFindSafe(@optional (label nil) (pos nil))
  prog((ret id)
    when( pos == -1
      ret = errset(id = axlUIMenuFind(label pos) t)
      when( ret && car(ret)
        return(car(ret))
      )
      ret = errset(id = axlUIMenuFind("Help") t)
      when( ret && car(ret)
        return(car(ret))
      )
      return(nil)
    )
    ret = errset(id = axlUIMenuFind(label) t)
    when( ret && car(ret)
      return(car(ret))
    )
    return(nil)
  )
)

procedure( ASTB_CmdRegisterSafe(cmdName procSym @key (cmdType "general"))
  prog((ret)
    ret = errset(axlCmdRegister(cmdName procSym ?cmdType cmdType) t)
    when( ret
      return(t)
    )
    ret = errset(axlCmdRegister(cmdName procSym) t)
    when( ret
      return(t)
    )
    ASTB_LogWarn(sprintf(nil "Failed to register command %s" cmdName))
    nil
  )
)

printf("[ASTB] core/version_adapter.il loaded.\n")

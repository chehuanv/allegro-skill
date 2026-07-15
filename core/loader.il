;; ============================================================
;; File: core/loader.il
;; Purpose: Module auto-loader
;; Encoding: ASCII
;; ============================================================

procedure( ASTB_HasSuffix(str suffix)
  prog((lenSuffix lenStr start)
    lenSuffix = strlen(suffix)
    lenStr = strlen(str)
    if( lenStr < lenSuffix
    then
      return(nil)
    else
      start = lenStr - lenSuffix + 1
      return(substring(str start lenStr) == suffix)
    )
  )
)

procedure( ASTB_LoadDir(dirPath @optional (recursive nil))
  prog((files f fullPath result)
    when( isDir(dirPath)
      ASTB_DebugLog(strcat("ASTB_LoadDir: scanning " dirPath))
      files = sort(getDirFiles(dirPath) 'alphalessp)
      foreach( f files
        unless( or(f == "." f == "..")
          fullPath = strcat(dirPath "/" f)
          when( isDir(fullPath) && recursive
            ASTB_LoadDir(fullPath recursive)
          )
          when( ASTB_HasSuffix(f ".il") && isFile(fullPath)
            ASTB_DebugLog(strcat("ASTB_LoadDir: loading file " fullPath))
            result = errset(load(fullPath) t)
            unless( result
              ASTB_LogError(sprintf(nil "Failed to load %s" fullPath))
            )
          )
        )
      )
    )
  )
)

procedure( ASTB_LoadCore()
  prog((coreFiles f result)
    result = errset(load(strcat(ASTB_GLOBAL->CorePath "/utils.il")) t)
    unless( result
      ASTB_LogError("Failed to load core/utils.il")
    )
    result = errset(load(strcat(ASTB_GLOBAL->CorePath "/version_adapter.il")) t)
    unless( result
      ASTB_LogError("Failed to load core/version_adapter.il")
    )
    coreFiles = sort(getDirFiles(ASTB_GLOBAL->CorePath) 'alphalessp)
    foreach( f coreFiles
      when( and(ASTB_HasSuffix(f ".il")
                f != "utils.il"
                f != "version_adapter.il"
                f != "loader.il"
                f != "_stubs.il")
        result = errset(load(strcat(ASTB_GLOBAL->CorePath "/" f)) t)
        unless( result
          ASTB_LogError(sprintf(nil "Failed to load core/%s" f))
        )
      )
    )
    ASTB_LogInfo("Core libraries loaded.")
  )
)

procedure( ASTB_LoadModules()
  prog(()
    ASTB_DebugLog("ASTB_LoadModules: start")
    ASTB_LoadDir(ASTB_GLOBAL->ModulePath t)
    ASTB_LogInfo("Modules loaded.")
    ASTB_DebugLog("ASTB_LoadModules: done")
  )
)

printf("[ASTB] core/loader.il loaded.\n")

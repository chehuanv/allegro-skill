;; ============================================================
;; File: core/config.il
;; Purpose: Configuration management
;; Encoding: ASCII
;; ============================================================

defvar(ASTB_CONFIG makeTable('ASTB_CONFIG))
defvar(ASTB_CONFIG_KEYS nil)

procedure( ASTB_StringInList(str lst)
  prog((item)
    foreach( item lst
      when( item == str
        return(t)
      )
    )
    nil
  )
)

procedure( ASTB_TableHasKey(table key)
  ASTB_StringInList(key ASTB_CONFIG_KEYS)
)

procedure( ASTB_ConfigFile()
  strcat(ASTB_GLOBAL->ConfigPath "/astb.cfg")
)

procedure( ASTB_LoadConfig()
  prog((cfgFile port line kv)
    cfgFile = ASTB_ConfigFile()
    ASTB_LogInfo(sprintf(nil "ASTB_LoadConfig: file=%s exists=%L" cfgFile isFile(cfgFile)))
    unless( isFile(cfgFile)
      ASTB_LogInfo("Config file not found, using defaults.")
      return(nil)
    )
    port = infile(cfgFile)
    when( null(port)
      ASTB_LogWarn(sprintf(nil "Cannot open config file: %s" cfgFile))
      return(nil)
    )
    while( gets(line port)
      kv = ASTB_ParseCfgLine(line)
      when( kv
        ASTB_SetConfig(car(kv) cadr(kv))
      )
    )
    close(port)
    ASTB_LogInfo(sprintf(nil "Config loaded from %s" cfgFile))
  )
)

procedure( ASTB_SaveConfig()
  prog((cfgFile port key)
    cfgFile = ASTB_ConfigFile()
    ASTB_EnsureDir(ASTB_GLOBAL->ConfigPath)
    port = outfile(cfgFile)
    when( null(port)
      ASTB_LogError(sprintf(nil "Cannot write config file: %s" cfgFile))
      return(nil)
    )
    fprintf(port "# allegro_skill configuration\n")
    fprintf(port "# Auto-generated, do NOT edit with UTF-8 editor\n")
    foreach( key ASTB_CONFIG_KEYS
      fprintf(port "%s=%s\n" key ASTB_CONFIG[key])
    )
    close(port)
    ASTB_LogInfo(sprintf(nil "Config saved to %s" cfgFile))
  )
)

procedure( ASTB_GetConfig(key defaultVal)
  prog((val hasKey)
    hasKey = ASTB_TableHasKey(ASTB_CONFIG key)
    val = defaultVal
    when( hasKey
      val = ASTB_CONFIG[key]
    )
    when( eq(val 'unbound)
      val = defaultVal
    )
    return(val)
  )
)

procedure( ASTB_SetConfig(key value)
  prog((s)
    s = if( stringp(value) value sprintf(nil "%s" value) )
    ASTB_CONFIG[key] = s
    unless( ASTB_StringInList(key ASTB_CONFIG_KEYS)
      ASTB_CONFIG_KEYS = cons(key ASTB_CONFIG_KEYS)
    )
    return(s)
  )
)

procedure( ASTB_InitDefaultConfig()
  prog(()
    unless( ASTB_TableHasKey(ASTB_CONFIG "version")
      ASTB_SetConfig("version" "2.0")
    )
    unless( ASTB_TableHasKey(ASTB_CONFIG "language")
      ASTB_SetConfig("language" "zh-CN")
    )
    unless( ASTB_TableHasKey(ASTB_CONFIG "logLevel")
      ASTB_SetConfig("logLevel" "INFO")
    )
    unless( ASTB_TableHasKey(ASTB_CONFIG "autoReload")
      ASTB_SetConfig("autoReload" "true")
    )
  )
)

printf("[ASTB] core/config.il loaded.\n")

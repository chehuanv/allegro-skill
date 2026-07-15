;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main.il - Allegro SKILL Toolbox 主框架
; 负责初始化、模块加载、菜单注册
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 版本信息
axlSetVariable("ASTB_VERSION" "2.2.0")

; 获取工具箱根目录
procedure(ASTB_GetRootDir()
    let((scriptPath)
        scriptPath = getSkillPath()
        car(scriptPath)
    )
)

; 加载核心模块
procedure(ASTB_LoadCore()
    let((coreDir coreFiles)
        coreDir = strcat(ASTB_GetRootDir() "/core")
        coreFiles = '("config.il" "utils.il" "trans.il" "version_adapter.il" "loader.il" "menu.il")
        
        foreach(file coreFiles
            let((filePath)
                filePath = strcat(coreDir "/" file)
                when(isFile(filePath)
                    load(filePath)
                )
            )
        )
    )
)

; 加载功能模块
procedure(ASTB_LoadModules()
    let((modDir modDirs)
        modDir = strcat(ASTB_GetRootDir() "/modules")
        modDirs = '("check" "package" "placement" "routing" "shape" "text" "utilities" "via")
        
        foreach(subDir modDirs
            let((subDirPath files)
                subDirPath = strcat(modDir "/" subDir)
                when(isDir(subDirPath)
                    files = sort(axlListFiles(subDirPath "*.il"))
                    foreach(file files
                        load(strcat(subDirPath "/" file))
                    )
                )
            )
        )
    )
)

; 初始化入口
procedure(ASTB_Init()
    ASTB_LoadCore()
    ASTB_LoadModules()
    printf("Allegro SKILL Toolbox v%s loaded successfully.\\n" axlGetVariable("ASTB_VERSION"))
)

; 自动初始化
ASTB_Init()

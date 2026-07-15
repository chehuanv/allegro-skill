;; ============================================================
;; File: modules/utilities/color_power_nets.il
;; Purpose: Auto-color power and ground nets
;; Encoding: ASCII (Chinese labels loaded from labels_raw.dat)
;; ============================================================

;; --- Ground net prefixes (case-sensitive, exact start match) ---
defvar(_ASTB_PWRGND_GND_LIST '("GND" "AGND" "DGND" "SGND" "EGND" "VSS"))

;; --- Power net prefix patterns ---
defvar(_ASTB_PWRGND_PWR_PREFIXES '("VCC" "VDD" "VIO" "VIN" "VOUT" "VPP" "VEE"))

;; --- Voltage -> Color mapping (1=Red 2=Green 3=Blue 4=Yellow 5=Orange 6=Purple 7=Cyan 8=White 9=Gray 10=Pink) ---
defvar(_ASTB_PWRGND_VOLT_COLOR '(
  ("3.3" 3)   ;; Blue
  ("5"   5)   ;; Orange
  ("1.8" 6)   ;; Purple
  ("1.2" 7)   ;; Cyan
  ("12"  8)   ;; White
  ("1"   10)  ;; Pink
  ("2.5" 4)   ;; Yellow
  ("0.9" 9)   ;; Gray
  ("1.5" 6)   ;; Purple
  ("2"   4)   ;; Yellow
  ("3"   3)   ;; Blue
  ("6"   5)   ;; Orange
  ("9"   9)   ;; Gray
  ("15"  8)   ;; White
  ("24"  8)   ;; White
  ("48"  8)   ;; White
))

;; Check if string starts with exact prefix (case-sensitive)
procedure( _ASTB_PwrGndStartsWith(str prefix)
  prog((slen plen)
    slen = strlen(str)
    plen = strlen(prefix)
    when( plen <= slen
      return( substring(str 1 plen) == prefix )
    )
    return(nil)
  )
)

;; Check if net is ground
procedure( _ASTB_PwrGndIsGnd(netName)
  prog((prefix)
    foreach( prefix _ASTB_PWRGND_GND_LIST
      when( _ASTB_PwrGndStartsWith(netName prefix)
        return(t)
      )
    )
    return(nil)
  )
)

;; Parse voltage value from net name (e.g. "VCC_3.3V" -> "3.3", "5V" -> "5")
procedure( _ASTB_PwrGndParseVoltage(netName)
  prog((len i ch valStr dotFound)
    len = strlen(netName)
    i = 1
    while( i <= len
      ch = substring(netName i 1)
      ;; Look for digit start
      when( ch >= "0" && ch <= "9"
        valStr = ch
        dotFound = nil
        i = i + 1
        while( i <= len
          ch = substring(netName i 1)
          when( ch >= "0" && ch <= "9"
            valStr = strcat(valStr ch)
          )
          when( ch == "." && !dotFound
            valStr = strcat(valStr ch)
            dotFound = t
          )
          when( !(ch >= "0" && ch <= "9") && ch != "."
            return(valStr)
          )
          i = i + 1
        )
        return(valStr)
      )
      i = i + 1
    )
    return(nil)
  )
)

;; Get color for voltage value
procedure( _ASTB_PwrGndGetColor(voltage)
  prog((pair)
    foreach( pair _ASTB_PWRGND_VOLT_COLOR
      when( car(pair) == voltage
        return(cadr(pair))
      )
    )
    return(8) ;; Default White
  )
)

;; Main function: Auto-color power and ground nets
procedure( ASTB_Util_ColorPowerNets()
  prog((allNets netName colorList gndColor pwrColor voltStr voltColor)
    
    ;; Ground color = Green (2)
    gndColor = 2
    
    ;; Get all nets
    allNets = axlDBGetDesign()->nets
    
    ;; Process each net
    foreach( net allNets
      netName = net->name
      
      ;; Check if ground net
      when( _ASTB_PwrGndIsGnd(netName)
        ;; Color ground net green
        axlDBNetColor(net gndColor)
      )
      
      ;; Check if power net
      prog((prefix)
        foreach( prefix _ASTB_PWRGND_PWR_PREFIXES
          when( _ASTB_PwrGndStartsWith(netName prefix)
            ;; Parse voltage and get color
            voltStr = _ASTB_PwrGndParseVoltage(netName)
            when( voltStr
              voltColor = _ASTB_PwrGndGetColor(voltStr)
              axlDBNetColor(net voltColor)
            )
            return(t) ;; Break prefix loop
          )
        )
      )
    )
    
    axlMsgPut("Power/ground nets colored successfully!")
    return(t)
  )
)

;; Toolbox wrapper
ASTB_RegisterCommand("ASTB_Util_ColorPowerNets" "ASTB_Util_ColorPowerNets" "utilities" "Auto-color power and ground nets")

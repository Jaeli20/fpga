## ============================================================
##  Zybo Z7-10 - 7 sensores flex (puente con PULLUP interno)
## ============================================================

# JA1  flex_i[0]
set_property PACKAGE_PIN N15 [get_ports {flex_i[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[0]}]
set_property PULLUP true [get_ports {flex_i[0]}]

# JA2  flex_i[1]
set_property PACKAGE_PIN L14 [get_ports {flex_i[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[1]}]
set_property PULLUP true [get_ports {flex_i[1]}]

# JA3  flex_i[2]
set_property PACKAGE_PIN K16 [get_ports {flex_i[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[2]}]
set_property PULLUP true [get_ports {flex_i[2]}]

# JA4  flex_i[3]
set_property PACKAGE_PIN K14 [get_ports {flex_i[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[3]}]
set_property PULLUP true [get_ports {flex_i[3]}]

# JA7  flex_i[4]
set_property PACKAGE_PIN N16 [get_ports {flex_i[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[4]}]
set_property PULLUP true [get_ports {flex_i[4]}]

# JA8  flex_i[5]
set_property PACKAGE_PIN V15 [get_ports {flex_i[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[5]}]
set_property PULLUP true [get_ports {flex_i[5]}]

# JA9  flex_i[6]
set_property PACKAGE_PIN W15 [get_ports {flex_i[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flex_i[6]}]
set_property PULLUP true [get_ports {flex_i[6]}]

## ============================================================
##  Zybo Z7-10 - 4 botones físicos (PMOD JD)
## ============================================================

# JD1 ? btn_i[0]
set_property PACKAGE_PIN T11 [get_ports {btn_i[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_i[0]}]
set_property PULLUP true [get_ports {btn_i[0]}]

# JD2 ? btn_i[1]
set_property PACKAGE_PIN T10 [get_ports {btn_i[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_i[1]}]
set_property PULLUP true [get_ports {btn_i[1]}]

# JD3 ? btn_i[2]
set_property PACKAGE_PIN W14 [get_ports {btn_i[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_i[2]}]
set_property PULLUP true [get_ports {btn_i[2]}]

# JD4 ? btn_i[3]
set_property PACKAGE_PIN Y14 [get_ports {btn_i[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_i[3]}]
set_property PULLUP true [get_ports {btn_i[3]}]


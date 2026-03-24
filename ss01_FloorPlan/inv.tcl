#######
# Setup
#######

# Khai bao bien la STAGE
set STAGE 00_init_design  

# cho phep innovus su dung nhieu loi CPU de chay nhanh hon
setMultiCpuUsage -localCpu $env(CPU_NUM)


# Limitation under the license 
# Setting GUI, thiet lap luoi voi do chia 0.1um
setPreference ConstrainUserXGird 0.1
setPreference ConstrainUserXOffset 0.1
setPreference ConstrainUserYGird 0.1
setPreference ConstrainUserYOffset 0.1
setPreference SnapAllCorner 1

########################
set central_path /pd/data 
source /all_lef_files.tcl 
set init_verilog /croc_chip_yosys.v 
set init_design_uniquify 1
set init_design_settop 1
set init_top_cell croc_chip 
set init_lef_file $init_lef_files
set init_mmmc_file /croc_mmmc.view
set init_pwr_net {VDD}
set init_gnd_net {VSS}

# doc toan bo cac bien init_ nap data vao memory va dung database ban dau 
init_design 

puts "Done init design, pls check log file if any errors during init design"

#return

saveDesign SAVED/${STAGE}_init.invs

# Kiem tra xem cac standard cell trong thu vien da duoc load day du thong tin der thuc hien cho Placement ch?
check_library -all_lib_cell -place > rpt/#{STAGE}/check_library.rpt 

# update name 
source ${central_path}/scripts/../update_name_format.tcl 

############
# Create row
############
deleteRow -all 
initCoreRow
cutRow
# Xoa cac hang cu, khoi tao hang moi, va cat cac row de len vung cam hoac cac macro cung

###############
# Create track
###############
add_tracks -offset {Metal1 vert 0 Metal2 horiz 0 Metal3 vert 0 Metal4 horiz 0 Metal5 vert 0  TopMetal1 horiz 0 TopMetal2 vert 0}

#####################
# Report utilization
#####################
checkFPlan -reportUtil > rpt/${STAGE}/check_library.rpt
# Tinh toan va xuat bao cao ve mat do (utilization)

#####################
# Place Hardmacro
#####################
if 0 {
  dbGet [dbGet top.insts.cell.baseClas block -p2].pHaloTop 10
  dbGet [dbGet top.insts.cell.baseClas block -p2].pHaloBot 10
  dbGet [dbGet top.insts.cell.baseClas block -p2].pHaloLeft 10
  dbGet [dbGet top.insts.cell.baseClas block -p2].pHaloRight 10

  placeInstance i_croc_soc/i_croc/gen_sram_bank_1__i_sram/gen_512x32x8x1_i_cut -fixed {620.07 202.36}
  placeInstance i_croc_soc/i_croc/gen_sram_bank_0__i_sram/gen_512x32x8x1_i_cut -fixed {620.07 335.84}

}

###############
# Check Design
###############
checkDesign -all > rpt/${STAGE}/check_design.rpt


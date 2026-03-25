##########
# Set Up
##########
set STAGE 00_init_design

setMultiCpuUsage -localCpu $env(CPU_NUM)

setPreference ConstrainUserXGrid 0.1
setPreference ConstrainUserXOffset 0.1
setPreference ConstrainUserYGrid 0.1
setPreference ConstrainUserYOffset 0.1
setPreference SnapAllConer 1

set central_path .../pd/data 
source .../all_lef_files.tcl 
set init_verilog .../croc_chip_yosys.v 
set init_design_uniquify 1
set init_design_settop 1
set init_top_cell croc_chip 
set init_lef_file $init_lef_files
set init_mmmc_file .../croc_mmmc.view 
set init_pwr_net {VDD}
set init_gnd_net {VSS}
init_design 

puts "Done init design. Pls check log file if any errors during init design"
return 

saveDesign SAVED/${STAGE}_init.ivns

#check lib usage
check_library -all_lib_cell -place > rpt/${STAGE}/check_lib.rpt

#update name 
source ${central_path}/update_name.tcl 

############
#Create Row
############
deleteRow -all 
initCoreRow
cutRow 

##############
# Crate track
##############
add_tracks -offset {Metal1 vert 0 Metal2 horiz 0 Metal3 vert 0 Metal4 horiz 0 Metal5 vert 0 TopMetal1 horiz 0 TopMetal2 vert 0}

############
# Report Uti 
############
checkFPlan -reportUtil > rpt/${STAGE}/check_lib.rpt

####################
# Placed hardMacros
####################
dbGet [dbGet top.insts.cell.baseClass block -p2].pHaloTop 10
dbGet [dbGet top.insts.cell.baseClass block -p2].pHaloBot 10
dbGet [dbGet top.insts.cell.baseClass block -p2].pHaloLeft 10
dbGet [dbGet top.insts.cell.baseClass block -p2].pHaloRight 10

placeInstance {i_croc_soc/i_croc/gen_sram_bank_1__i_sram/gen_512x32x8x1_i_cut} -fixed {620.07 202.36}
placeInstance {i_croc_soc/i_croc/gen_sram_bank_0__i_sram/gen_512x32x8x1_i_cut} -fixed {620.07 335.84}

###################
# Check design
###################

checkDesign -all 

###############
#Global Connect 
###############
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -insts * -override
globalNetConnect VSS -type pgpin -pin VSS -insts * -override

############
# Add endcap
############
setEndCapMode -prefix ENDCAP -leftEdge sky130_fd_sc_hd__endcap -rightEdge sky130_fd_sc_hd__endcap
addEndCap 

verifyEndCap

###############
# Add PG Mesh
###############
source -e -v .../PG/create_pg.tcl
verifyPowerVia

# Check open 
verify_connectivity -net {VDD VSS}

saveDesign SAVED/${STAGE}_PG.invs
return

###############
# Add Well Tap 
###############
addWellTap -cell sky130_fd_sc_hd__tapvpwrvgnd_1 -cellInterval 40 -inRowOffset 25 -prefix WELLTAP 

saveDesign SAVED/${STAGE}_PG.invs

# Report Timing
timeDesign -prePlace -pathReport -slackReport -numPath 1000 -prefix ${STAGE}_prePlace -outDir ./rpt/${STAGE}_prePlace 


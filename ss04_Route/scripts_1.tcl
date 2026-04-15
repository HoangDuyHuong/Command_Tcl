########
# Setup
#######

# Set name of Stage 
set STAGE 06_route_opt 

# set central_path 
set central_path /share/pd/data 

# source some file config and seting 
source ${central_path}/scripts/common/common_settings.tcl
source ${central_path}/scripts/common/user_settings.tcl
source ${central_path}/scripts/common/config.tcl

# Create dir report 
exec mkdir -p ./rpt/${STAGE} 

########### 
# Routing 
###########
# reset config NanoRoute 
setNanoRouteMode -reset

# Khai bao node cong nghe dang su dung  (130nm)
setNanoRouteMode -dbProcessNode 130

# Cho phep tu dong chen Antenna Diode  to fix Antenna
setNanoRouteMode -quiet -routeInsertAntennaDiode 1

# Chi dinh cell cu the (sky130_fd_sc_hd__diode_2)
setNanoRouteMode -quiet -routeAntennaCellName sky130_fd_sc_hd__diode_2

# use timing engine default of tool
setNanoRouteMode -quiet -timingEngine {}

# bat tinh nang dinh tuyen huong thoi gian (Timing-driven) de ko lam hong setup/hold
setNanoRouteMode -quiet -routeWithTimingDriven 1

# bat tinh dinh tuyen can nhac nhieu (Signal Integrity - SI driven)
setNanoRouteMode -quiet -routeWithSiDriven 1

# tat tu dong fix SI sau khi Route 
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0

# Cac cau hinh lap  (iteration) và lop di day (layer): default
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true

# tang cuong no luc cho tool den cac chan kho tiep can 
setNanoRouteMode -routeExpAdvancedPinAccess 2

# DUng array Via  
setNanoRouteMode -drouteUseMultiCutViaEffort default

# at tien to cho cac cell dc fix setup
setOptMode -addInstancePrefix ictc_postRoute_setup_

# (PostRoute Optimization).
# Add buffer, resize cell... to fix Setup timing, Max Tran, Max Cap.
optDesign -postRoute

# Saved database Setup
saveDesign SAVED/${STAGE}_setup.invs

# chay timing report kiem tra sau khi opt 
timeDesign -postRoute        -pathReports -slackReports -numPaths 1000 -prefix croc_postRoute -outDir ./rpt/${STAGE}/${STAGE}_setup
timeDesign -postRoute -hold  -pathReports -slackReports -numPaths 1000 -prefix croc_postRoute -outDir ./rpt/${STAGE}/${STAGE}_hold

# Fix Hold, but don't use 
if 0 {
    # fixing hold
    setOptMode -addInstancePrefix ictc_postRoute_hold_
    optDesign -postRoute -hold

    saveDesign SAVED/${STAGE}_setup.invs
    
    timeDesign -postRoute        -pathReports -slackReports -numPaths 1000 -prefix croc_postRoute -outDir ./rpt/${STAGE}/${STAGE}_setup
    timeDesign -postRoute -hold  -pathReports -slackReports -numPaths 1000 -prefix croc_postRoute -outDir ./rpt/${STAGE}/${STAGE}_hold
}

# Saved 
saveDesign SAVED/${STAGE}.invs

# run checkers
# Utilization
checkFPlan -reportUtil > rpt/${STAGE}/check_util.rpt

# check placement: overlap?,...
checkPlace > rpt/${STAGE}/checkPlace.rpt

# DRC check 
verify_drc -limit 0 > rpt/${STAGE}/verify_drc.rpt


####################
# Filler insertion 
####################

# Khai bao cac loai filler cell se dung de lap khoang trong (thuong la cac cell co do rong khac nhau 1, 2, 4, 8)
setFillerMode -core {sg13g2_fill_1 sg13g2_fill_2 sg13g2_fill_4 sg13g2_fill_8} -corePrefix FILLER

# Insert 
addFiller -doDrc false

# Check 
checkFiller

# Saved 
saveDesign SAVED/${STAGE}_filler.invs


###############
# Export data 
###############
# thao thu muc output
mkdir -p output

# Export file DEF (Design Exchange Format) - chua thong tin ve vi tri cell va duong day (physical layout)
defOut -unit 1000 -usedVia -routing output/${STAGE}/[dbget top.name].def.gz

# Export verilog netlist (Mach chua cong da duoc toi uu hoa kem theo clock tree, buffer...)
saveNetlist output/${STAGE}/[dbget top.name].v

# Export file LEF abstract - Tao file LEF cho chinh khoi thiet ke nay (de tai su dung lam macro cho thiet ke cao cap hon)
write_lef_abstract -extractBlockObs -cutObsMinSpacing -specifyTopLayer TopMetal2 -5.8 -extractBlockPGPinLayers {TopMetal1 TopMetal2} output/${STAGE}/[dbget top.name].lef

# Export file GDS (Graphic Database System) - Day la dinh dang layout tieu chuan de gui xong nha may (Foundry) che tao (Tape-out)
streamOut [dbget top.name].gds -structureName [dbget top.name]_APR -units 1000 -mode ALL

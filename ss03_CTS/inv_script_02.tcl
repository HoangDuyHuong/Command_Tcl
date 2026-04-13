##########
# Setup
#########
set STAGE 04_CTS_opt

# dinh nghia duong dan goc chua data chung
set central_path /pd/data 

# source config va cai dat chung 
source ${central_path}/scripts/common/common_settings.tcl 
source ${central_path}/scripts/common/user_settings.tcl 
source ${central_path}/scripts/common/config.tcl

# Tao thu muc de chua cac file bao cao cho cong doan nay 
exec mkdir -p ./rpt/${STAGE}

# Set don't use 
set dont_use_cells sg13g2_IOPad*
set_dont_use $dont_use_cells 

# thiet lap che do phan tich timing
# -cppr both: bat tinh nang loai bo CRPR cho ca setup va hold 
# -usefulSkew 1: cho phep su dung useful_skew de muon thoi gian giup fix setup
# -analysisType onchipVariation: chay phan tich timing trong che do OCV 
set_analysisMode -cppr both -clockGatingCheck 1 -timeBorrow 1 -useOutputPinCap 1 -sequentiaConstProp 1 -timingSelfLoopNoSkew 0 -enableMultipleDriveNet 1 -clockSrcPath 1 -warn 1 -usefulSkew 1 -analysisType onchipVariation -skew true -clockPropagation sdcControl -log 1 

# chi dinh cac view nao se duoc check setup va hold 
set_interactive_constrain_modes [all_constraint_modes -active]

# bao tools biet bay gio la day clock real roi, ko phai ly tuong nhu cong doan placement  
set_propagated_clock [all_clocks]
redirect -quiet {set honorDomain [getAnalysisMode -honorDomains]} >/dev/null 

# report path group option 
reportPathGroupOption

##############
# Fix setup 
##############
# tu dong bat sua cac loi vi pham DRC: Max capacitance, Max transittion, Max Fanout
setOptMode -fixCap true -fixTran true -fixFanoutLoad true 

# Dat tien to cho cac cell buffer/inv moi duo tool chen vao de de nhan dien sau nay 
setOptMode -addInstancePrefix cell_postCTS_setup 

# cmd toi uu hoa Post-CTS (tap trung vao fix set va DRC)
# -expandedViews: toi uu tren nhieu view 
optDesign -postCTS -expandedViews -timingDebugReport -outDir ./rpt/${STAGE}_setup 

# save database sau khi fix setup 
saveDesign SAVED/${STAGE}_setup.invs 

###########
# fix Hold 
###########
# phan tich timing hold 
timeDesign -postCTS -hold -pathReport -slackReports -numPaths 1000 -prefix croc_postCTS -outDir ./rpt/${STAGE}_hold 
# doi tien to 
setMode -addInstancePrefix postCTS_hold 

# run cmd toi uu hold timing (thuong la add delay buffer vao data path)
optDesign -postCTS -hold -expandedViews -timingDebugReport outDir ./rpt/${STAGE}_hold 

saveDesign SAVED/${STAGE}_hold.invs 

# report timing 
timeDesign -postCTS       -pathReport -slackReports -numPaths 1000 -prefix croc_postCTS -outDir ./rpt/${STAGE}/${STAGE}_Opt_setup 
timeDesign -postCTS -hold -pathReport -slackReports -numPaths 1000 -prefix croc_postCTS -outDir ./rpt/${STAGE}/${STAGE}_Opt_hold 

saveDesign SAVED/${STAGE}_setup.invs 

# xuat bao cao ra file 
checkFPlan -reportUtil > rpt/${STAGE}/check_util.rpt 

#check tong the thiet ke 
checkDesign -all > rpt/${STAGE}/check_design.rpt 

#kiem tra cac loi ve sap xep cell 
checkPlace > rpt/${STAGE}/checkPlace.rpt 

# kiem tra congestion
reportCongestion -overflow -includeBlockage -hotSpot > /rpt/${STAGE}/reportCongestion.rpt 


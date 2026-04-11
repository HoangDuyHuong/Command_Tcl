############
# Setup
###########
set STAGE 03_CTS

# nap cac bien moi truong va thiet lap quy tac thiet ke 
set central_path /.../pd/data 
source ${central_path}/scripts/common_settings.tcl 
source ${central_path}/scripts/user_settings.tcl 
source ${central_path}/scripts/config.tcl 

###############################
# Clock Tree Synthesys - ccopt 
###############################
set_ccopt_mode -integration native
# bat che do CCOpt (clock concurrent optimization) 'native' 
# yeu cau CCOpt dung truc tiep engine tinh toan timing noi tru cua innovus de dat accuracy cao nhat 

###################
# set don't use 
###################
set dont_use_cells sg13g2_IOPad* 
set_dont_use $dont_use_cells
# set tools k tu y dung chan IO pad nay ra de can bang clock 

create_ccopt_clock_tree_spec -file ccopt_native.spec 
source ccopt_native.spec 
# tu dong doc cac file SDC timing consteain de tu sinh ra mo ban dat ta cho mang luoi clock 

setCTSMode -bottonPreferredLayer Metal2
setCTSMode -routeTopPreferredLayer Metal5
# thiet lap cac lop kim loai, uu tien di day mang clock 
# o day, ta set tool uu tien di day clock Metal 2 (lop duoi cung) den Metal5 (tren cung), tranh dung cac Metal khac do ko hop 

# 3 rang buoc
set_ccopt_property target_max_trans 0.8
# Ep transittion/slew toi da 0.8 
set_ccopt_property -max_fanout 32 
# Ep so luong max fanout ma 1 buffer phai keo la 32 
set_ccopt_property -target_skew 0.15 
# Target skew giua cac nhanh la 0.15 

set_ccopt_property override_minimum_skew_target true 
# cho phep ghi de cac gioi han skew toi thieu

set_ccopt_property sink_type -pin cell_name//CLK ignore
# yeu cau tool hay phot lo chan nay di, ko care den pin nay

ccopt_design -cts 
# Lenh quan trong nhat: tool bat dau tong hop, cay dung CTS 
# cam buffer, route va can bang skew dua tren all config tren

saveDesign SAVED/${STAGE}.invs 

exec mkdir -p /rpt/${STAGE}
report_ccpot_skew_group -file ./rpt/${STAGE}/ccpot_skew_group.rpt 
report_ccpot_clock_trees -file ./rpt/${STAGE}/ccpot_skew_group.rpt 
# tao cac thu muc bao cao va xuat ra file bao cao .rpt 

checkPFlan -report > rpt/${STAGE}/check_util.rpt 
checkDesign -all > rpt/${STAGE}/check_design.rpt 
checkPlace > rpt/${STAGE}/checkPlace.rpt 
reportCongestion -overflow -includeBlockage -hotSpot > rpt/report_congestion.rpt 
# chay cac lenh check nhieu giai doan, do ra file .rpt 

timeDesign -postCTS -pathReport -slackReport -numPaths 1000 -prefix croc_postCTS -outDir rpt/${STAGE}/${STAGE}_setup 
timeDesign -postCTS -hold -pathReport -slackReport -numPaths 1000 -prefix croc_postCTS -outDir rpt/${STAGE}/${STAGE}_hold
# -postCTS: cho biet bay gio da co mang clock that, ko phai ly thuong nua, hay tinh delay that 



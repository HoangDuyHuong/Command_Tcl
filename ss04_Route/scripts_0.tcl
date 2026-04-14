############
# Setup
############ 
set STAGE 05_route

set central_path /pd/data 

# source config va setting 
source ${central_path}/scripts/common/common_setting.tcl 
source ${central_path}/scripts/common/user_setting.tcl 
source ${central_path}/scripts/common/config.tcl

# tao thu muc bao cao 
exec mkdir -p ./rpt/${STAGE}

# Route 
# Reset all mode tool route 
setNanoRouteMode -reset 

# Cung cap thong tin ve node cong nghe nanoRoute (130nm)
setNanoRouteMode -dbProcessNode 130

# cho phep tool tu dong chen cac diode de fix antenna trong luc Route 
setNanoRouteMode -quiet -routeInsertAntennaDiode 1

# chi dinh chinh xac ten thu vien cell diode se duoc dung de chen vao mach 
setNanoRouteMode -quiet -routeAntennaCellNam cell_name_diode 

# Cau hinh engine tinh toan timing {}: Default 
setNanoRouteMode -quiet -timingEngine {}

# bat che do timing Driven Route (tool se uu tien di day ngan cho cac duong toi han: critical path)
setNanoRouteMode -quiet -routeWithTimingSiDriven 1

# bat che do SI_Driven: tool se co gang di day sao cho giam thieu hien tuong nhieu xuyen am (cross talk)
setNanoRouteMode -quiet -routeWithSiDriven 1

# tat viec tu dong sua loi SI ngay sau khi Route 
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0

#  cau hinh vong lap bat dau cua Detail Route: Default 
setNanoRouteMode -quiet -drouteStartIteration default 

# cau hinh lop kim loai cuoi cung dc phep di day 
setNanoRouteMode -quiet -routeBottomRoutingLayer default 

# cau hinh vong lap ket thuc cua detail route 
setNanoRouteMode -quiet -drouteEndIteration default 

# tang cuong no luc cua tool trong viec truy cap vao cac chan cua cell, dat biet huu ich trong thiet ke mat do cao, chan kho ket noi 
setNanoRouteMode -routeExpAdvancedPinAcess 2

# Thiet lap muc do co gang chen Multi-Via thay vi sigle via de tang mat do tin cay ca giam dien tro 
setNanoRouteMode -drouteUseMultiCutViaEffort default 

# Lenh chinh: chay route cho toan bo thiet ke, bao gom global route va detail route 
routeDesign -globalDetail 

# Saved design 
saveDesign SAVED/${STAGE}.invs 

# chay phan tich timing setup 
timeDesign -postRoute      -pathReport -slackReport -numPaths 1000 -prefix croc_postRoute -outDir ./rpt/${STAGE}_setup

# chay phan tich timing hold 
timeDesign -postRoute hold -pathReport -slackReport -numPaths 1000 -prefix croc_postRoute -outDir ./rpt/${STAGE}_hold

# run cheker, kiem tra placement xem viec di day co lam phat sinh loi vi tri nao ko (overlap?)
checkPlace > rpt/${STAGE}/checkPlace.rpt 


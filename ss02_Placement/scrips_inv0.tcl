##########
# Set up
#########
set STAGE 02_place_opt

set central_path .../pd/data 

set report_dir rpt 
set stage_rpt ${report_dir}/${STAGE}

if {[glob -nocomplain $stage_rpt] == ""} {exec mkdir $stage_rpt}

source ${central_path} .../common_settings.tcl 
source ${central_path} .../user_settings.tcl 
source ${central_path} .../config.tcl 

##############
#Placement
#############
place_design
# run Global Placement, legalize standard cell on row, no overlap, opt wirelength 

# report timing
timeDesign -PreCTS -pathReport -slackReport -numPaths 1000 -prefix placeOnly -outDir ./rpt/${STAGE}

saveDesign SAVED/${STAGE}.invs
return



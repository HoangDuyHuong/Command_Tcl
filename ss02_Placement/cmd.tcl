# command to see any cell overlap error 
checkPlace

# command to fix cell overlap error 
refinePlace

# cmd to fix cell overlap selected
refinePlace -inst [dbGet selected.name]

# cmd report timing path reg2reg 
report_timing -path_group reg2reg 

# cmd report_timing basic
report_timing -from <start_point> -to <end_point>

# to highlight timing path 
report_timing -from <start_point> -to <end_point> -machine_readable > file_name 
load_timing_debug_report file_name
highlight_timing_report -path 1

# Some cmd to fix timing
# turn on batchMode
setEcoMode -batchMode true \
           - updateTiming false \
           - honorFixedStatus false \
           - honorDontUse false \ 
           - honorDontTouch false \
           - honorFixedNetWire false \
           - refinePlace false \

report_timing -from <start_point> -to <end_point> 
# repeat above report_timing after size cell/ add buffer/ remove buffer/  to see changing in timing path 

# cmd size cell
ecoChangeCell -inst <inst_name> -cell <same ref name function but diff cell size>

# Ex in Design
# Inst name: i_croc_soc/i_croc/i_core_wrap/FE_OCPC5293_FE_RN_89_0
# Cell name: sg13g2_inv_4
# Size cell cmd:
ecoChangeCell -inst i_croc_soc/i_croc/i_core_wrap/FE_OCPC5293_FE_RN_89_0 -cell sg13g2_inv_8
# After size cell
# Inst name: i_croc_soc/i_croc/i_core_wrap/FE_OCPC5293_FE_RN_89_0
# Cell name: sg13g2_inv_8

# cmd to find how many cell size in lib: 
# suggesttion: use get_lib_cell
#Ex to find size cell in lib
[get_object_name [get_lib_cells *sg13g2_inv_*]] "\n"
        sg13g2_stdcell_slow_1p08V_125C/sg13g2_inv_1
        sg13g2_stdcell_slow_1p08V_125C/sg13g2_inv_16
        sg13g2_stdcell_slow_1p08V_125C/sg13g2_inv_2
        sg13g2_stdcell_slow_1p08V_125C/sg13g2_inv_4
        sg13g2_stdcell_slow_1p08V_125C/sg13g2_inv_8
        sg13g2_stdcell_fast_1p32V_m40C/sg13g2_inv_1
        sg13g2_stdcell_fast_1p32V_m40C/sg13g2_inv_16
        sg13g2_stdcell_fast_1p32V_m40C/sg13g2_inv_2
        sg13g2_stdcell_fast_1p32V_m40C/sg13g2_inv_4
        sg13g2_stdcell_fast_1p32V_m40C/sg13g2_inv_8
        -----
        => This is inv cell type cell size ( 1, 2, 4, 8, 16 ).

# cmd to remove buffer 
ecoDeleteRepeater -inst <buffer inst name>
ecoDeleteRepeater -invPair {{inv1 inv2} {inv3 inv4} ... }

#Ex 
ecoDeleteRepeater -inst i_croc_soc/i_croc/i_core_wrap/FE_OCPC5185_FE_OFN1368_2060

# cmd to add buffer
ecoAddRepeater -term i_croc_soc/i_croc/i_core_wrap/_6994_/A -newNetName ECO_NET -name ECO_INST_BUF -cell sg13g2_buf_16 -relativeDistToSink 1 
=> term: pin name which we want insert  buffer to.
=> newNetName: new net name
=> name: new buffer inst name 
=> cell: buffer reference name
=> relativeDistToSink: new buffer add will placed close to sink pin (term).

# turn off ECO mode after apply:
setEcoMode -batchMode false \
           - updateTiming true \
           - honorFixedStatus true \
           - honorDontUse true \ 
           - honorDontTouch true \
           - honorFixedNetWire true \
           - refinePlace true \



Study dbGet command

Cell/Instances
dbGet top.insts.name: Get name of all Instances in the design
dbGet top.insts.cell: get cell type (NAND, INV,...)
dbGet top.insts: Get all Instances (can combine with filters)

Net 
dbGet top.nets.name: List all nets in the design
dbGet top.nets.pin: Get pins connected to each nets
dbGet top.nets.netType: Check if net is special, normal

Placement and Geometry
dbGet top.insts.loc: Get Instances Placement location
dbGet top.insts.orient: Get cell orientation 
dbGet top.insts.status: see if placed/fixed/unplace

Ex:
Cmd take cell status unplacedlaced/placed
dbGet [dbGet -p top.insts.pStatus unplaced/placed].name

cmd take cell have name *INV*
dbGet top.insts.cell.name *INV*

cmd cout total number of Instances in design
llength [dbGet top.insts]

cmd cout total Instances have name *buf_8*
llength [dbGet top.insts.cell.name buf_8]

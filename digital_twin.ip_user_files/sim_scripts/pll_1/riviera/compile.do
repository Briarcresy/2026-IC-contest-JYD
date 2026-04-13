transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic" "+incdir+../../../../digital_twin.gen/sources_1/ip/pll" -l xpm -l xil_defaultlib \
"D:/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"D:/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../ipstatic" "+incdir+../../../../digital_twin.gen/sources_1/ip/pll" -l xpm -l xil_defaultlib \
"../../../../digital_twin.gen/sources_1/ip/pll/pll_clk_wiz.v" \
"../../../../digital_twin.gen/sources_1/ip/pll/pll.v" \

vlog -work xil_defaultlib \
"glbl.v"


onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib frodoBD_opt

do {wave.do}

view wave
view structure
view signals

do {frodoBD.udo}

run -all

quit -force

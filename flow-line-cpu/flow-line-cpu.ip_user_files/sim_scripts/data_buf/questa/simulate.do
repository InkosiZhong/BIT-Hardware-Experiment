onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib data_buf_opt

do {wave.do}

view wave
view structure
view signals

do {data_buf.udo}

run -all

quit -force

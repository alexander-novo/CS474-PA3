#
# Set overall margins for the combined set of plots and size them
# to generate a requested inter-plot spacing
#
if (!exists("MP_LEFT"))   MP_LEFT = .15
if (!exists("MP_RIGHT"))  MP_RIGHT = .95
if (!exists("MP_BOTTOM")) MP_BOTTOM = .14
if (!exists("MP_TOP"))    MP_TOP = .9
if (!exists("MP_xGAP"))   MP_xGAP = 0.07
if (!exists("MP_yGAP"))   MP_yGAP = 0.1

set terminal pdf enhanced size 8,4.8
set output 'out/part_1a.pdf'

set multiplot layout 2,2 columnsfirst title "{/:Bold=15 Result of DFT on f Function}" \
              margins screen MP_LEFT, MP_RIGHT, MP_BOTTOM, MP_TOP spacing screen MP_xGAP, MP_yGAP

unset key
set arrow 1 from -1,0 to 4,0 nohead dt 3

set title 'Real Component'
set xrange [-1:4]
plot "out/part_1a_data.dat" using 1:(0):(0):2 with vectors noborder head lt 1 size .2,20,45 fixed
set xlabel 'x'
set title 'Magnitude'
plot "out/part_1a_data.dat" using 1:(0):(0):4 with vectors noborder head lt 2 size .2,20,45 fixed

unset xlabel
set title 'Imaginary Component'
plot "out/part_1a_data.dat" using 1:(0):(0):3 with vectors noborder head lt 3 size .2,20,45 fixed
set xlabel 'x'
set title 'Phase'
plot "out/part_1a_data.dat" using 1:(0):(0):5 with vectors noborder head lt 4 size .2,20,45 fixed

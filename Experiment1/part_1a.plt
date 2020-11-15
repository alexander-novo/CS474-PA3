#
# Set overall margins for the combined set of plots and size them
# to generate a requested inter-plot spacing
#
if (!exists("MP_LEFT"))   MP_LEFT = .15
if (!exists("MP_RIGHT"))  MP_RIGHT = .95
if (!exists("MP_BOTTOM")) MP_BOTTOM = .14
if (!exists("MP_TOP"))    MP_TOP = .9
if (!exists("MP_xGAP"))   MP_xGAP = 0.12
if (!exists("MP_yGAP"))   MP_yGAP = 0.07

set terminal pdf enhanced
set output 'out/part_1a.pdf'

set multiplot layout 2,2 columnsfirst title "{/:Bold=15 Result of DFT on f Function}" \
              margins screen MP_LEFT, MP_RIGHT, MP_BOTTOM, MP_TOP spacing screen MP_xGAP, MP_yGAP

set format y "%.1f"
set key box opaque
set ylabel 'Real value'
set xrange [-1:5]
unset key
set arrow 1 from -1,0 to 5,0 nohead dt 3

plot "out/part_1a_data.dat" using 1:(0):(0):2 with vectors filled head lw 3 lt 1
set xlabel 'Samples'
set ylabel 'Magnitude'
plot "out/part_1a_data.dat" using 1:(0):(0):4 with vectors filled head lw 3 lt 2

#unset ytics

unset xlabel
set ylabel 'Imaginary value'
plot "out/part_1a_data.dat" using 1:(0):(0):3 with vectors filled head lw 3 lt 3
set xlabel 'Samples'
set ylabel 'Phase'
plot "out/part_1a_data.dat" using 1:(0):(0):5 with vectors filled head lw 3 lt 4

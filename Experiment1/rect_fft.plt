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

set terminal png enhanced size 900, 600
set output 'out/rect_fft.png'

set multiplot layout 2,2 columnsfirst title "{/:Bold=15 Result of FFT on Rect Sample Data}" \
              margins screen MP_LEFT, MP_RIGHT, MP_BOTTOM, MP_TOP spacing screen MP_xGAP, MP_yGAP

set format y "%.1f"
set key box opaque
set ylabel 'Real Component'
set xrange [0:128]
unset key
set arrow 1 from 0,0 to 128,0 nohead dt 3

plot "out/rect_fft.dat" using 1:(0):(0):2 with vectors nohead lw 1 lt 1
set xlabel 'samples'
set ylabel 'Magnitude'
plot "out/rect_fft.dat" using 1:(0):(0):4 with vectors nohead lw 1 lt 2

#unset ytics

unset xlabel
set ylabel 'Imaginary Component'
set yrange[-1.2:1.2]
plot "out/rect_fft.dat" using 1:(0):(0):3 with vectors nohead lw 1 lt 3
set xlabel 'samples'
set ylabel 'Phase'
unset yrange
plot "out/rect_fft.dat" using 1:(0):(0):5 with vectors nohead lw 1 lt 4

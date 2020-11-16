#
# Set overall margins for the combined set of plots and size them
# to generate a requested inter-plot spacing
#
if (!exists("MP_LEFT"))   MP_LEFT = .15
if (!exists("MP_RIGHT"))  MP_RIGHT = .95
if (!exists("MP_BOTTOM")) MP_BOTTOM = .14
if (!exists("MP_TOP"))    MP_TOP = .9
if (!exists("MP_xGAP"))   MP_xGAP = 0.1
if (!exists("MP_yGAP"))   MP_yGAP = 0.1

set terminal pdf enhanced size 8,4.8
set output 'out/fft.pdf'

set multiplot layout 2,2 columnsfirst title "{/:Bold=15 Result of FFT on Cosine Sample Data}" \
              margins screen MP_LEFT, MP_RIGHT, MP_BOTTOM, MP_TOP spacing screen MP_xGAP, MP_yGAP

set key box opaque
set xrange [0:128]
unset key
set arrow 1 from 0,0 to 128,0 nohead dt 3

set title "Real Value"
plot "out/cos_fft.dat" using 1:(0):(0):2 with vectors nohead lw 1 lt 1
set xlabel 'samples'
set title 'Magnitude'
plot "out/cos_fft.dat" using 1:(0):(0):4 with vectors nohead lw 1 lt 2

#unset ytics

unset xlabel
set title 'Imaginary value'
plot "out/cos_fft.dat" using 1:(0):(0):3 with vectors nohead lw 1 lt 3
set xlabel 'samples'
set title 'Phase'
set yrange [-3.14159:3.14159]
set ytics ('-{/Symbol p}' -pi, '-{/Symbol p}/2' -pi / 2, '0' 0, '{/Symbol p}/2' pi / 2, '{/Symbol p}' pi)
plot "out/cos_fft.dat" using 1:(0):(0):5 with vectors nohead lw 1 lt 4

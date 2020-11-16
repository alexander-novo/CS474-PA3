# Set the output to a png file
set terminal pdf enhanced
# The file we'll write to
set output 'out/cos.pdf'
# The graphic title
set title "{/:Bold=15 Cos(2{/Symbol p}ux) with u=8 and N=128 samples}"
unset key
set arrow 1 from 0,0 to 1,0 nohead dt 3
set samples 128
#plot the graphic
plot [0:1] cos(2 * 3.1415926 * x * 8) with linespoints pt 7 ps 1


# Set the output to a png file
set terminal pdf enhanced size 9,4
# The file we'll write to
set output 'out/cos.pdf'
# The graphic title
set title "{/:Bold=15 Cos(2{/Symbol p}ux) with u=8 and N=128 samples}"
set key outside
set arrow 1 from 0,0 to 1,0 nohead dt 3
set samples 400
# Plot the graphic
plot [0:1] cos(2 * 3.1415926 * x * 8) title "cos(2{/Symbol p}ux)", 'out/cos_data.dat' using 1:2 pt 7 ps .5 title "samples"

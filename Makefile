CXXFLAGS     = -std=c++14 -g -fopenmp -Ofast -mavx2 -mfma
OBJDIR       = obj
DEPDIR       = $(OBJDIR)/.deps
# Flags which, when added to gcc/g++, will auto-generate dependency files
DEPFLAGS     = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d

# Function which takes a list of words and returns a list of unique words in that list
# https://stackoverflow.com/questions/16144115/makefile-remove-duplicate-words-without-sorting
uniq         = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))

# Source files - add more to auto-compile into .o files
SOURCES      = Common/image.cpp Common/fft.cpp Common/mask.cpp Experiment1/main.cpp Experiment2/rect.cpp Experiment2/main.cpp Experiment3/main.cpp
# Executable targets - add more to auto-make in default 'all' target
EXEC         = Experiment1/experiment Experiment2/spectrum Experiment2/rect Experiment3/reconstruct
# Targets required for the homework, spearated by experiment
REQUIRED_1   = out/part_1a_data.dat out/cos_data.dat out/cos_fft.dat out/rect_fft.dat out/cos.pdf out/fft.pdf out/rect_fft.pdf out/part_1a.pdf
REQUIRED_2   = out/spectrum_log_rect_512_512_32_32.pgm out/spectrum_log_rect_512_512_64_64.pgm out/spectrum_log_rect_512_512_128_128.pgm
REQUIRED_3   = out/lenna_reconstructed_phase.pgm out/lenna_reconstructed_mag.pgm
REQUIRED_OUT = $(REQUIRED_1) $(REQUIRED_2) $(REQUIRED_3)

SOURCEDIRS   = $(call uniq, $(dir $(SOURCES)))
OBJDIRS      = $(addprefix $(OBJDIR)/, $(SOURCEDIRS))
DEPDIRS      = $(addprefix $(DEPDIR)/, $(SOURCEDIRS))
DEPFILES     = $(SOURCES:%.cpp=$(DEPDIR)/%.d)

.PHONY: all clean report

# By default, make all executable targets and the images required for the homework
all: $(EXEC) $(REQUIRED_OUT)

# Executable Targets
Experiment1/experiment: $(OBJDIR)/Experiment1/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment2/spectrum: $(OBJDIR)/Experiment2/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o $(OBJDIR)/Common/mask.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment2/rect: $(OBJDIR)/Experiment2/rect.o $(OBJDIR)/Common/image.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment3/reconstruct: $(OBJDIR)/Experiment3/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o $(OBJDIR)/Common/mask.o
	$(CXX) $(CXXFLAGS) $^ -o $@

### Experiment 1 Outputs ###
out/cos_data.dat out/cos_fft.dat out/part_1a_data.dat out/rect_fft.dat: Experiment1/experiment | out
	Experiment1/experiment

# Generate plots
out/cos.pdf: Experiment1/cos.plt out/cos_data.dat | out
	gnuplot $<

out/fft.pdf: Experiment1/fft.plt out/cos_fft.dat | out
	gnuplot $<

out/part_1a.pdf: Experiment1/part_1a.plt out/part_1a_data.dat | out
	gnuplot $<

out/rect_fft.pdf: Experiment1/rect_fft.plt out/rect_fft.dat | out
	gnuplot $<

### Experiment 2 Outputs ###
out/rect_%.pgm: Experiment2/rect | out
	Experiment2/rect $(word 1,$(subst _, ,$*)) $(word 2,$(subst _, ,$*)) $(word 3,$(subst _, ,$*)) $(word 4,$(subst _, ,$*)) $@

out/spectrum_rect_%.pgm: Experiment2/spectrum out/rect_%.pgm | out
	Experiment2/spectrum out/rect_$*.pgm $@

out/spectrum_shifted_rect_%.pgm: Experiment2/spectrum out/rect_%.pgm | out
	Experiment2/spectrum out/rect_$*.pgm $@ -s

out/spectrum_log_rect_%.pgm: Experiment2/spectrum out/rect_%.pgm | out
	Experiment2/spectrum out/rect_$*.pgm $@ -s -l

### Experiment 3 Outputs ###
out/%_reconstructed_phase.pgm: Experiment3/reconstruct Images/%.pgm | out
	Experiment3/reconstruct -p Images/$*.pgm $@

out/%_reconstructed_mag.pgm: Experiment3/reconstruct Images/%.pgm | out
	Experiment3/reconstruct -m Images/$*.pgm $@

out/%_reconstructed_mag_log.pgm: Experiment3/reconstruct Images/%.pgm | out
	Experiment3/reconstruct -ml Images/$*.pgm $@


# Figures needed for the report
report: out/cos.pdf out/fft.pdf out/part_1a.pdf out/rect_fft.pdf
report: out/rect_512_512_32_32.png out/rect_512_512_64_64.png out/rect_512_512_128_128.png out/spectrum_rect_512_512_32_32.png out/spectrum_shifted_rect_512_512_32_32.png
report: out/spectrum_log_rect_512_512_32_32.png out/spectrum_log_rect_512_512_64_64.png out/spectrum_log_rect_512_512_128_128.png out/spectrum_log_rect_1024_1024_256_32.png
report: out/lenna_reconstructed_phase.png out/lenna_reconstructed_mag.png out/lenna_reconstructed_mag_log.png

clean:
	rm -rf $(OBJDIR)
	rm -f $(EXEC)
	rm -rf out
	rm -f Images/*.png

# Generate .png images from .pgm images. Needed for report, since pdfLaTeX doesn't support .pgm images
%.png: %.pgm
	pnmtopng $< > $@

# Auto-Build .cpp files into .o
$(OBJDIR)/%.o: %.cpp
$(OBJDIR)/%.o: %.cpp $(DEPDIR)/%.d | $(DEPDIRS) $(OBJDIRS)
	$(CXX) $(DEPFLAGS) $(CXXFLAGS) -c $< -o $@

# Make generated directories
$(DEPDIRS) $(OBJDIRS) out: ; @mkdir -p $@
$(DEPFILES):
include $(wildcard $(DEPFILES))

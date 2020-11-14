CXXFLAGS     = -std=c++17 -g -fopenmp -Ofast -mavx2 -mfma
OBJDIR       = obj
DEPDIR       = $(OBJDIR)/.deps
# Flags which, when added to gcc/g++, will auto-generate dependency files
DEPFLAGS     = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d

# Source files - add more to auto-compile into .o files
SOURCES      = Common/image.cpp Common/fft.cpp Common/mask.cpp Experiment1/main.cpp Experiment2/rect.cpp Experiment2/main.cpp Experiment3/main.cpp
# Executable targets - add more to auto-make in default 'all' target
EXEC         = Experiment1/experiment Experiment2/spectrum Experiment2/rect Experiment3/experiment
# Targets required for the homework, spearated by experiment
REQUIRED_1   = out/part_1a_data.dat out/cos_data.dat out/cos_fft.dat out/rect_fft.dat out/cos_plot.png out/fft_plot.png out/rect_fft_plot.png out/part_1a_plot.png
REQUIRED_2   = out/spectrum_log_rect_512_512_32_32.pgm out/spectrum_log_rect_512_512_64_64.pgm out/spectrum_log_rect_512_512_128_128.pgm
REQUIRED_3   = out/lenna-mag.pgm out/lenna-phase.pgm
REQUIRED_OUT = $(REQUIRED_1) $(REQUIRED_2) $(REQUIRED_3)

OBJDIRS      = $(addprefix $(OBJDIR)/, $(dir $(SOURCES)))
DEPDIRS      = $(addprefix $(DEPDIR)/, $(dir $(SOURCES)))
DEPFILES     = $(SOURCES:%.cpp=$(DEPDIR)/%.d)

.PHONY: all clean report

# By default, make all executable targets and the images required for the homework
all: $(EXEC) $(REQUIRED_OUT)

# Executable Targets
Experiment1/experiment: $(OBJDIR)/Experiment1/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment2/spectrum: $(OBJDIR)/Experiment2/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o $(OBJDIR)/Common/mask.o
	$(CXX) $(CXXFLAGS) $^ -o $@

<<<<<<< HEAD
Experiment3/experiment: $(OBJDIR)/Experiment3/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o
=======
Experiment2/rect: $(OBJDIR)/Experiment2/rect.o $(OBJDIR)/Common/image.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment3/experiment: $(OBJDIR)/Experiment3/main.o $(OBJDIR)/Common/image.o $(OBJDIR)/Common/fft.o $(OBJDIR)/Common/mask.o
>>>>>>> 2f47ef7cac30383cc3da33925f356fff7df474de
	$(CXX) $(CXXFLAGS) $^ -o $@

### Experiment 1 Outputs ###
out/%.dat: Experiment1/experiment | out
	Experiment1/experiment

# Generate plots
out/%_plot.png: Experiment1/%.plt
	gnuplot Experiment1/$*.plt

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
out/%-mag.pgm out/%-phase.pgm: Experiment3/experiment Images/%.pgm
	Experiment3/experiment Images/$*.pgm out/$*-mag.pgm out/$*-phase.pgm

# Figures needed for the report
report: out/rect_512_512_32_32.png out/rect_512_512_64_64.png out/rect_512_512_128_128.png out/spectrum_rect_512_512_32_32.png out/spectrum_shifted_rect_512_512_32_32.png
report: out/spectrum_log_rect_512_512_32_32.png out/spectrum_log_rect_512_512_64_64.png out/spectrum_log_rect_512_512_128_128.png out/spectrum_log_rect_1024_1024_256_32.png

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

CXXFLAGS     = -std=c++17 -fopenmp -g
OBJDIR       = obj
DEPDIR       = $(OBJDIR)/.deps
# Flags which, when added to gcc/g++, will auto-generate dependency files
DEPFLAGS     = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d

# Source files - add more to auto-compile into .o files
SOURCES      = Common/image.cpp Experiment1/main.cpp Experiment2/main.cpp Experiment3/main.cpp
# Executable targets - add more to auto-make in default 'all' target
EXEC         = Experiment1/correlate Experiment2/smooth Experiment3/median
# Targets required for the homework, spearated by experiment
REQUIRED_1   = 
REQUIRED_2   = 
REQUIRED_3   = 
REQUIRED_OUT = $(REQUIRED_1) $(REQUIRED_2) $(REQUIRED_3)

OBJDIRS      = $(addprefix $(OBJDIR)/, $(dir $(SOURCES)))
DEPDIRS      = $(addprefix $(DEPDIR)/, $(dir $(SOURCES)))
DEPFILES     = $(SOURCES:%.cpp=$(DEPDIR)/%.d)

.PHONY: all clean report

# By default, make all executable targets and the images required for the homework
all: $(EXEC) $(REQUIRED_OUT)

# Executable Targets
Experiment1/correlate: $(OBJDIR)/Experiment1/main.o $(OBJDIR)/Common/image.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment2/smooth: $(OBJDIR)/Experiment2/main.o $(OBJDIR)/Common/image.o
	$(CXX) $(CXXFLAGS) $^ -o $@

Experiment3/median: $(OBJDIR)/Experiment3/main.o $(OBJDIR)/Common/image.o
	$(CXX) $(CXXFLAGS) $^ -o $@

### Experiment 1 Outputs ###


### Experiment 2 Outputs ###


### Experiment 3 Outputs ###


# Figures needed for the report
report: 

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

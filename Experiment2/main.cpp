// Experiment2/main.cpp
#include <chrono>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>

#include "../Common/fft.h"

// Struct for inputting arguments from command line
struct Arguments {
	char *inputImagePath, *outImagePath;
	double A;  // High Boost option
	Image inputImage;
	std::ofstream outFile;
	bool logTransform = false;
	bool shift        = false;
};

bool verifyArguments(int argc, char** argv, Arguments& arg, int& err);
void printHelp();

int main(int argc, char** argv) {
	int err;
	Arguments arg;

	if (!verifyArguments(argc, argv, arg, err)) { return err; }

	std::complex<float>* transform =
	    new std::complex<float>[arg.inputImage.rows * arg.inputImage.cols];

	// Take Fourier Transform, applying shift if specified
	fft2D(arg.inputImage, transform, arg.shift);

	// Plot the spectrum and apply log intensity transform if specified
	MaskResult<float> spectrum =
	    plotSpectrum(transform, arg.inputImage.rows, arg.inputImage.cols);
	if (arg.logTransform) {
		spectrum.transform([](const float& x) { return (float) log(1 + x); });
	}

	// Write spectrum plot out as image
	arg.outFile << (Image) spectrum;
}

bool verifyArguments(int argc, char** argv, Arguments& arg, int& err) {
	if (argc < 2 ||
	    (argc < 3 && strcmp(argv[1], "-h") && strcmp(argv[1], "--help"))) {
		std::cout << "Missing operand.\n\n";
		err = 1;
		printHelp();
		return false;
	}

	if (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
		printHelp();
		return false;
	}

	// Required arguments
	arg.inputImagePath = argv[1];
	std::ifstream inFile(argv[1]);
	try {
		arg.inputImage = Image::read(inFile);
	} catch (std::exception& e) {
		std::cout << "Image \"" << argv[1] << "\"failed to be read: \"" << e.what()
		          << "\"\n";
		err = 2;
		return false;
	}

	arg.outImagePath = argv[2];
	arg.outFile.open(argv[2]);
	if (!arg.outFile) {
		std::cout << "Could not open \"" << argv[2] << "\"\n";
		err = 2;
		return false;
	}

	// Optional Arguments
	for (unsigned i = 3; i < argc; i++) {
		if (!strcmp(argv[i], "-s")) {
			arg.shift = true;
		} else if (!strcmp(argv[i], "-l")) {
			arg.logTransform = true;
		} else {
			std::cout << "Unrecognised argument \"" << argv[i] << "\".\n";
			printHelp();
			err = 1;
			return false;
		}
	}

	return true;
}

void printHelp() {
	std::cout << "Usage: spectrum <input image> <output image> [options]   (1)\n"
	          << "   or: spectrum -h                                       (2)\n\n"
	          << "(1) Take an image file as input, and output the spectrum\n"
	          << "    of its fourier transform.\n"
	          << "(2) Print this help menu\n\n"
	          << "OPTIONS\n"
	          << "  -s  Shift the fourier transform to center its period\n"
	          << "      on the center of the image.\n"
	          << "  -l  Apply a logarithmic intensity transformation to the\n"
	          << "      resulting image, allowing for better visualisation of\n"
	          << "      the outer edges of the period.\n";
}
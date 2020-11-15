// Experiment3/main.cpp
#include <cmath>
#include <complex>
#include <cstring>
#include <fstream>
#include <iostream>

#include "../Common/fft.h"

// Struct for inputting arguments from command line
struct Arguments {
	char *inputImagePath, *outImagePath;
	Image inputImage;
	std::ofstream outFile;
	enum {
		MAGNITUDE_ONLY,
		MAGNITUDE_LOG,
		PHASE_ONLY,
	} mode;
};

bool verifyArguments(int argc, char** argv, Arguments& arg, int& err);
void printHelp();

int main(int argc, char** argv) {
	int err;
	Arguments arg;

	if (!verifyArguments(argc, argv, arg, err)) { return err; }

	// Computer Fourier Transform. Don't shift, since we're not visualizing.
	std::complex<float>* transform =
	    new std::complex<float>[arg.inputImage.rows * arg.inputImage.cols];
	fft2D(arg.inputImage, transform, false);

	switch (arg.mode) {
		case Arguments::MAGNITUDE_ONLY:
		case Arguments::MAGNITUDE_LOG:
			// Get rid of phase information by setting everything equal to its
			// magnitude
#pragma omp parallel for
			for (unsigned i = 0; i < arg.inputImage.rows * arg.inputImage.cols; i++) {
				transform[i] = std::abs(transform[i]);
			}
			break;
		case Arguments::PHASE_ONLY:
			// Get rid of magnitude information by dividing out magnitude
#pragma omp parallel for
			for (unsigned i = 0; i < arg.inputImage.rows * arg.inputImage.cols; i++) {
				transform[i] /= std::abs(transform[i]);
			}
			break;
	}

	// Take inverse transform
	fft2D(transform, arg.inputImage.rows, arg.inputImage.cols, 1);

	float min = std::round(transform[0].real()),
	      max = std::round(transform[0].real());

	MaskResult<float> reconstructed(arg.inputImage.rows, arg.inputImage.cols);
	// Reconstruct image from inverse transform
#pragma omp parallel for collapse(2)
	for (unsigned y = 0; y < arg.inputImage.rows; y++) {
		for (unsigned x = 0; x < arg.inputImage.cols; x++) {
			// Inverse transform gives complex values, but everything *should* be
			// real. Smooth out rounding errors by rounding to nearest number.
			float realVal = std::round(transform[y * arg.inputImage.cols + x].real());
			reconstructed[y][x] = realVal;

			if (realVal > max)
				max = realVal;
			else if (realVal < min)
				min = realVal;
		}
	}

	reconstructed.min = min;
	reconstructed.max = max;

	if (arg.mode == Arguments::MAGNITUDE_LOG)
		reconstructed.transform(
		    [min](const float& x) { return std::log(1 + x - min); });

	arg.outFile << (Image) reconstructed;
}

bool verifyArguments(int argc, char** argv, Arguments& arg, int& err) {
	if (argc < 2 ||
	    (argc < 4 && strcmp(argv[1], "-h") && strcmp(argv[1], "--help"))) {
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

	if (!strcmp(argv[1], "-m")) {
		arg.mode = Arguments::MAGNITUDE_ONLY;
	} else if (!strcmp(argv[1], "-ml")) {
		arg.mode = Arguments::MAGNITUDE_LOG;
	} else if (!strcmp(argv[1], "-p")) {
		arg.mode = Arguments::PHASE_ONLY;
	} else {
		std::cout << "Option \"" << argv[1] << "\" not recognised.\n\n";
		printHelp();
		err = 1;
		return false;
	}

	arg.inputImagePath = argv[2];
	std::ifstream inFile(argv[2]);
	try {
		arg.inputImage = Image::read(inFile);
	} catch (std::exception& e) {
		std::cout << "Image \"" << argv[2] << "\" failed to be read: \"" << e.what()
		          << "\"\n";
		err = 2;
		return false;
	}

	arg.outImagePath = argv[3];
	arg.outFile.open(argv[3]);
	if (!arg.outFile) {
		std::cout << "Could not open \"" << argv[3] << "\"\n";
		err = 2;
		return false;
	}

	return true;
}

void printHelp() {
	std::cout
	    << "Usage: reconstruct -p  <input image> <output image>          (1)\n"
	    << "   or: reconstruct -m  <input image> <output image>          (2)\n"
	    << "   or: reconstruct -ml <input image> <output image>          (3)\n"
	    << "   or: reconstruct -h                                        (4)\n\n"
	    << "(1) (phase-only) Take an image file as input, calculate\n"
	    << "    Fourier Transform, set magnitude to 0, and then reconstruct\n"
	    << "    the image through inverse Fourier Transform.\n"
	    << "(2) (magnitude-only) Take an image file as input, calculate\n"
	    << "    Fourier Transform, set phase to 0, and then reconstruct\n"
	    << "    the image through inverse Fourier Transform.\n"
	    << "(3) (magnitude-only with logarithmic inenstiy transformation)\n"
	    << "    Same as (2) but a logarithmic intensity transformation\n"
	    << "    is applied, allowing to see dark details.\n"
	    << "(4) Print this help menu\n";
}
// Experiment2/rect.cpp
#include <chrono>
#include <fstream>
#include <iostream>
#include <vector>

#include "../Common/fft.h"

int main(int argc, char** argv) {
	if (argc < 6) {
		std::cout << "Too few arguments!\n\n"
		          << "rect <image height> <image width> <rectangle height> "
		             "<rectangle width> <output file>\n";
		return 1;
	}

	unsigned imageHeight = strtoul(argv[1], nullptr, 10),
	         imageWidth  = strtoul(argv[2], nullptr, 10),
	         rectHeight  = strtoul(argv[3], nullptr, 10),
	         rectWidth   = strtoul(argv[4], nullptr, 10);

	if (imageHeight == 0) {
		std::cout << "Could not interpret \"" << argv[1]
		          << " as a positive integer.\n";
		return -1;
	} else if (imageWidth == 0) {
		std::cout << "Could not interpret \"" << argv[2]
		          << " as a positive integer.\n";
		return -1;
	} else if (rectHeight == 0) {
		std::cout << "Could not interpret \"" << argv[3]
		          << " as a positive integer.\n";
		return -1;
	} else if (rectWidth == 0) {
		std::cout << "Could not interpret \"" << argv[4]
		          << " as a positive integer.\n";
		return -1;
	}
	Image rect(imageHeight, imageWidth, 255);
	for (unsigned y = 0; y < rect.rows; y++) {
		for (unsigned x = 0; x < rect.cols; x++) {
			rect[y][x] =
			    (y > (rect.rows / 2 - rectHeight / 2)) &&
			            (y <= (rect.rows - rect.rows / 2 + rectHeight / 2)) &&
			            (x > (rect.cols / 2 - rectWidth / 2)) &&
			            (x <= (rect.cols - rect.cols / 2 + rectWidth / 2)) ?
			        255 :
			        0;
		}
	}

	std::ofstream outfile(argv[5]);
	outfile << rect;
	outfile.close();
}
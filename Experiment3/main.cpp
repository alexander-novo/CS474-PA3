// Experiment3/main.cpp
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <complex>
#include <cmath>
#include <algorithm>
#include <iterator>

#include "../Common/fft.h"

/* @Brief: Removes either the magnitude or phase of a Fourier Transofrmed image
   @Param: image - the input image
   @Param: comp - the flag for which component to keep, 0 keeps the magnitude,
   				  1 keeps the phase.
   @Return: void
*/
void set_mag_phase(Image& image, bool comp) {

	float real_values[image.cols * image.rows];
 	float imag_values[image.cols * image.rows] = {0}; // intitializae imaginary part to zero

 	// get real part from image
 	for (int i = 0; i < image.cols; i++){
 		for (int j = 0; j < image.rows; j++){
 			real_values[i * image.cols + j] = image[i][j];
 		}
 	}

 	// perform the 2D DFT
 	fft2D(image.cols, image.rows, real_values, imag_values, -1);

 	// Keep magnitude component
 	if (comp == 0) {
 		for (int i = 0; i < image.cols * image.rows; i++) {

 			real_values[i] = sqrt(pow(real_values[i], 2) + pow(imag_values[i], 2));
 			imag_values[i] = 0;
 		}
 	}

 	// Keep phase component
 	else {
 		for (int i = 0; i < image.cols * image.rows; i++) {

 			float theta = atan2(imag_values[i], real_values[i]);
 			real_values[i] = cos(theta);
 			imag_values[i] = sin(theta);
 		}
 	}

 	// inverse 2D DFT
 	fft2D(image.cols, image.rows, real_values, imag_values, 1);

 	float max = 0.0;
	float min = 1000000.0;
	float value;

	// get max and min values for normalization
 	for (int i = 0; i < image.rows; i++){
		for (int j = 0; j < image.cols; j++){
			value = real_values[i * image.rows + j];

			if(value > max){
				max = value;
			}
			if(value < min)
				min = value;
		}
	}

	// scale each pixel and update final image
	for (int i = 0; i < image.rows; i++){
		for (int j = 0; j < image.cols; j++){

			double scaled_value = 255.0 * ((real_values[i*image.cols + j] - min) / (double)(max - min));
			image[i][j] = (int) scaled_value;
		}
	}
}

int main(int argc, char** argv) {
	std::cout << "Experiment 3" << std::endl;

	// Get input image
	std::ifstream inFile(argv[1]);
 	Image image = Image::read(inFile);
 	Image zero_mag = Image(image);

 	// Set magnitude and phase
 	set_mag_phase(image, 0);
 	set_mag_phase(zero_mag, 1);

 	// Output modified images
 	std::ofstream outFile(argv[2]);
 	outFile << image;
 	outFile.close();

 	outFile.open(argv[3]);
 	outFile << zero_mag;
 	outFile.close();

 	return 0;
}
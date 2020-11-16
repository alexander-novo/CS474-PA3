// Experiment1/main.cpp
#include <cmath>
#include <complex>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "../Common/fft.h"

int main(int argc, char** argv) {
	std::cout << "Experiment 1" << std::endl;

	//////////////////////// Part a /////////////////////////////

	// Discrete function f
	std::complex<float> f[4] = {std::complex<float>(2, 0), std::complex<float>(3, 0),
	                            std::complex<float>(4, 0), std::complex<float>(4, 0)};
	std::complex<float> f_copy[4];
	std::copy(f, f + 4, f_copy);

	// Perform the DFT
	fft(f, 4, -1);

	// Output results from DFT
	std::ofstream outFile("out/part_1a_data.dat");
	for (int i = 0; i < 4; i++) {
		f[i] = f[i] / std::complex<float>(4, 0);

		std::cout << "F(f): " << f[i] << std::endl;
		outFile << i << " " << f[i].real() << " " << f[i].imag() << " "
		        << std::abs(f[i]) << " " << std::arg(f[i]) << std::endl;
	}
	outFile.close();

	// Perfrom the inverse DFT to verify results
	fft(f, 4, 1);

	for (int i = 0; i < 4; i++) { std::cout << "F`( F(f) ): " << f[i] << std::endl; }

	//////////////////////// Part b /////////////////////////////

	float step = 1.0 / 128.0;
	std::complex<float> cos_samples[128];

	// Calculate cosine samples
	std::ofstream outCosFile("out/cos_data.dat");
	for (int i = 0; i < 128; i++) {
		cos_samples[i] = std::cos(2.0 * M_PI * 8.0 * (float) (i * step));
		outCosFile << i * step << " " << cos_samples[i].real() << std::endl;
	}
	outCosFile.close();

	// Perform shift
	float mod = 1;
	for (int i = 0; i < 128; i++) {
		cos_samples[i] = cos_samples[i] * mod;
		mod *= -1;
	}

	// Perform the DFT on the Cosine samples
	fft(cos_samples, 128, -1);

	// Ouput DFT cosine results
	std::ofstream outCosFFT_File("out/cos_fft.dat");
	for (int i = 0; i < 128; i++) {
		cos_samples[i] = cos_samples[i] / std::complex<float>(128, 0);

		outCosFFT_File << i << " " << cos_samples[i].real() << " "
		               << cos_samples[i].imag() << " " << std::abs(cos_samples[i])
		               << " " << std::arg(cos_samples[i]) << std::endl;
	}
	outCosFFT_File.close();

	//////////////////////// Part c /////////////////////////////

	std::ifstream inRectFile("Experiment1/Rect_128.dat");
	std::complex<float> rect_samples[128];

	// Read Rect data from file
	int index = 0;
	std::string line;
	while (std::getline(inRectFile, line)) {
		rect_samples[index] = std::stof(line) * std::pow(-1, index);
		index++;
	}

	// Perform the DFT on Rect data
	fft(rect_samples, 128, -1);

	// Output results of DFT on Rect data
	std::ofstream outRectFile("out/rect_fft.dat");
	for (int i = 0; i < 128; i++) {
		rect_samples[i] = rect_samples[i] / std::complex<float>(128, 0);

		outRectFile << i << " " << rect_samples[i].real() << " "
		            << rect_samples[i].imag() << " " << std::abs(rect_samples[i])
		            << " " << std::arg(rect_samples[i]) << std::endl;
	}
	outRectFile.close();

	return 0;
}

#include "fft.h"

#define _USE_MATH_DEFINES

#include <algorithm>
#include <cmath>

void fft(std::complex<float> data[], unsigned long n, int isign) {
	// Bit-reverse swapping
	// i is the index of the element we're swapping, and j is its bit-reverse
	// Skip 0, since it is always first (and its bit reverse mapping is itself).
	// Start at 1, whose bit reverse is 100...0 = n / 2.
	// Don't worry about the last element, whose bit reverse is itself again
	for (unsigned i = 1, j = n / 2; i < (n - 1); i++) {
		// Only swap if we're swapping with something ahead of us.
		// Avoids double-swapping and self-swapping.
		if (j > i) { std::swap(data[i], data[j]); }

		// Since we're adding to i one at a time, from the least-significant bit
		// leftward, the bit reverse (j) should be added to one at a time, from the
		// most-significant rightward. We do this by following this algorithm:
		// starting from the left and moving rightward, find the first 0. Any bits we
		// pass over that are 1, set them to 0 and move on (as a carry). Then set the
		// first 0 that we didn't just set to 1. m takes the form of 100...0 and as we
		// go on, the 1 shifts rightward. If j & m is nonzero, then there in j, is a 1
		// in the same bit as m, so we set it to 0 by XOR-ing it, then shift m
		// rightward. Finally, set the correct 0 to 1, by OR-ing with m
		unsigned m = n / 2;
		while (m > 0 && j & m) {
			j ^= m;
			m >>= 1;
		}
		j |= m;
	}

	// Compute Fourier Transform bottom-up with dynamic programming.
	// Each loop computes all of the M-sample fourier transforms,
	// terminating with the n-sample fourier transform we want.
	// Note that we don't have to worry about 1-sample fourier
	// transforms, as these are the samples themselves (and are
	// already computed).
	for (unsigned M = 2; M <= n; M *= 2) {
		// The M-th principle root of unity (or its inverse depending on isign)
		double theta = isign * (2 * M_PI / M);
		std::complex<double> W_M(cos(theta), sin(theta));

		// An M-th root of unity. The M-th principle root of
		// unity above to the u-th power (starting at 0,
		// which is always 1 + 0i)
		std::complex<double> W_Mu(1, 0);

		// For each group, iterate through the samples in the
		// group. We only iterate through the first half
		// since we can calculate any sample in the second
		// half with no additional cost by calculating the
		// corresponding sample in the first half.
		for (unsigned u = 0; u < M / 2; u++) {
			// Iterate through all of the groups of M
			// samples. Note that i ≡ u (mod M), so i is the
			// index of the u-th sample of each group.

			// Before execution, the samples are split into
			// two smaller sub-groups of M/2 samples each,
			// the evens and the odds. Because of our
			// bit-reverse swapping from earlier, the evens
			// are the first half of the group, and the odds
			// are the second half of the group. After
			// execution, these two sub-groups of M/2 samples
			// will be replaced a single group of M samples
			// by combining the same sample from each of the
			// sub-groups together (offset by M/2) into the
			// corresponding sample of the overall group. A
			// slightly different combination of the same
			// samples will also gives us the larger sample
			// offset by M/2. In this way, we can calculate
			// in place (rather than creating a copy of the
			// sub-groups to fill in the larger group).

			// The reason we iterate through the groups
			// inside iterating through the elements of each
			// group is because the i-th elements of each
			// group have a common multiplier (W_M^u). In
			// this way, we can calculate this multiplier and
			// use it for the u-th element in every group
			// before proceeding, since each group uses
			// distinct values and each pair of samples in
			// each group uses distinct pairs of samples from
			// sub-groups
			for (unsigned i = u; i < n; i += M) {
				// Since i ≡ u (mod M) and u is always < M /
				// 2, then before execution, i is the index
				// of an element in the even sub-group. To
				// calculate the value of the larger sample
				// at i, we also need the corresponding
				// sample in the odd sub-group, who index is
				// i + M / 2 (see above).
				unsigned j = i + M / 2;

				// Temp value of F_odd * W_M^u for
				// calculating in-place. Promoted to double for precision.
				std::complex<double> temp = std::complex<double>(data[j]) * W_Mu;

				// Calculate value of
				// F(u + M/2) = F_even(u) - F_odd(u) * W_M^u
				// Promoted to double for precision.
				data[j] = std::complex<double>(data[i]) - temp;

				// Calculate value of F(u) = F_even(u) +
				// F_odd(u) * W_M^u, using the fact that F(u)
				// and F_even(u) are stored in the same spot
				data[i] += temp;
			}

			// Calculate W_M^{u + 1} = W_M^u * W_M
			W_Mu *= W_M;
		}
	}
}
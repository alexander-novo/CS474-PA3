#include "mask.h"

template <>
MaskResult<Image::pixelT>::operator Image() && {
	Image re(_rows, _cols, 255, _data);

	_rows = _cols = min = max = 0;
	_data                     = nullptr;

	return re;
}
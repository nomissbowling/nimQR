# scanner.nim

import qrutils, ./private/qrcommon
import pixie
import pixie/imageplanes
import stdnim

proc scan*(gi: ImagePlane): StdVector[QRdetect]=
  # expects gi is a 1ch grayscale
  result = gi.scanQR

proc scan*(fpath: string): StdVector[QRdetect]=
  result = fpath.readImage.toGray(toGrayCustomAW).scan

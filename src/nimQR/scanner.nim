# scanner.nim

import qrutils, ./private/qrcommon
import stdnim

proc scan*(gi: ImagePlane): StdVector[QRdetect]=
  # expects gi is a 1ch grayscale
  discard gi.scanQR(result)

proc scan*(fpath: string): StdVector[QRdetect]=
  var qri: QRimage
  discard qri.load(fpath)
  result = scan(qri.toGray)

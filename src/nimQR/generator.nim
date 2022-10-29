# generator.nim

import ./private/qrcommon
import pixie/imageplanes

proc gen*(msg: string): ImagePlane=
  result = msg.genQR

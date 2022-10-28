# generator.nim

import qrutils, ./private/qrcommon

proc gen*(msg: string): ImagePlane=
  result = msg.genQR

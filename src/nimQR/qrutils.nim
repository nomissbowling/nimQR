# qrutils.nim

import pixie
import pixie/imageplanes
import stdnim

type
  QRpoint* = tuple[x: cint, y: cint]

  QRdetect* = object
    typ*: StdString
    msg*: StdString
    loc*: StdVector[QRpoint]

proc pxScale*(im: Image; scale: int; x, y: int; fgc: ColorRGBA)=
  let scl = scale.float32
  var p = newPath()
  p.rect(rect(x.float32 * scl, y.float32 * scl, scl, scl))
  im.fillPath(p, fgc)

proc deco*(qr: ImagePlane, border: int, scale: int,
  fgc: ColorRGBA, bgc: ColorRGBA=rgba(0, 0, 0, 0)): Image=
  let
    n = qr.w + border * 2
    w = n * scale
    h = w
  result = newImage(w, h)
  for j in 0..<n:
    if j < border or j >= qr.h + border:
      for i in 0..<n:
        result.pxScale(scale, i, j, bgc)
    else:
      for i in 0..<n:
        if i < border or i >= qr.w + border:
          result.pxScale(scale, i, j, bgc)
        else:
          let
            y = j - border
            x = i - border
          result.pxScale(scale, i, j,
            if qr.px[y * qr.w + x] != 0x00: fgc else: bgc)

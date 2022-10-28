# qrutils.nim

import pixie
import stdnim

type
  QRpoint* = tuple[x: cint, y: cint]

type
  QRdetect* = object
    typ*: StdString
    msg*: StdString
    loc*: StdVector[QRpoint]

type
  ImagePlane* = ref object
    w*, h*: int
    px*: seq[uint8]

proc newImagePlane*(w, h: int): ImagePlane=
  result = ImagePlane(w: w, h: h, px: newSeq[uint8](w * h))

proc toGray*(rgba: ColorRGBA): uint8=
  # 0.2126R + 0.7152G + 0.0722B = Y of CIE XYZ
  # 0.300R + 0.590G + 0.110B NTSC/PAL
  # 0.299R + 0.587G + 0.114B ITU-R Rec BT.601
  if rgba.a == 0:
    result = 0xff'u8
  else:
    const
      fr: uint16 = (0.299 * 255).uint16
      fg: uint16 = (0.587 * 255).uint16
      fb: uint16 = (0.114 * 255).uint16
      # fa: uint16 = (1.000 * 255).uint16
    let
      r: uint8 = ((rgba.r * fr) div 255).uint8
      g: uint8 = ((rgba.g * fg) div 255).uint8
      b: uint8 = ((rgba.b * fb) div 255).uint8
      # a: uint8 = ((rgba.a * fa) div 255).uint8
    result = r + g + b

proc toGray*(im: Image): ImagePlane= # {.hasSimd, raises: [].} =
  # expects im is a 4ch RGBA
  result = newImagePlane(im.width, im.height)
  for i in 0..<result.px.len:
    result.px[i] = im.data[i].toGray

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

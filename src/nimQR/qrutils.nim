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
  QRmap* = object
    sz*: int
    p*: seq[char]

type
  QRimage* = object
    qr*: QRmap
    ch*, w*, h*: int
    px*: seq[uint8]

type
  RGBA* = tuple[r, g, b, a: uint8]

template asBE32ptr*(pixieu32asBEu32: ColorRGBX): ptr uint32=
  cast[ptr uint32](pixieu32asBEu32.addr)

template asBE32ptr*(tpl4u8asBEu32: RGBA): ptr uint32=
  cast[ptr uint32](tpl4u8asBEu32[0].unsafeAddr)

template assignAsBE32*(tpl4u8asBEu32: RGBA, u32BE: uint32)=
  tpl4u8asBEu32.asBE32ptr[] = u32BE

template asBE32ptr*(u8x4asBEu32: uint8): ptr uint32=
  cast[ptr uint32](u8x4asBEu32.unsafeAddr)

template assignAsBE32*(u8x4asBEu32: uint8, tpl4u8asBEu32: RGBA)=
  u8x4asBEu32.asBE32ptr[] = tpl4u8asBEu32.asBE32ptr[]

template newRGBA*(r, g, b: uint8; a: uint8=0xff'u8): RGBA=
  (r, g, b, a)

template newRGBA*(r, g, b: int; a: int=0xff): RGBA=
  (r.uint8, g.uint8, b.uint8, a.uint8)

proc newRGBA*(abgr: uint32=0'u32): RGBA=
  result.assignAsBE32(abgr) # assign rgba as BE when input abgr is LE

proc pxScale*(qri: var QRimage, scale: int; ch, w, x, y: int, fgc: RGBA)=
  for j in 0..<scale:
    for i in 0..<scale:
      qri.px[ch * (w * (y * scale + j) + (x * scale + i))].assignAsBE32(fgc)

proc deco*(qr: QRmap, border: int, scale: int, fgc: RGBA, bgc: RGBA=newRGBA()):
  QRimage=
  let
    ch = 4
    n = qr.sz + border * 2
    w = n * scale
    h = w
    px = newSeq[uint8](ch * w * h)
  result = QRimage(qr: qr, ch: ch, w: w, h: h, px: px)
  for j in 0..<n:
    if j < border or j >= qr.sz + border:
      for i in 0..<n:
        result.pxScale(scale, ch, w, i, j, bgc)
    else:
      for i in 0..<n:
        if i < border or i >= qr.sz + border:
          result.pxScale(scale, ch, w, i, j, bgc)
        else:
          let
            y = j - border
            x = i - border
          result.pxScale(scale, ch, w, i, j,
            if qr.p[y * qr.sz + x] == '*': fgc else: bgc)

proc toGray*(rgba: RGBA): uint8=
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

proc toGray*(qri: QRimage): QRimage=
  # expects qri is a 4ch RGBA
  assert qri.ch == 4
  let
    ch = 1
    w = qri.w
    h = qri.h
    px = newSeq[uint8](ch * w * h)
  result = QRimage(qr: qri.qr, ch: ch, w: w, h: h, px: px)
  for j in 0..<h:
    for i in 0..<w:
      let rgba = newRGBA(qri.px[qri.ch * (w * j + i)].asBE32ptr[])
      result.px[ch * (w * j + i)] = rgba.toGray

proc load*(qri: var QRimage, fpath: string): bool=
  let img = readImage(fpath)
  qri.ch = 4 # always 4 on pixie Image
  qri.w = img.width
  qri.h = img.height
  qri.px = newSeq[uint8](qri.ch * qri.w * qri.h)
  for i in 0..<img.data.len:
    qri.px[qri.ch * i].asBE32ptr[] = img.data[i].asBE32ptr[]
  result = true

proc save*(qri: QRimage, fpath: string): bool=
  # expects qri is a 4ch RGBA
  assert qri.ch == 4
  let img = newImage(qri.w, qri.h)
  for i in 0..<img.data.len:
    img.data[i].asBE32ptr[] = qri.px[qri.ch * i].asBE32ptr[]
  img.writeFile(fpath)
  result = true

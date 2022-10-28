# tgenerator.nim

import unittest
import nimQR
import pixie
import strformat, strutils

proc dumps*(qr: ImagePlane): string=
  var r = @[""]
  for y in 0..<qr.h:
    for x in 0..<qr.w:
      r.add(if qr.px[y * qr.w + x] != 0x00: "  " else: "■") # reverse B/W
    r.add("\n")
  result = r.join

proc outQR(msg: string, expectsz: int, fn: string, border: int, scale: int,
  fgc: ColorRGBA, bgc: ColorRGBA=rgba(0, 0, 0, 0)): bool=
  let qr = msg.gen
  check(qr.w == expectsz and qr.h == expectsz)
  qr.deco(border, scale, fgc, bgc).writeFile(fn)
  # echo fmt"QR size: {qr.w:06d}, {qr.h:06d}"
  # echo qr.dumps
  result = true

proc run() =
  suite "test QR generator":
    let
      bgc = rgba(0x33, 0xcc, 0x99, 0xff)
      fnShort = "res/_test_zbar_nim_short_.png"
      fnLong = "res/_test_zbar_nim_long_.png"
      fnBGC = "res/_test_zbar_nim_bgc_.png"

    test fmt"generate QR short: {fnShort}":
      const s = "testQR"
      check(outQR(s, 21, fnShort, 2, 16, rgba(0xcc, 0x99, 0x33, 0xff)))

    test fmt"generate QR long: {fnLong}":
      var s = "big".repeat(106) # seq[string] will be auto joined
      # echo $s.typeof # string
      check(s.len == 318)
      s = fmt"QR{s}QR"
      check(outQR(s, 69, fnLong, 1, 5, rgba(0x66, 0x33, 0xcc, 0xff)))

    test fmt"generate QR BGC: {fnBGC}":
      const s = "black"
      check(outQR(s, 21, fnBGC, 2, 16, rgba(0x00, 0x00, 0x00, 0xff), bgc))

run()

# tscanner.nim

import unittest
import nimQR
import pixie
import stdnim
import strformat, strutils

proc toStr(locs: seq[seq[QRpoint]]): string=
  var r = @[fmt"locs: {locs.len}"]
  for loc in locs:
    r.add(fmt" loc: {loc.len}")
    for pt in loc:
      r.add($pt)
  result = r.join("\n")

proc toSeq(loc: StdVector[QRpoint]): seq[QRpoint]=
  for it in loc.begin..<loc.end:
    result.add(it[])

proc inQR(fpath: string, expectmsg: string): bool=
  let qrd = fpath.scan
  var
    typs = newSeq[string](qrd.size)
    msgs = newSeq[string](qrd.size)
    locs = newSeq[seq[QRpoint]](qrd.size)
    k = 0
  for it in qrd.begin..<qrd.end:
    let detect: QRdetect = it[] # assign to accessing type
    typs[k] = $detect.typ.cStr
    check(typs[k] == "QR-Code")
    msgs[k] = $detect.msg.cStr
    locs[k] = detect.loc.toSeq
    k += 1
  if expectmsg.len > 0: check(msgs[0] == expectmsg)
  else: echo fmt"test {fpath}:{'\n'}{typs}{'\n'}{msgs}{'\n'}{locs.toStr}"
  result = true

proc outImg(fpath: string, opath: string, fontfile: string): bool=
  let
    img = fpath.readImage
    ctx = newContext(img)
    qrd = img.toGray.scan
  for it in qrd.begin..<qrd.end:
    let
      detect: QRdetect = it[] # assign to accessing type
      typ = $detect.typ.cStr
      msg = $detect.msg.cStr
      loc = detect.loc.toSeq
    check(typ == "QR-Code")
    var
      mx = 999999'f32
      my = 0'f32
      p = newPath()
    for i, pt in loc:
      let
        x = pt.x.float32
        y = pt.y.float32
      if i == 0: p.moveTo(x, y)
      else: p.lineTo(x, y)
      if x < mx: mx = x # as min x
      if y > my: my = y # as max y
    p.closePath
    img.strokePath(p, rgba(240, 32, 32, 255))
    ctx.font = fontfile
    ctx.fontSize = 12
    ctx.fillStyle = rgba(32, 32, 240, 255)
    ctx.fillText(msg, mx - 8, my + 10) # left bottom
  img.writeFile(opath)
  result = true

proc run() =
  suite "test QR scanner":
    let
      fnShort = "res/_test_zbar_nim_short_.png"
      fnLong = "res/_test_zbar_nim_long_.png"
      fnBGC = "res/_test_zbar_nim_bgc_.png"
      fnMul = "res/_test_zbar_nim_mul_.png"
      fnOut = "res/_test_zbar_nim_out_.png"
      # fontfile = "mikaP.ttf"
      fontfile = "c:/windows/fonts/arial.ttf"

    test fmt"scan QR short: {fnShort}":
      const s = "testQR"
      check(inQR(fnShort, s))

    test fmt"scan QR long: {fnLong}":
      var s = "big".repeat(106) # seq[string] will be auto joined
      # echo $s.typeof # string
      check(s.len == 318)
      s = fmt"QR{s}QR"
      check(inQR(fnLong, s))

    test fmt"scan QR BGC: {fnBGC}":
      const s = "black"
      check(inQR(fnBGC, s))

    test fmt"scan QR Mul: {fnMul} -> {fnOut}":
      const s = ""
      check(inQR(fnMul, s))
      check(outImg(fnMul, fnOut, fontfile))

run()

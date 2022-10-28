mode = ScriptMode.Verbose

# Package

packageName   = "nimQR"
version       = "0.0.1"
author        = "nomissbowling"
description   = "Nim QR code generator scanner lib zbar"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "benchmarks", "htmldocs"]
skipFiles     = @["_config.yml"]
backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0",
  "pixie >= 5.0.1",
  "stdnim >= 0.0.1"

# Scripts

proc configForTests() =
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --path: "."
  --run

proc configForBenchmarks() =
  --define: release
  --path: "."
  --run

task test, "run tests":
  configForTests()
  setCommand "c", "tests/tQR.nim"

task testQR, "run QR tests":
  configForTests()
  setCommand "c", "tests/tQR.nim"

task benchmark, "run benchmarks":
  configForBenchmarks()
  setCommand "c", "benchmarks/bQR.nim"

task docs, "generate documentation":
  exec("mkdir -p htmldocs/nimQR")
  --project
  --git.url: "https://github.com/nomissbowling/nimQR"
  --git.commit: master
  setCommand "doc", "nimQR.nim"

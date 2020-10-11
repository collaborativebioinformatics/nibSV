# Package

version       = "0.1.0"
author        = "Zev Kronenberg"
author        = "Christopher Dunn"
author        = "(Add your name here)"
description   = "Structural Variant nibbles"
license       = "BSD-3-Clause"
srcDir        = "src"
installDirs   = @["nibsvpkg"]
bin           = @["nibsv"]


# Dependencies

requires "nim >= 1.2.0", "hts", "kmer", "bitvector >= 0.4.10", "cligen"

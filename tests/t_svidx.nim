import unittest
import nibpkg/svidx

suite "svidx suite":
 test "that sv insertion works":

  var idx: svIdx
  new(idx)
  idx.insert("ATCGGCTACTATT", 11, 2)

  for kmer, t in idx:
   check t.svs == @[2'u32]

 test "that no ref insertion occurs unless kmer matches":

  var idx: svIdx
  new(idx)
  idx.insert("ATCGGCTACTATT", 11, -1)
  check idx.len == 0

  idx.insert("ATCGGCTACTATT", 11, 2)
  idx.insert("ATCGGCTACTATT", 11, -1)

  for kmer, t in idx:
   check t.svs == @[2'u32]
   check t.refCount == 1'u32


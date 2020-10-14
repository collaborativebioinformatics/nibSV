# vim: sw=1 ts=1 sts=1 tw=0 et:
import unittest
import nibpkg/svidx
import tables

suite "SvIndex suite":
 test "that sv insertion works":

  var idx: SvIndex
  idx.insert("ATCGGCTACTATT", 11, 2)

  for kmer, t in idx.counts:
   check t.svs == @[2'u32]

 test "that no ref insertion occurs unless kmer matches":

  var idx: SvIndex
  idx.insert("ATCGGCTACTATT", 11, -1)
  check idx.len == 0

  idx.insert("ATCGGCTACTATT", 11, 2)
  idx.insert("ATCGGCTACTATT", 11, -1)

  for kmer, t in idx.counts:
   check t.svs == @[2'u32]
   check t.refCount == 1'u32

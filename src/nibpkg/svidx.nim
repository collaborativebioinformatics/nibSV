import tables
export tables
import msgpack4nim, streams
import ./kmers

type svIdx* = TableRef[uint64, tuple[refCount: uint32, altCount: uint32, svs: seq[uint32]]]

proc dumpIdxToFile*(idx: svIdx, fn: string) =
    let strm = openFileStream(fn, fmWrite)
    strm.pack(idx)
    strm.close()

proc loadIdxFromFile*(fn: string): svIdx =
    new(result) # = newTable[uint64, tuple[refCount:uint32, altCount:uint32, svs:seq[uint32]]]()
    let strm = openFileStream(fn, fmRead)
    strm.unpack(result)
    strm.close()

proc insert*(s: var svIdx, sequence: string, k: int, sv_idx: int = -1) =
    ## when inserting reference sequences leave sv_idx as -1
    var l = Dna(sequence).dna_to_kmers(k)

    # inserting alternates
    if sv_idx >= 0:
        for kmer in l.seeds:
            var kc = s.getOrDefault(kmer.kmer)
            kc.altCount.inc
            kc.svs.add(sv_idx.uint32)
            s[kmer.kmer] = kc

        return

    # inserting reference counts iff the kmer was already found as alternate.
    for kmer in l.seeds:
        # note: sometimes doing double lookup.
        if kmer.kmer notin s: continue
        s[kmer.kmer].refCount.inc

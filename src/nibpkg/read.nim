import ./kmers
import ./mainLookup
import tables
export tables
import ./svidx

type Read* = object
    ## key of svid, count of supporting kmers
    compatible_SVs*: CountTable[uint32]

proc process_read*(s: string, idx: svIdx, k: int = 25, spacedSeeds: bool = false, space: int = 50): Read =
    # find SVs with kmers intersecting with those from this read.
    var x: Read
    var kmers = Dna(s).dna_to_kmers(k)
    if(spacedSeeds):
        kmers = spacing_kmer(kmers, space)
    for kmer in kmers.seeds:
        var matching_svs = idx.lookupKmer(kmer)
        for c in matching_svs:
            x.compatible_SVs.inc(c)
    return x

proc filter_read_matches*(read: var Read, min_matches: int = 2, winner_takes_all: bool = false) =
    ## track sv with most kmer matches
    var removables: seq[uint32]
    var max_sv = 0
    var max_kcnt = 0'u32
    for sv, kcnt in read.compatible_SVs:
        if kcnt < min_matches:
            removables.add(sv)
        if kcnt > max_kcnt.int:
            max_sv = sv.int
            max_kcnt = kcnt.uint32
    for r in removables:
        read.compatible_SVs.del(r)

    if winner_takes_all:
        clear(read.compatible_SVs)
        read.compatible_SVs.inc(max_sv.uint32, max_kcnt.int)

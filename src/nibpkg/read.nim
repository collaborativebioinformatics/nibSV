import ./kmers
import ./mainLookup
import tables

type 
    Read* = object
        compatible_SVs* : CountTable[uint32]

proc process_read(s : string, idx : svIdx, k:int=25): Read =
    var x : Read
    var l = Dna(s).dna_to_kmers(k)
    for kmer in l.seeds:
        var compats = idx.lookupKmer(kmer)
        for c in compats:
            x.mget(compatible_SVs[c]).inc

    return x


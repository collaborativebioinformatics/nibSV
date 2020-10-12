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
            x.mgetOrPut(compatible_SVs[c], 0).inc

    return x

proc filter_read_matches(read : Read, min_matches:int=2, winner_takes_all:bool=false) =
    
    var removables : seq[uint32]
    var max_key:uint32=0
    var max_val:uint32=0
    for key, val in read.compatible_SVs:
        if val > min_matches:
            removables.add(key)
        if val > max_val:
            max_key = key
            max_val = val
    for r in removables:
        compatible_SVs.del(r)
    
    if winner_takes_all:
        clear(compatible_SVs)
        compatible_SVs[max_key] = val

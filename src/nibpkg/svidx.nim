# vim: sw=4 ts=4 sts=4 tw=0 et:
import tables
#export tables
from strutils import nil
import msgpack4nim, streams, json
import ./kmers

type
    SvValue* = tuple[refCount: uint32, altCount: uint32, svs: seq[uint32]]

    ## A map from KMER ID -> (number of time kmer appears in a ref seq, number of times kmer appears in an alt seq, list(SVs) that kmer is contained in )
    svIdx* = TableRef[uint64, SvValue]
    # TODO: Use object instead of tuple, for easier serialization.

proc dumpIdxToFile*(idx: svIdx, fn: string) =
    let strm = openFileStream(fn, fmWrite)
    strm.pack(idx)
    strm.close()

proc loadIdxFromFile*(fn: string): svIdx =
    new(result) # = newTable[uint64, tuple[refCount:uint32, altCount:uint32, svs:seq[uint32]]]()
    let strm = openFileStream(fn, fmRead)
    strm.unpack(result)
    strm.close()

proc `%`(idx: svIdx): JsonNode =
    type
        Value = object
            refCount: uint32
            altCount: uint32
            svs: seq[uint32]
        Index = Table[string, Value]
    var t: Index
    result = %t
    for k,v in idx.pairs():
        let val = Value(refCount:v.refCount, altCount:v.altCount, svs:v.svs)
        result[$k] = %val

proc dumpIdxToJson*(idx: svIdx): string =
    return json.pretty(%idx)

proc loadIdxFromJson*(js: string): svIdx =
    ## This painful method might become simple if svIdx values
    ## switched from tuple to object.
    new(result)
    let j = json.parseJson(js)
    for key,val in j:
        var svs: seq[uint32]
        for sv in val["svs"].getElems():
            svs.add(sv.getInt().uint32)
        let v:SvValue = (
            refCount: val["refCount"].getInt().uint32,
            altCount: val["altCount"].getInt().uint32,
            svs: svs)
        let k:uint64 = strutils.parseBiggestUint(key)
        result[k] = v

proc run*() =
    var idx: svIdx
    new(idx)
    var v: SvValue = (0'u32, 0'u32, @[0'u32])
    idx[42] = v
    echo dumpIdxToJson(idx)

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

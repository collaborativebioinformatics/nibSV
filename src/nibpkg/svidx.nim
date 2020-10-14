# vim: sw=4 ts=4 sts=4 tw=0 et:
import tables
#export tables
from strutils import nil
import msgpack4nim, streams, json
import ./kmers

type
    #SvValue* = tuple[refCount: uint32, altCount: uint32, svs: seq[uint32]]
    SvValue* = object
        refCount*: uint32
        altCount*: uint32
        svs*: seq[uint32]

    ## A map from KMER ID -> (number of time kmer appears in a ref seq, number of times kmer appears in an alt seq, list(SVs) that kmer is contained in )
    svIdx* = TableRef[uint64, SvValue]
    SvIndex* = object
        counts*: Table[uint64, SvValue]
        kmerSize*: uint8

proc dumpIdxToFile*(idx: svIdx, fn: string) =
    let strm = openFileStream(fn, fmWrite)
    strm.pack(idx)
    strm.close()

proc loadIdxFromFile*(fn: string): svIdx =
    new(result) # = newTable[uint64, tuple[refCount:uint32, altCount:uint32, svs:seq[uint32]]]()
    let strm = openFileStream(fn, fmRead)
    strm.unpack(result)
    strm.close()

proc dumpIndexToFile*(idx: SvIndex, fn: string) =
    let strm = openFileStream(fn, fmWrite)
    strm.pack(idx)
    strm.close()

proc loadIndexFromFile*(fn: string): SvIndex =
    let strm = openFileStream(fn, fmRead)
    strm.unpack(result)
    strm.close()

proc `%`(idx: svIdx): JsonNode =
    var t: svIdx
    result = json.newJObject()
    for k,v in idx.pairs():
        let val = SvValue(refCount:v.refCount, altCount:v.altCount, svs:v.svs)
        result[$k] = %val

proc dumpIdxToJson*(idx: svIdx): string =
    return json.pretty(%idx)

proc loadIdxFromJson*(js: string): svIdx =
    ## This painful method might become simple if svIdx values
    ## switched from tuple to object.
    new(result)
    let j = json.parseJson(js)
    for key,val in j:
        let k:uint64 = strutils.parseBiggestUint(key)
        let v = json.to(val, SvValue)
        result[k] = v

proc `%`(idx: SvIndex): JsonNode =
    result = json.newJObject()
    result["kmerSize"] = %idx.kmerSize
    result["counts"] = json.newJObject()
    for k,v in idx.counts.pairs():
        let val = SvValue(refCount:v.refCount, altCount:v.altCount, svs:v.svs)
        result["counts"][$k] = %val

proc dumpIndexToJson*(idx: SvIndex): string =
    return json.pretty(%idx)

proc loadIndexFromJson*(js: string): SvIndex =
    ## This painful method might become simple if SvIndex values
    ## switched from tuple to object.
    let j = json.parseJson(js)
    result.kmerSize = j["kmerSize"].getInt().uint8
    for key,val in j["counts"]:
        let k:uint64 = strutils.parseBiggestUint(key)
        let v = json.to(val, SvValue)
        result.counts[k] = v

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

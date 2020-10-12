type
    CountingArray*[T] = ref object
        values: seq(int32)
        size: int32

proc create[T](counter: type CountingArray, size: int32) =
    counter.values = newSeq(T)[size]
    counter.size = size

proc add[T](counter: type CountingArray, val: T) =
    counter.values [int64(val) mod int64(counter.size)] =
        counter.values [int64(val) mod int64(counter.size)] + 1

proc get[T](counter: type CountingArray, val: T): int32 =
    return counter.values[int64(val) mod int64(counter.size)]

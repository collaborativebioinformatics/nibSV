from nibpkg/compose import nil
from nibpkg/refmers import nil
from nibpkg/mainLookup import nil

when isMainModule:
  import cligen
  dispatchMulti(
        [compose.compose_variants, cmdName="compose"],
        [refmers.countRefKmers, cmdName="count"],
        [mainLookup.buildSVIdx, cmdName="lookup"],
  )

from nibpkg/compose import nil
from nibpkg/refmers import nil

when isMainModule:
  import cligen
  dispatchMulti(
        [compose.compose_variants, cmdName="compose"],
        [refmers.countRefKmers, cmdName="count"],
  )

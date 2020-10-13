from nibpkg/compose import nil
from nibpkg/refmers import nil
from nibpkg/mainLookup import nil
from nibpkg/classify import nil
from nibpkg/captain import nil

when isMainModule:
  import cligen
  dispatchMulti(
        [compose.compose_variants, cmdName = "compose"],
        [refmers.showCounts, cmdName = "count"],
        [mainLookup.buildSVIdx, cmdName = "lookup"],
        [classify.main_classify, cmdName = "classify"],
        [captain.main_runner, cmdName = "main"],
  )

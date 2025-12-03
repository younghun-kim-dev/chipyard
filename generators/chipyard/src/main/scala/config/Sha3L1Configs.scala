package chipyard

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import chipyard.config._

class Sha3RocketBigL1Config extends Config(
  new sha3.WithSha3Accel ++
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  new freechips.rocketchip.subsystem.WithL1DCacheSets(64) ++   // ✅ 64
  new freechips.rocketchip.subsystem.WithL1DCacheWays(8)  ++   // ✅ 8 → 총 32KiB
  new chipyard.config.AbstractConfig
)


package chipyard

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.rocket._     // TLBConfig
import chipyard.config._

class WithSha3TLBWays(nWays: Int = 32) extends Config((site, here, up) => {
  case sha3.Sha3TLB => Some(TLBConfig(
    nSets             = 1,
    nWays             = nWays,   // 기본 4 → 32 권장
    nSectors          = 1,
    nSuperpageEntries = 1
  ))
})

// 조합 예시: L1은 그대로 두고 SHA3 TLB만 키우는 구성
class Sha3RocketTLB32Config extends Config(
  new WithSha3TLBWays(32) ++
  new sha3.WithSha3Accel ++
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  new chipyard.config.AbstractConfig
)

package chipyard

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._         // WithInclusiveCache, WithNBigCores 등
import boom.common._                            // WithNSmallBooms/WithNMediumBooms/...
import gemmini._                                // DefaultGemminiConfig

// BOOM 1코어 + L2 포함 + Gemmini (Rocket은 0개)
class YHGemminiSmallBoom11Config extends Config(
  new gemmini.DefaultGemminiConfig ++           // Gemmini RoCC 부착 (모든 타일 대상)
  new WithInclusiveCache ++                     // SiFive L2
  new WithNSmallBooms(1) ++                     // BOOM 1개
  new WithNBigCores(0) ++                       // Rocket 0개로 명시
  new chipyard.config.AbstractConfig
)

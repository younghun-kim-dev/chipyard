package chipyard

import org.chipsalliance.cde.config._

// BOOM v4 mixins
import boom.v4.common.{ WithNSmallBooms, WithNMediumBooms, WithNLargeBooms }

// Gemmini default config
import gemmini.DefaultGemminiConfig

// ⚠ 네 버전 기준: Rocket 코어 수 믹스인은 rocket 네임스페이스에 있음
import freechips.rocketchip.rocket.WithNBigCores

/** -----------------------------------------------------------
  * Gemmini + BOOM(v4) + Rocket (Heterogeneous) 구성 세트
  *  - Gemmini : DefaultGemminiConfig
  *  - BOOM    : Small / Medium / Large v4 중 택1
  *  - Rocket  : Big Rocket N코어(1 또는 2)
  *
  * 사용 예:
  *   make CONFIG=GemminiLargeBoomV4Rocket1Config -j$(nproc)
  *   make run-binary CONFIG=GemminiLargeBoomV4Rocket1Config BINARY=...
  *
  * L2(banks/용량/경로) 스윕은 별도 파생 Config에서
  *   WithInclusiveCache(capacityKB=...) / WithNBanks(...) 등을 얹어 사용 권장.
  * ----------------------------------------------------------- */

// === Small BOOM + Gemmini + Rocket ===
class GemminiSmallBoomV4Rocket1Config extends Config(
  new DefaultGemminiConfig ++
  new WithNBigCores(1) ++            // Rocket 1 (freechips.rocketchip.rocket)
  new WithNSmallBooms(1) ++          // BOOM Small 1
  new chipyard.config.AbstractConfig
)

class GemminiSmallBoomV4Rocket2Config extends Config(
  new DefaultGemminiConfig ++
  new WithNBigCores(2) ++            // Rocket 2
  new WithNSmallBooms(1) ++
  new chipyard.config.AbstractConfig
)


// === Medium BOOM + Gemmini + Rocket ===
class GemminiMediumBoomV4Rocket1Config extends Config(
  new DefaultGemminiConfig ++
  new WithNBigCores(1) ++
  new WithNMediumBooms(1) ++
  new chipyard.config.AbstractConfig
)

class GemminiMediumBoomV4Rocket2Config extends Config(
  new DefaultGemminiConfig ++
  new WithNBigCores(2) ++
  new WithNMediumBooms(1) ++
  new chipyard.config.AbstractConfig
)


// === Large BOOM + Gemmini + Rocket ===
class GemminiLargeBoomV4Rocket1Config extends Config(
  new DefaultGemminiConfig ++
  new WithNBigCores(1) ++
  new WithNLargeBooms(1) ++
  new chipyard.config.AbstractConfig
)

class GemminiLargeBoomV4Rocket2Config extends Config(
  new DefaultGemminiConfig ++
  new WithNBigCores(2) ++
  new WithNLargeBooms(1) ++
  new chipyard.config.AbstractConfig
)


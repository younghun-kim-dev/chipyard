package chipyard

import org.chipsalliance.cde.config._        // 옛날 freechips.rocketchip.config 아님!

// BOOM v4 네임스페이스
import boom.v4.common.{ WithNSmallBooms, WithNMediumBooms, WithNLargeBooms }

// Gemmini 기본 설정 믹스인
import gemmini.DefaultGemminiConfig

/** BOOM(v4) 1코어 + Gemmini 기본 설정 */
class GemminiSmallBoomV4Config extends Config(
  new DefaultGemminiConfig ++
  new WithNSmallBooms(1) ++
  new chipyard.config.AbstractConfig
)

/** BOOM(v4) Medium 1코어 + Gemmini */
class GemminiMediumBoomV4Config extends Config(
  new DefaultGemminiConfig ++
  new WithNMediumBooms(1) ++
  new chipyard.config.AbstractConfig
)

/** BOOM(v4) Large 1코어 + Gemmini */
class GemminiLargeBoomV4Config extends Config(
  new DefaultGemminiConfig ++
  new WithNLargeBooms(1) ++
  new chipyard.config.AbstractConfig
)


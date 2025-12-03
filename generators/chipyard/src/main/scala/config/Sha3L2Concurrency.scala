// generators/chipyard/src/main/scala/config/Sha3L2Concurrency.scala
package chipyard

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import chipyard.config._
import sifive.blocks.inclusivecache._

/** L2 동시성만 확실히 올림(버퍼/지연은 그대로) */
class WithInclusiveL2ConcurrencyOnly(
  sets: Int = 1024,
  ways: Int = 8,
  portFactor: Int = 8,   // ← 기본 4에서 확실히 ↑ (동시성·처리율↑)
  memCycles: Int = 40
) extends Config((site, here, up) => {
  case InclusiveCacheKey =>
    val p = up(InclusiveCacheKey)
    p.copy(
      sets       = sets,
      ways       = ways,
      portFactor = portFactor,
      memCycles  = memCycles
      // bufInner/Outer*는 건드리지 않음(기본값 유지 = 불필요한 고정 지연 X)
    )
})

/** 512 KiB 스트리밍 개선용 구성 */
class Sha3RocketL2For512KConfig extends Config(
  new sha3.WithSha3Accel ++
  new WithNBigCores(1) ++
  new WithInclusiveL2ConcurrencyOnly(
    sets = 1024, ways = 8, portFactor = 8, memCycles = 40
  ) ++
  new chipyard.config.AbstractConfig
)


package chipyard

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import chipyard.config._
import sifive.blocks.inclusivecache._  // Parameters.scala가 있는 패키지

/** Inclusive L2의 내부/외부 포트 버퍼링을 강화해 ready 경로와 역압을 완화 */
class WithInclusiveL2Buffers(
  inner: InclusiveCachePortParameters = InclusiveCachePortParameters.fullC, // 스케줄러 경로 ready 컷
  outer: InclusiveCachePortParameters = InclusiveCachePortParameters.full   // 외부 포트도 파이프/플로우
) extends Config((site, here, up) => {
  case InclusiveCacheKey =>
    val p = up(InclusiveCacheKey)
    p.copy(
      // SubsystemFragments.scala에서도 이 4개 필드를 copy로 건드린다
      bufInnerInterior = inner,
      bufOuterInterior = outer,
      bufInnerExterior = inner,
      bufOuterExterior = outer
    )
})

/** SHA3 RoCC + L2 버퍼 튠 조합 (bare sha3-rocc에서도 효과가 바로 남) */
class Sha3Rocket_L2Buf_Config extends Config(
  new sha3.WithSha3Accel ++
  new WithNBigCores(1) ++
  new WithInclusiveL2Buffers(              // 안전한 디폴트: 내부 fullC, 외부 full
    inner = InclusiveCachePortParameters.fullC,
    outer = InclusiveCachePortParameters.full
  ) ++
  new chipyard.config.AbstractConfig
)

class Sha3RocketL2TuneConfig extends Config(
  new sha3.WithSha3Accel ++
  new WithNBigCores(1) ++
  new WithInclusiveL2Buffers(
    inner = InclusiveCachePortParameters.fullC,
    outer = InclusiveCachePortParameters.full
  ) ++
  new chipyard.config.AbstractConfig
)

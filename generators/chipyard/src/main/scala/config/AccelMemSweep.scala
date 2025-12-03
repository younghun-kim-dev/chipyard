package chipyard

import org.chipsalliance.cde.config.Config  // ✅ Chipyard 1.11 올바른 경로

/** 0) 베이스라인: BOOM Large 1 + Rocket 2 + SHA3 + Inclusive L2(512KiB) + L2 bank=1 */
class BaselineOneBankL2Sha3 extends Config(
  new freechips.rocketchip.subsystem.WithNBanks(1) ++
  new sha3.WithSha3Accel ++
  new boom.common.WithNLargeBooms(1) ++
  new freechips.rocketchip.subsystem.WithNBigCores(2) ++
  new freechips.rocketchip.subsystem.WithInclusiveCache ++
  new chipyard.config.AbstractConfig
)

/** 1) L2 은행 스윕 공통 바탕 (용량/코어/가속기 고정, 채널은 기본 1) */
class BaseSha3HeteroInclL2 extends Config(
  new sha3.WithSha3Accel ++
  new boom.common.WithNLargeBooms(1) ++
  new freechips.rocketchip.subsystem.WithNBigCores(2) ++
  new freechips.rocketchip.subsystem.WithInclusiveCache ++
  new chipyard.config.AbstractConfig
)

class L2BanksOneSha3   extends Config(new freechips.rocketchip.subsystem.WithNBanks(1) ++ new BaseSha3HeteroInclL2)
class L2BanksTwoSha3   extends Config(new freechips.rocketchip.subsystem.WithNBanks(2) ++ new BaseSha3HeteroInclL2)
class L2BanksFourSha3  extends Config(new freechips.rocketchip.subsystem.WithNBanks(4) ++ new BaseSha3HeteroInclL2)
class L2BanksEightSha3 extends Config(new freechips.rocketchip.subsystem.WithNBanks(8) ++ new BaseSha3HeteroInclL2)

/** 2) 경로 비교: L2를 빼서 Broadcast 경로로 (가장 호환성 높은 방법) */
class BroadcastHubSha3 extends Config(
  new sha3.WithSha3Accel ++
  new boom.common.WithNLargeBooms(1) ++
  new freechips.rocketchip.subsystem.WithNBigCores(2) ++
  // L2 mixin을 의도적으로 생략 → 기본 Broadcast 경로 사용
  new chipyard.config.AbstractConfig
)

/** 3) SW-only 대조군 (임계점 계산용) */
class L2BanksFourSoftwareOnly extends Config(
  new boom.common.WithNLargeBooms(1) ++
  new freechips.rocketchip.subsystem.WithNBigCores(2) ++
  new freechips.rocketchip.subsystem.WithNBanks(4) ++
  new freechips.rocketchip.subsystem.WithInclusiveCache ++
  new chipyard.config.AbstractConfig
)

/** 4) 호스트 조합 변형 (선택) */
class L2BanksFourSha3RocketThree extends Config(
  new sha3.WithSha3Accel ++
  new boom.common.WithNLargeBooms(0) ++                  // BOOM 0
  new freechips.rocketchip.subsystem.WithNBigCores(3) ++ // Rocket 3
  new freechips.rocketchip.subsystem.WithNBanks(4) ++
  new freechips.rocketchip.subsystem.WithInclusiveCache ++
  new chipyard.config.AbstractConfig
)

class L2BanksFourSha3BoomTwoRocketOne extends Config(
  new sha3.WithSha3Accel ++
  new boom.common.WithNLargeBooms(2) ++                  // BOOM 2
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++ // Rocket 1
  new freechips.rocketchip.subsystem.WithNBanks(4) ++
  new freechips.rocketchip.subsystem.WithInclusiveCache ++
  new chipyard.config.AbstractConfig
)


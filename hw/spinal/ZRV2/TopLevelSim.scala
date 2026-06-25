package ZRV2

import spinal.core._
import spinal.core.sim._

object TopLevelSim extends App {
  Config.sim.compile(TopLevel()).doSim { dut =>
    // Fork a process to generate the reset and the clock on the dut
    dut.clockDomain.forkStimulus(period = 10)

    var modelState = 0
    for (idx <- 0 to 99) {
      // Drive the dut inputs with random values
      dut.io.flush.randomize()
      dut.io.stall.randomize()

      // Wait a rising edge on the clock
      dut.clockDomain.waitRisingEdge()

    }
  }
}

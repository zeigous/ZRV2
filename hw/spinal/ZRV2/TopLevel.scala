package ZRV2

import ZRV2.CoreConfig
import ZRV2.common._
import ZRV2.fetch._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps


// Hardware definition
case class TopLevel() extends Component {
  val config = CoreConfig(xlen = 32, progMemPath = "hw/programs/memTest.hex")

  val io = new Bundle {
    val stall = in Bool()
    val flush = in(Flow(Flush(config)))

    val decodeOut = out(Flow(F2ToID1(config)))
  }

  /* The pipeline */
  val fetch1 = Fetch1(config)
  val fetch2 = Fetch2(config)
  val progMem = ProgMem(config)

  /* Inter-pipeline registers */
  val f1ToF2  = RegInit(Flow(F1ToF2(config)).getZero)
  val f2ToID1 = RegInit(Flow(F2ToID1(config)).getZero)

  /* Flush and Stall hooks */
  fetch1.io.flush := io.flush
  fetch1.io.stall := io.stall

  /* Connections */
  f1ToF2.payload    := fetch1.io.outToF2.payload
  fetch2.io.f1In    := f1ToF2
  f2ToID1.payload   := fetch2.io.output.payload
  progMem.io.input  := fetch1.io.outToMem
  fetch2.io.memIn   := progMem.io.output

  when (io.flush.valid) {
    f1ToF2.valid    := False
    f2ToID1.valid   := False
  } otherwise {
    f1ToF2.valid    := fetch1.io.outToF2.valid
    f2ToID1.valid   := fetch2.io.output.valid
  }

  io.decodeOut := f2ToID1
}

object TopLevelVerilog extends App {
  Config.spinal.generateVerilog(TopLevel())
}

object TopLevelVhdl extends App {
  Config.spinal.generateVhdl(TopLevel())
}

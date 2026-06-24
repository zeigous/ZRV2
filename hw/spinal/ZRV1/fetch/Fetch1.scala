package ZRV1.fetch
import ZRV1.CoreConfig
import ZRV1.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Fetch1(config: CoreConfig) extends Component {
  val io = new Bundle {
    /* Outputs from F1 to Memory */
    val outToMem = out( F1ToProgMem(config) )

    /* Outputs from F1 to F2 */
    val outToF2 = out( Flow(F1ToF2(config)) )

    /* Flush and Stall Inputs */
    val flush = in( Flow(Flush(config)) )
    val stall = in( Bool() )
  }

  val pc = Reg(UInt(config.xlen bits)) init 0

  io.outToF2.valid  := True

  io.outToF2.payload.pc     := pc
  io.outToMem.addr          := pc

  when (!io.stall && !io.flush.valid) {
    pc := pc + 4
  }

  when(io.flush.valid) {
    pc := io.flush.payload.addr

    io.outToF2.valid  := False
  }
}

package ZRV2.fetch

import ZRV2.CoreConfig
import ZRV2.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Fetch2(config: CoreConfig) extends Component {
  val io = new Bundle {
    val memIn = in( ProgMemToF2(config) )
    val f1In = in( Flow(F1ToF2(config)) )
    val output = out( Flow(F2ToID1(config)) )
  }

  io.output.valid          := io.f1In.valid
  io.output.payload.pc     := io.f1In.payload.pc
  io.output.payload.mem    := io.memIn.mem

}

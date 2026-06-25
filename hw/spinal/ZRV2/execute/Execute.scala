package ZRV2.execute

import ZRV2.CoreConfig
import ZRV2.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Execute(config: CoreConfig) extends Component {
  val io = new Bundle {
    val input = in( Flow(RRToEX(config)) )
    val output = out( Flow(EXToMEM1(config)) )

    val flushOut = out( Flow(Flush(config)) )
  }

  io.output.valid   := io.input.valid
  io.output.payload := io.output.payload.getZero
  io.flushOut.valid := False

  
}

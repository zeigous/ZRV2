package ZRV2.execute

import ZRV2.CoreConfig
import ZRV2.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class RegRead(config: CoreConfig) extends Component {
  val io = new Bundle {
    val input = in( Flow(ID2ToRR(config)) )
    val output = out( Flow(RRToEX(config)) )

    /* output to regfile */
    val rs1 = out( UInt(5 bits) )
    val rs2 = out( UInt(5 bits) )

    /* Input from regfile */
    val rs1In = in( UInt(5 bits) )
    val rs2In = in( UInt(5 bits) )

    /* Input from forward */
    val rs1Fwd = in( Flow(UInt(5 bits)) )
    val rs2Fwd = in( Flow(UInt(5 bits)) )
  }
  
  io.output.valid   := io.input.valid
  io.output.payload := io.output.payload.getZero

  /* Zero control signals if not valid */
  when (io.input.valid) {
    io.output.payload.controlSignals := io.input.payload.controlSignals
  }

  /* Just pass along most stuff */
  io.output.payload.pc          := io.input.payload.pc
  io.output.payload.nxtPc       := io.input.payload.nxtPc
  io.output.payload.func        := io.input.payload.func
  io.output.payload.branchFunc  := io.input.payload.branchFunc
  io.output.payload.memFunc     := io.input.payload.memFunc
  io.output.payload.imm         := io.input.payload.imm
  io.output.payload.rd          := io.input.payload.rd

  /* output to regfile */
  io.rs1 := (io.input.payload.rs1.valid) ? io.input.payload.rs1.reg | 0
  io.rs2 := (io.input.payload.rs2.valid) ? io.input.payload.rs2.reg | 0

  /* output to next stage */
  io.output.payload.rs1.value   := (io.rs1Fwd.valid) ? io.rs1Fwd.payload | io.rs1In
  io.output.payload.rs2.value   := (io.rs2Fwd.valid) ? io.rs2Fwd.payload | io.rs2In
}

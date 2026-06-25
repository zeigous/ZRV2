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

  /* Constant pass along */
  io.output.payload.nxtPc := io.input.nxtPc
  io.output.payload.controlSignals := io.input.payload.controlSignals
  io.output.payload.memFunc := io.input.payload.memFunc
  io.output.payload.rs2 := io.input.payload.rs2
  io.output.payload.rd  := io.input.payload.rd

  /* ALU */
  val aluOut = UInt(config.xlen bits)
  val input1 = (io.input.payload.controlSignals.aluASel === AluASel.rs1) ? io.input.payload.rs1.value | io.input.payload.pc
  val input2 = (io.input.payload.controlSignals.aluBSel === AluBSel.rs2) ? io.input.payload.rs2.value | io.input.payload.imm.asUInt

  switch(io.input.payload.func) {
    is(Func.add) { aluOut := (input1 + input2) }
    is(Func.sub) { aluOut := (input1 - input2) }
    is(Func.xor) { aluOut := (input1 ^ input2) }
    is(Func.or)  { aluOut := (input1 | input2) }
    is(Func.and) { aluOut := (input1 & input2) }
    is(Func.sll) { aluOut := (input1 << input2).resize(config.xlen bits) }
    is(Func.srl) { aluOut := (input1 |>> input2) }
    is(Func.sra) { aluOut := (input1 >> input2)  }
    is(Func.slt) { aluOut := (input1.asSInt < input2.asSInt) ? U(1) | U(0) }
    is(Func.sltu){ aluOut := (input1 < input2) ? U(1) | U(0)}

    default {aluOut := (input1 + input2)}
  }

  io.output.payload.aluOut := aluOut

  /* Branch */
  val doBranch = Bool()
  switch(io.input.payload.branchFunc) {
    is(BranchFunc.equal)                { doBranch := (io.input.payload.rs1.value === io.input.payload.rs2.value) }
    is(BranchFunc.less)                 { doBranch := (io.input.payload.rs1.value.asSInt < io.input.payload.rs2.value.asSInt) }
    is(BranchFunc.greaterEqual)         { doBranch := (io.input.payload.rs1.value.asSInt >= io.input.payload.rs2.value.asSInt) }
    is(BranchFunc.lessUnsigned)         { doBranch := (io.input.payload.rs1.value < io.input.payload.rs2.value) }
    is(BranchFunc.greaterEqualUnsigned) { doBranch := (io.input.payload.rs1.value >= io.input.payload.rs2.value) }

    default {doBranch := (io.input.payload.rs1.value === io.input.payload.rs2.value)}
  }

  /* Flush */
  io.flushOut.payload.addr := aluOut

  when ((doBranch && io.input.payload.controlSignals.branch) || io.input.payload.controlSignals.jump) {
    io.flushOut.valid := True
  }
}

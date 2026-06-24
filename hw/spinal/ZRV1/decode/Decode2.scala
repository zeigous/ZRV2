package ZRV1.decode

import ZRV1.CoreConfig
import ZRV1.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Decode2(config: CoreConfig) extends Component {
  val io = new Bundle {
    val input = in( Flow(ID1ToID2(config)) )
    val output = out( Flow(ID2ToRR(config)) )
  }
  io.output.valid := io.input.valid

  /* Check if Reg is 0 */
  io.output.payload.rs1.valid := io.input.payload.rs1.valid &&  (io.input.payload.rs1.reg === 0)
  io.output.payload.rs2.valid := io.input.payload.rs2.valid &&  (io.input.payload.rs2.reg === 0)
  io.output.payload.rd.valid  := io.input.payload.rd.valid &&   (io.input.payload.rd.reg === 0)

  /* constant stuff */

  io.output.payload.pc    := io.input.payload.pc
  io.output.payload.nxtPc := io.input.payload.pc + 4
  io.output.payload.rs1   := io.input.payload.rs1
  io.output.payload.rs2   := io.input.payload.rs2
  io.output.payload.rd    := io.input.payload.rd

  /* Correct the imm for srai */

  /* Generate Control Signals */
  val inst = io.input.payload.inst
  io.output.payload := io.output.payload.getZero

  /* Opcode Decode Rom */
  val decoderTable = Seq(
    //                    ( aluA,        aluB,        aluMod,          jump,  branch, jmpSel,       memMode,      regWe, regIn )
    B"01100--" -> makeCtrl(AluASel.rs1, AluBSel.rs2, AluModSel.funct,  False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu),   // R-Type
    B"00100--" -> makeCtrl(AluASel.rs1, AluBSel.imm, AluModSel.funct,  False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu),   // I-Type ALU
    B"00000--" -> makeCtrl(AluASel.rs1, AluBSel.imm, AluModSel.add,    False, False,  JmpSel.alu,  MemMode.read,  True,  RegIn.mem),   // Loads
    B"01000--" -> makeCtrl(AluASel.rs1, AluBSel.imm, AluModSel.add,    False, False,  JmpSel.alu,  MemMode.write, False, RegIn.alu),   // Stores
    B"11000--" -> makeCtrl(AluASel.rs1, AluBSel.rs2, AluModSel.funct,  False, True,   JmpSel.alu,  MemMode.none,  False, RegIn.alu),   // Branches
    B"01101--" -> makeCtrl(AluASel.pc,  AluBSel.imm, AluModSel.add,    False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu),   // LUI
    B"00101--" -> makeCtrl(AluASel.pc,  AluBSel.imm, AluModSel.add,    False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu),   // AUIPC
    B"11011--" -> makeCtrl(AluASel.pc,  AluBSel.imm, AluModSel.add,    True,  False,  JmpSel.alu,  MemMode.none,  True,  RegIn.nxtPc)  // JAL
  )

  /* Use the Rom */
  when (io.input.valid) {
    io.output.payload.controlSignals := inst(6 downto 0).muxListDc(decoderTable)
  }

  /* Opcode Decode Rom */
  def makeCtrl(a: AluASel.E, b: AluBSel.E, mod: AluModSel.E, j: Bool, br: Bool, js: JmpSel.E, mm: MemMode.E, we: Bool, ri: RegIn.E): ControlSignals = {
    val c = ControlSignals()
    c.aluASel := a; c.aluBSel := b; c.aluModSel := mod
    c.jump := j; c.branch := br; c.jmpSel := js
    c.memMode := mm; c.regWe := we; c.regIn := ri
    c
  }
}
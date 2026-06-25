package ZRV2.decode

import ZRV2.CoreConfig
import ZRV2.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Decode2(config: CoreConfig) extends Component {
  val io = new Bundle {
    val input   = in( Flow(ID1ToID2(config)) )
    val output  = out( Flow(ID2ToRR(config)) )
  }
  io.output.payload := io.output.payload.getZero
  io.output.valid   := io.input.valid

  /* Check if Reg is 0 */
  io.output.payload.rs1.valid := io.input.payload.rs1.valid &&  (io.input.payload.rs1.reg === 0)
  io.output.payload.rs2.valid := io.input.payload.rs2.valid &&  (io.input.payload.rs2.reg === 0)
  io.output.payload.rd.valid  := io.input.payload.rd.valid  &&  (io.input.payload.rd.reg === 0)

  /* constant stuff */
  io.output.payload.pc    := io.input.payload.pc
  io.output.payload.nxtPc := io.input.payload.pc + 4
  io.output.payload.rs1   := io.input.payload.rs1
  io.output.payload.rs2   := io.input.payload.rs2
  io.output.payload.rd    := io.input.payload.rd

  /* Generate Control Signals */
  val inst = io.input.payload.inst

  /* Correct the imm for srai */
  when (inst(6 downto 2) === B"00100" && inst(14 downto 12) === B"101" && inst(30) === True) {
    io.input.payload.imm := io.input.payload.imm & B"000000000000000000000000000011111"
  }


  /* Opcode Decode Rom */
  switch (inst(6 downto 2)) {
    //                                                         ( aluA,        aluB,      jump,  branch,   jmpSel,       memMode,    regWe,   regIn )
    is(B"01100") { io.output.payload.controlSignals := makeCtrl(AluASel.rs1, AluBSel.rs2, False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu)   }  // R-Type
    is(B"00100") { io.output.payload.controlSignals := makeCtrl(AluASel.rs1, AluBSel.imm, False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu)   }  // I-Type ALU
    is(B"00000") { io.output.payload.controlSignals := makeCtrl(AluASel.rs1, AluBSel.imm, False, False,  JmpSel.alu,  MemMode.read,  True,  RegIn.mem)   }  // Loads
    is(B"01000") { io.output.payload.controlSignals := makeCtrl(AluASel.rs1, AluBSel.imm, False, False,  JmpSel.alu,  MemMode.write, False, RegIn.alu)   }  // Stores
    is(B"11000") { io.output.payload.controlSignals := makeCtrl(AluASel.rs1, AluBSel.rs2, False, True,   JmpSel.alu,  MemMode.none,  False, RegIn.alu)   }  // Branches
    is(B"01101") { io.output.payload.controlSignals := makeCtrl(AluASel.pc,  AluBSel.imm, False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu)   }  // LUI
    is(B"00101") { io.output.payload.controlSignals := makeCtrl(AluASel.pc,  AluBSel.imm, False, False,  JmpSel.alu,  MemMode.none,  True,  RegIn.alu)   }  // AUIPC
    is(B"11011") { io.output.payload.controlSignals := makeCtrl(AluASel.pc,  AluBSel.imm, True,  False,  JmpSel.alu,  MemMode.none,  True,  RegIn.nxtPc) }  // JAL
    is(B"11011") { io.output.payload.controlSignals := makeCtrl(AluASel.rs1, AluBSel.imm, True,  False,  JmpSel.alu,  MemMode.none,  True,  RegIn.nxtPc) }  // JALR
  }

  /* Func3 Decode Rom */
  switch (inst(30) ## inst(14 downto 12) ## inst(6 downto 2)) {
    /* R-Type / I-Type */
    is(B"0_000_01100", B"0_000_00100")  { io.output.payload.func := Func.add }
    is(B"1_000_01100")                  { io.output.payload.func := Func.sub }
    is(B"-_100_01100", B"-_100_00100")  { io.output.payload.func := Func.xor }
    is(B"-_110_01100", B"-_110_00100")  { io.output.payload.func := Func.or  }
    is(B"-_111_01100", B"-_111_00100")  { io.output.payload.func := Func.and }
    is(B"-_001_01100", B"-_001_00100")  { io.output.payload.func := Func.sll }
    is(B"0_101_01100", B"0_101_00100")  { io.output.payload.func := Func.srl }
    is(B"1_101_01100", B"1_101_00100")  { io.output.payload.func := Func.sra }
    is(B"-_010_01100", B"-_010_00100")  { io.output.payload.func := Func.slt }
    is(B"-_011_01100", B"-_011_00100")  { io.output.payload.func := Func.sltu}

    /* Load / Store */
    is(B"-_---_00000", B"-_---_01000")  { io.output.payload.memFunc := inst(14 downto 12).as(MemFunc())}

    /* Branch */
    is(B"-_---_11000")                  { io.output.payload.memFunc := inst(14 downto 12).as(MemFunc())}
  }

  /* Opcode Decode Rom */
  def makeCtrl(a: AluASel.E, b: AluBSel.E, j: Bool, br: Bool, js: JmpSel.E, mm: MemMode.E, we: Bool, ri: RegIn.E): ControlSignals = {
    val c = ControlSignals()
    c.aluASel := a; c.aluBSel := b; 
    c.jump := j; c.branch := br; c.jmpSel := js
    c.memMode := mm; c.regWe := we; c.regIn := ri
    c
  }
}
package ZRV2.decode

import ZRV2.CoreConfig
import ZRV2.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Decode1(config: CoreConfig) extends Component{
  val io = new Bundle {
    val input = in( Flow(F2ToID1(config)) )
    val output = out( Flow(ID1ToID2(config)) )
  }
  io.output.valid := io.input.valid

  val inst = io.input.payload.mem

  /* Do Imm extension */
  val opcode5 = io.input.payload.mem(6 downto 2)
  switch(opcode5) {
    is (B"00100")                     { io.output.payload.imm := inst(31 downto 12) ## B"000000000000"} /* U-Type */
    is (B"00100", B"00000", B"11001") { io.output.payload.imm := inst(31 downto 20).asSInt.resize(32 bits).asBits } /* I-Type */
    is (B"01000")                     { io.output.payload.imm := (inst(31 downto 25) ## inst(11 downto 7)).asSInt.resize(32 bits).asBits } /* S-Type */
    is (B"11000")                     { io.output.payload.imm := (inst(31) ## inst(7) ## inst(30 downto 25) ## inst(11 downto 8) ## B"0").asSInt.resize(32 bits).asBits } /* B-Type */
    is (B"11011")                     { io.output.payload.imm := (inst(31) ## inst(19 downto 12) ## inst(20) ## inst(30 downto 21) ## B"0").asSInt.resize(32 bits).asBits } /* J-Type */
    default { io.output.imm := 0 }
  }

  /* Register Extraction */
  io.output.payload.rs1.reg := inst(19 downto 15).asUInt
  io.output.payload.rs2.reg := inst(24 downto 20).asUInt
  io.output.payload.rd.reg  := inst(11 downto 7).asUInt

  io.output.payload.rs1.valid := False
  io.output.payload.rs2.valid := False
  io.output.payload.rd.valid  := False

  switch(opcode5) {
    is (B"00100", B"11011")           { /* J Type and U Type */
      io.output.payload.rd.valid  := True
    }
    is (B"00100", B"00000", B"11001") { /* I-Type */
      io.output.payload.rs1.valid := True
      io.output.payload.rd.valid  := True
    }
    is (B"01000", B"11000")           { /* B Type and S Type */
      io.output.payload.rs1.valid := True
      io.output.payload.rs2.valid := True
    }
    is (B"01100")                     { /* R Type */
      io.output.payload.rs1.valid := True
      io.output.payload.rs2.valid := True
      io.output.payload.rd.valid  := True
    }
    default {/* Do nothing */}
  }
}

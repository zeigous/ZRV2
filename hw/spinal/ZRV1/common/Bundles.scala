package ZRV1.common

import ZRV1.CoreConfig
import spinal.core._

import scala.language.postfixOps

case class F1ToProgMem(config: CoreConfig) extends Bundle {
  val addr = UInt(config.xlen bits)
}

case class ProgMemToF2(config: CoreConfig) extends Bundle {
  val mem = Bits(config.xlen bits)
}

case class F1ToF2(config: CoreConfig) extends Bundle {
  val pc = UInt(config.xlen bits)
}

case class Flush(config: CoreConfig) extends Bundle {
  val addr = UInt(config.xlen bits)
}


case class F2ToID1(config: CoreConfig) extends Bundle {
  val pc = UInt(config.xlen bits)
  val mem = Bits(config.xlen bits)
}

case class ID1ToID2(config: CoreConfig) extends Bundle {
  val pc    = UInt(config.xlen bits)
  val inst  = Bits(config.xlen bits)
  val imm   = Bits(config.xlen bits)
  val rs1   = RegIdentifier(config)
  val rs2   = RegIdentifier(config)
  val rd    = RegIdentifier(config)
}

case class ID2ToRR(config: CoreConfig) extends Bundle {
  val pc              = UInt(config.xlen bits)
  val nxtPc           = UInt(config.xlen bits)
  val controlSignals  = ControlSignals()
  val func            = Func()
  val imm             = Bits(config.xlen bits)
  val rs1             = RegIdentifier(config)
  val rs2             = RegIdentifier(config)
  val rd              = RegIdentifier(config)
}

/* Control Signals */
case class ControlSignals() extends Bundle {
  val aluASel   = AluASel()
  val aluBSel   = AluBSel()
  val aluModSel = AluModSel()
  val jump      = Bool()
  val branch    = Bool()
  val jmpSel    = JmpSel()
  val memMode   = MemMode()
  val regWe     = Bool()
  val regIn     = RegIn()
}

object AluASel    extends SpinalEnum(defaultEncoding=native) { val rs1, pc = newElement() }
object AluBSel    extends SpinalEnum(defaultEncoding=native) { val rs2, imm = newElement() }
object AluModSel  extends SpinalEnum(defaultEncoding=native) { val add, funct = newElement() }
object JmpSel     extends SpinalEnum(defaultEncoding=native) { val alu, ecall = newElement() }
object MemMode    extends SpinalEnum(defaultEncoding=native) { val read, write, none = newElement() }
object RegIn      extends SpinalEnum(defaultEncoding=native) { val alu, mem, nxtPc = newElement() }
object Func       extends SpinalEnum(defaultEncoding=native) { val add, sub, xor, or, and, sll, srl, sra, slt, sltu = newElement()}

case class RegIdentifier(config: CoreConfig) extends Bundle {
  val reg = UInt(5 bits)
  val valid = Bool()
}

case class RegValue(config: CoreConfig) extends Bundle {
  val value = UInt(config.xlen bits)
  val reg = UInt(5 bits)
  val valid = Bool()
}

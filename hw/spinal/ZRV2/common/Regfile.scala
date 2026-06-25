package ZRV2.common

import ZRV2.CoreConfig
import ZRV2.common._
import spinal.core._
import spinal.lib._

import scala.language.postfixOps

case class Regfile(config: CoreConfig) extends Component {
  val io = new Bundle {
    val rs1     = in( UInt(5 bits) )
    val rs2     = in( UInt(5 bits) )

    val rd      = in( UInt(5 bits) )
    val we      = in Bool()
    val rdVal   = in( UInt(config.xlen bits) )

    val rs1Out  = out( UInt(config.xlen bits) )
    val rs2Out  = out( UInt(config.xlen bits) )
  }

  val regfile = Vec.fill(32)(Reg(UInt(config.xlen bits)))

  /* Read */
  when (io.rs1 === 0) {
    io.rs1Out := 0
  } otherwise {
    io.rs1Out := regfile(io.rs1)
  }
  when (io.rs2 === 0) {
    io.rs2Out := 0
  } otherwise {
    io.rs2Out := regfile(io.rs1)
  }

  /* Write */
  when (!(io.rd === 0) && io.we) {
    regfile(io.rd) := io.rdVal
  }
}

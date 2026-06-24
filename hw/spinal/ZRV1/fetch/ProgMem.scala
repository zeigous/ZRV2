package ZRV1.fetch

import ZRV1.CoreConfig
import ZRV1.common._
import spinal.core._

import scala.io.Source
import scala.language.postfixOps

object HexLoader {
  def load(path: String): Array[BigInt] = {
    Source.fromFile(path).getLines()
      .map(_.trim)
      .filter(line => line.nonEmpty && !line.startsWith("//"))
      .map(line => BigInt(line, 16))
      .toArray
  }
}

case class ProgMem(config: CoreConfig) extends Component {
  val io = new Bundle {
    val input = in( F1ToProgMem(config) )
    val output = out( ProgMemToF2(config) )
  }
  val romContent = HexLoader.load(config.progMemPath)

  val progMem = Mem(Bits(config.xlen bits), wordCount = romContent.length)
  progMem.init(romContent.map(B(_)))

  io.output.mem := progMem.readSync(address = io.input.addr(log2Up(romContent.length) + 1 downto 2), enable = True)
}

import com_pkg::*;
`include "common/com_if.svh"

module Decode3(
    input clk,
    input rst,
    input clk_en,
    
    input stall,
    input flush_t flush,

    id2_id3_if.decode3 in,
    id3_rn_if.decode3 out
);

    always_ff @(posedge clk) begin
        if (clk_en && !stall && !rst && !flush.valid) begin // eventually will add splitting for fused fp-ops
            out.valid <= in.valid;
            out.instruction.func <= in.decoded_instruction.func;
            out.instruction.inst_class <= in.decoded_instruction.inst_class;
            out.instruction.illegal <= in.decoded_instruction.illegal;
            out.pc <= in.pc;
            out.predicted_next_adr <= in.predicted_next_adr;
            
            // rs1
            out.instruction.rs1.predetermined <= in.decoded_instruction.uses_pc;
            out.instruction.rs1.rs <= in.decoded_instruction.rs1.sel;
            out.instruction.rs1.val <= (in.decoded_instruction.uses_pc) ? in.pc : '0;
            out.instruction.rs1.valid <= (in.decoded_instruction.rs1.used | in.decoded_instruction.uses_pc);

            // rs2
            out.instruction.rs2.predetermined <= in.decoded_instruction.has_imm;
            out.instruction.rs2.rs <= in.decoded_instruction.rs2.sel;
            out.instruction.rs2.val <= (in.decoded_instruction.has_imm) ? in.decoded_instruction.imm : '0;
            out.instruction.rs2.valid <= (in.decoded_instruction.rs2.used | in.decoded_instruction.has_imm);

            // rs3 (currently store val)
            out.instruction.rs3.predetermined <= '0;
            out.instruction.rs3.rs <= in.decoded_instruction.rs2.sel;
            out.instruction.rs3.val <= '0;
            out.instruction.rs3.valid <= (in.decoded_instruction.rs2.used && in.decoded_instruction.has_imm) ? '1 : '0;

            // rd 
            out.instruction.rd.predetermined <= '0;
            out.instruction.rd.rs <= in.decoded_instruction.rd.sel;
            out.instruction.rd.val <= '0;
            out.instruction.rd.valid <= in.decoded_instruction.rd.used;

        end else if (flush.valid || rst) begin
            out.valid <= '0;
        end
    end
    
    
endmodule

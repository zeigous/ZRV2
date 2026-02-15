import com_pkg::*;

`include "common/com_if.svh"

module Decode2 #(
    parameter WIDTH = 32
)(
    input clk,
    input rst,
    input clk_en,

    id1_id2_if.decode2 in,

    id2_id3_if.decode2 out,

    input flush_t flush,
    input stall,

    output flush_t flush_out
);

    // predicted addresses
    wire [WIDTH - 1 : 0] jal_branch_adr = (in.pc + in.decoded_instruction.imm) & 32'hFFFFFFFC;
    wire [WIDTH - 1 : 0] jalr_adr = (ras_address_out + in.decoded_instruction.imm) & 32'hFFFFFFFC;

    always_ff @(posedge clk) begin
        if (clk_en && !stall && !flush.valid && !rst) begin
            out.valid <= in.valid;
            out.predicted_next_adr <= predicted_adr;
            out.pc <= in.pc;

            // decoded instruction mapping
            out.decoded_instruction.inst_class <= in.decoded_instruction.inst_class;
            out.decoded_instruction.rd <= in.decoded_instruction.rd;
            out.decoded_instruction.rs1 <= in.decoded_instruction.rs1;
            out.decoded_instruction.rs2 <= in.decoded_instruction.rs2;
            out.decoded_instruction.imm <= in.decoded_instruction.imm;
            out.decoded_instruction.has_imm <= in.decoded_instruction.has_imm;
            out.decoded_instruction.uses_pc <= in.decoded_instruction.uses_pc;
            out.decoded_instruction.func <= in.decoded_instruction.func;
            out.decoded_instruction.illegal <= ((in.decoded_instruction.inst_class == ILLEGAL) || (in.decoded_instruction.func == IL)) ? '1 : '0;

        end else if (flush.valid || rst) begin
            out.valid <= '0;
        end
    end

    wire [WIDTH - 1 : 0] ras_address_out;

    wire [WIDTH - 1 : 0] predicted_adr;

    always_comb begin
        flush_out.valid = 0;
        flush_out.address = 0;

        predicted_adr = in.pc + 4;

        if (!in.branch_jump) begin 
            if (in.predicted_next_adr != in.pc + 4) begin // should never happen
                flush_out.address = in.pc + 4;
                flush_out.valid = '1;

            end else if (in.decoded_instruction.inst_class == JAL) begin
                flush_out.address = jal_branch_adr;
                predicted_adr = jal_branch_adr;
                flush_out.valid = '1;

            end else if (in.decoded_instruction.inst_class == JALR) begin
                flush_out.address = jalr_adr;
                jal_branch_adr = jalr_adr;
                flush_out.valid = '1;

            end else if (in.decoded_instruction.inst_class == BRANCH) begin
                flush_out.address = jal_branch_adr;
                predicted_adr = jal_branch_adr;
                flush_out.valid = '1;
            end
            
        end else if (in.branch_jump) begin
            if (in.decoded_instruction.inst_class == JAL) begin // mispredicted address
                flush_out.address = jal_branch_adr;
                flush_out.valid = (jal_branch_adr == in.predicted_next_adr) ? '0 : '1;
                predicted_adr = jal_branch_adr;

            end else if (in.decoded_instruction.inst_class == JALR) begin // mispredicted address
                flush_out.address = jalr_adr;
                flush_out.valid = (jalr_adr == in.predicted_next_adr)  ? '0 : '1;
                predicted_adr = jalr_adr;

            end else if (in.decoded_instruction.inst_class == BRANCH) begin // mispredicted address
                flush_out.address = jal_branch_adr;
                flush_out.valid = (jal_branch_adr == in.predicted_next_adr || jal_branch_adr == in.pc + 4) ? '0 : '1;
                predicted_adr = jal_branch_adr;

            end else begin // not a jump
                flush_out.address = in.pc + 4;
                flush_out.valid = '1;
            end
        end

        flush_out.valid &= in.valid; // only flush if input is valid
    end

    Ras #(
        .WIDTH(WIDTH)
    ) Ras_instance (
        .clk(clk),
        .rst(rst),
        .clk_en(clk_en),
        .flush(flush),
        .valid( (in.valid && (in.decoded_instruction.inst_class == JAL || in.decoded_instruction.inst_class == JALR) ) ? 1'b1 : 1'b0 ),
        .pc(in.pc),
        .rs1( (in.decoded_instruction.inst_class == JALR) ? in.decoded_instruction.rs1 : 5'b0),
        .rd( (in.decoded_instruction.inst_class == JAL || in.decoded_instruction.inst_class == JALR) ? in.decoded_instruction.rd : 5'b0 ),
        .address_out(ras_address_out)
    );
    
endmodule

import com_pkg::*;
`include "common/com_if.svh"

module Decode1(
    input clk,
    input rst,
    input clk_en,

    // stall and flush
    input stall,
    input flush_t flush,

    i_cache_if.decode cache_if,

    id1_id2_if.decode1 stage_if
);

    decode_instruction_t decoded_instruction;
    
    SimpleDecoder #(
        .WIDTH(32)
    ) SimpleDecoder_instance (
        .inst_in(cache_if.cache_data_out),
        .inst_out(decoded_instruction)
    );

    always_ff @(posedge clk) begin
        if (clk_en && !stall && !flush.valid && !rst && cache_if.data_valid) begin
            stage_if.valid <= cache_if.data_valid;
            stage_if.pc <= cache_if.cache_adr_out;
            stage_if.decoded_instruction <= decoded_instruction;
            stage_if.predicted_next_adr <= cache_if.predicted_next_adr;
            stage_if.branch_jump <= cache_if.branch_jump;
        end else if (flush.valid || rst || !cache_if.data_valid) begin
            stage_if.valid <= '0;
        end
    end
    

endmodule

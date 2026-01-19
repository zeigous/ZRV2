`include "common/com_if.svh"
import com_pkg::*;

module predecode #()(
    input clk,
    input rst,
    input clk_en,

    // cache interface
    i_cache_if.predecode cache_if,

    // wire back to fetch
    ouput [4:0] pc_inc_amount,

    // flush
    input flush_t flush,

    // stall
    input stall
);
    logic [4:0] length = 0;

    always_comb begin

    end

    assign pc_inc_amount = length;

endmodule : predecode

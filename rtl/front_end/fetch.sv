`include "common/com_if.svh"
import com_pkg::*;

module fetch #()(
    input clk,
    input rst,
    input clk_en,

    // cache interface
    i_cache_if.fetch cache_if

    // flush

);
endmodule : fetch

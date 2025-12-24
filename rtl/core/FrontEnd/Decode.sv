`include "../common/common.svh"

module Decode(
    input clk,
    input clkEn,
    input rst
);

    always_ff @(posedge clk) begin
        if (rst && clkEn) begin

        end else if (clkEn) begin
            
        end
    end
    

endmodule : Decode

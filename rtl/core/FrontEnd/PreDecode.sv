`include "../common/common.svh"

module PreDecode(
    input clk,
    input clkEn,
    input rst
);

    always_ff @(posedge clk) begin
        if (rst && clkEn) begin

        end else if (clkEn) begin
            
        end
    end
    
endmodule

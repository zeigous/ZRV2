`include "../../common/common.svh"

module GShare (
    input clk,
    input clkEn,
    input rst,

    // PC and Update Signals
    input wire [31:0] pc,
    
    input wire update,
    input wire result,

    // prediction output
    output wire prediction
);
    // Parameters
    localparam ENTRIES = 4096;
    localparam LEN = 12;

    // GHR & PHT
    reg [LEN - 1 : 0] ghr; 
    reg [ENTRIES * 2 - 1 : 0] pht;

    // index the pht
    wire [LEN - 1 : 0] index = pc[13:2] ^ ghr;
    wire phtVal = pht[(index << 1) +: 2];

    // predict
    assign prediction = (phtVal < 2) ? 1'b0 : 1'b1;

    always_ff @(posedge clk) begin
        if (clkEn) begin
            if (rst) begin
                phtVal = {ENTRIES{2'b01}};
            end else if (update) begin
                if (result) begin
                    pht[(index << 1) +: 2] <=(pht[(index << 1) +: 2] < 3) ? pht[(index << 1) +: 2] + 1 : 2'h3;
                end else begin
                    pht[(index << 1) +: 2] <=(pht[(index << 1) +: 2] > 0) ? pht[(index << 1) +: 2] - 1 : 2'h0;
                end
            end
        end
    end
endmodule : GShare

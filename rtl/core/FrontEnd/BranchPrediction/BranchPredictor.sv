`include "../../common/common.svh"

module BranchPredictor (
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
    assign prediction = 0; // TEMP
endmodule : BranchPredictor

`include "../common/common.svh"

module FetchEngine(
    input clk,
    input clkEn,
    input rst

);
    localparam WIDTH = 64;
    
    // pc 
    reg [WIDTH - 1 : 0] pc;

    ////////////////////////////
    // Branch Prediction
    ////////////////////////////

    wire prediction;
    BranchPredictor BranchPredictor_instance (
        .clk(clk),
        .clkEn(clkEn),
        .rst(rst),
        .pc(pc),
        .update(/* */),
        .result(/* */),
        .prediction(prediction)
    );

    wire BTBDest;
    wire BTBValid;
    wire BTBUnconditional;
    BTB BTB_instance (
        .clk(clk),
        .clkEn(clkEn),
        .rst(rst),
        .pc(pc),
        .update(/* */),
        .destIn(/* */),
        .unconditionalIn(/* */),
        .destOut(BTBDest),
        .validOut(BTBValid),
        .unconditionalOut(BTBUnconditional)
    );

    ////////////////////////////
    // Fetch Unit
    ////////////////////////////

    always_ff @(posedge clk) begin
        if (rst && clkEn) begin

        end else if (clkEn) begin
            
        end
    end
    
endmodule : FetchEngine
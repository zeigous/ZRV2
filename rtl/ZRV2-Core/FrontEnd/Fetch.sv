`include "../common/common.svh"

module Fetch(
    input clk,
    input clkEn,
    input rst,

    // stalling & flushing
    input wire stall,
    input Flush flush,

    // output to decode
    output FetchOut out,

    // output to i-cache
    output iCacheRequest cacheRequestOut,

    // i-cache stall
    input wire iCacheStall
);
    // pc 
    reg [31:0] pc;

    ////////////////////////////
    // Branch Prediction
    ////////////////////////////

    wire GSharePrediction;
    GShare GShare_instance (
        .clk(clk),
        .clkEn(clkEn),
        .rst(rst),
        .pc(pc),
        .update(flush.en & flush.branch & !flush.unconditional),
        .result(flush.branchTaken),
        .prediction(GSharePrediction)
    );

    wire BTBDest;
    wire BTBValid;
    wire BTBUnconditional;
    BTB BTB_instance (
        .clk(clk),
        .clkEn(clkEn),
        .rst(rst),
        .pc(pc),
        .update(flush.en & flush.branch),
        .destIn(flush.address),
        .unconditionalIn(flush.unconditional),
        .destOut(BTBDest),
        .validOut(BTBValid),
        .unconditionalOut(BTBUnconditional)
    );

    ////////////////////////////
    // Fetch Unit
    ////////////////////////////

    always_ff @(posedge clk) begin
        if (clkEn) begin
            if (rst) begin
                pc                  <= 'h0;
                out                 <= 'h0;
            end else if (flush.en) begin
                pc                  <= flush.address;
                out.pc              <= flush.address; // doesnt really matter since the i-cache request is invalid anyways
            end else if (!stall && !iCacheStall) begin
                // update output
                out.pc              <= pc;
                out.branch          <= BTBValid;
                out.unconditional   <= BTBUnconditional;
                out.branchTaken     <= GSharePrediction;
                out.branchAddress   <= BTBDest;
                // update PC based on prediction
                if (BTBValid) begin
                    if (!BTBUnconditional && GSharePrediction) begin
                        pc          <= BTBDest;
                    end else begin
                        pc          <= pc + 4;
                    end
                end else begin
                    pc              <= pc + 4;
                end
            end
        end
    end
    
    // cache request
    assign cacheRequestOut.pc       = pc;
    assign cacheRequestOut.valid    = (flush.en) ? 'b1 : 'b0; // we have to invalidate or else the instruction is duplicated
    
endmodule : Fetch
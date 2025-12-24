`include "../../common/common.svh"

module BTB (
    input clk,
    input clkEn,
    input rst,

    // inputs for predicting
    input wire [31:0] pc,

    // inputs for updating
    input wire update,
    input wire [31:0] destIn,
    input wire unconditionalIn,

    // prediction out
    output wire [31:0] destOut,
    output wire validOut,
    output wire unconditionalOut

);
    assign validOut = 0;            //
    assign unconditionalOut = 0;    // TEMP
    assign destOut = 0;             //
endmodule

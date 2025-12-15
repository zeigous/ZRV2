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

    // parameters
    localparam ENTRIES = 256;
    localparam LEN = 8; // index bit length
    
    reg [31-LEN - 2 : 0] innerTag [ENTRIES]; // -2 due to pc being always 4 byte aligned
    reg [ENTRIES-1 : 0] innerValid; // packed for easy reset
    reg [31:0] innerDest [ENTRIES];
    reg innerUnconditional [ENTRIES];

    wire index = pc[(LEN + 1) : 2]; // +1 because +2 and -1 

    always_ff @(posedge clk) begin
        if (clkEn) begin
            if (rst) begin
                innerValid <= 'h0;
            end else if (update) begin
                innerDest[index] <= destIn;
                innerValid[index] <= 'b1;
                innerTag[index] <= pc[31 : LEN + 2];
                innerUnconditional[index] <= unconditionalIn;
            end
        end
    end

    // assign prediction output
    assign destOut = innerDest[index]; 
    assign validOut = (innerValid[index] && (innerTag[index] == pc[31 : LEN + 2])) ? 1 : 0;
    assign unconditionalOut = innerUnconditional[index];

endmodule

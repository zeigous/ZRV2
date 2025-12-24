`include "../common/common.svh"

module FetchBuffer(
    input clk,
    input clkEn,
    input rst,

    // Inputs //
    input wire [4 : 0]          decodePointerIn,  // pointer within the fetch buffer, determined during predecode, 
                                                  // that determines the next byte at which the decode stage decodes

    input wire [127 : 0]        incomingSection, // section coming from the fetch engine
    input wire [WIDTH - 1 : 0]  incomingPc, // pc of the incoming section
    input wire                  incomingValid, // whether the incoming section is valid or not, if its not, then we stall

    // Outputs //
    output reg [4 : 0]          decodePointerOut, // new decode pointer
    output wire                 preDecodeStall, // wire because the stall combos are registers
    output wire [127 : 0]       bufferSectionOut // output of the buffer to predecode
);

    localparam WIDTH = 64;
    

    // FETCH BUFFER
    // Note: 2 Sections, both 16B, circular buffer
    reg [255 : 0]               fetchBuffer;
    // Note: tags for each section, 2 64b tags
    reg [2 * WIDTH - 1 : 0]     bufferTags;
    // Note: valid bits for buffer
    reg [1 : 0]                 bufferValid;

    // both the possible stall combos
    reg stallFromInvalid;
    reg stallFromNoIncoming;
    
    always_ff @(posedge clk) begin
        if ( rst && clkEn ) begin
            fetchBuffer <= '0;
            bufferTags  <= '0;
            bufferValid <= '0;
        end else if ( clkEn ) begin
            
        end
    end
    
    assign preDecodeStall = stallFromInvalid | stallFromNoIncoming;

endmodule : FetchBuffer

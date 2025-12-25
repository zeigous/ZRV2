import common::*;

module PreDecode #(
    parameter WIDTH = 64,
    parameter BUFFER_SIZE = 16
)(
    input clk,
    input clkEn,
    input rst,

    input stall,
    input Flush flush,

    input wire fetchBufferStall,
    input wire [63:0] fetchBufferPc,
    input wire [127:0] fetchBufferInput,
    
    // outputs
    output wire nextInstructionCrosses, // if the next (not currently handled) instruction crosses the fetch boundary
    output wire currentInstructionCrosses,

    // output to decode
    PreDecodeOut out

);

    // pointer in the fetch buffer
    reg [3:0] bufferPointer;

    // bytes left in the buffer that the next instruction needs
    reg [12 * 8:0] remainingBytes;
    reg [3:0] bytesInBuffer; // bytes within the remaining byte buf
    reg [3:0] bytesRemaining; // bytes remaining in the instruction

    // determining the length of the instruction
    logic [3:0] instructionLength;
    logic [3:0] nextInstructionLength;

    // determine crossings
    assign currentInstructionCrosses = (bufferPointer + instructionLength > BUFFER_SIZE) ? '1 : '0;
    assign nextInstructionCrosses = (bufferPointer + instructionLength == BUFFER_SIZE || (nextInstructionLength + bufferPointer + instructionLength) > BUFFER_SIZE) ? '1 : '0;

    enum { NORMAL, CURRENT_CROSSING, NEXT_CROSSING, FETCH_STALL } state;

    always_ff @(posedge clk) stateMachine : begin
        if (rst && clkEn) begin
            bufferPointer <= 0;
            bytesRemaining <= 0;
            state <= NORMAL;
        end else if (flush.en && clkEn) begin
            bufferPointer <= flush.address[3:0]; // Take the low bits
            bytesInBuffer <= 0;
            bytesRemaining <= 0;
            state <= NORMAL;
        end else if (!stall && !fetchBufferStall && clkEn) begin
            case (state)
                NORMAL: begin
                    if (currentInstructionCrosses) begin
                        state <= CURRENT_CROSSING;
                        // store bytes in the buffer
                        bytesInBuffer <= 16 - bufferPointer;
                        bytesRemaining <= instructionLength - (16 - bufferPointer);
                        remainingBytes <= fetchBufferInput[127 : bufferPointer * 8];
                        // insert bubble
                        out.instruction <= '0;
                        out.instructionLength <= 3;
                        out.instructionPc <= fetchBufferPc + bufferPointer;

                    end else if (nextInstructionCrosses) begin
                        state <= NEXT_CROSSING;
                        // store bytes in the buffer
                        bytesInBuffer <= 16 - bufferPointer;
                        bytesRemaining <= instructionLength - (16 - bufferPointer);
                        remainingBytes <= fetchBufferInput[127 : bufferPointer * 8];
                        // to decode
                        out.instruction <= fetchBufferInput[(bufferPointer + instructionLength) * 8 - 1: bufferPointer * 8];
                        out.instructionLength <= instructionLength;
                        out.instructionPc <= fetchBufferPc + bufferPointer;
                        
                    end else begin
                        bufferPointer <= bufferPointer + instructionLength;
                        // to decode
                        out.instruction <= fetchBufferInput[(bufferPointer + instructionLength) * 8 - 1: bufferPointer * 8];
                        out.instructionLength <= instructionLength;
                        out.instructionPc <= fetchBufferPc + bufferPointer;
                    end
                end



                default: state <= NORMAL;
            endcase
        end 
    end

    
    //---------------------------------------------------------[instruction length lut]----------------------------------------------------------//
    logic [2:0] lengthLut [0:7] = '{2, 3, 4, 5, 7, 9, 11, 12};
    always_comb lengthLookup : begin
        nextInstructionLength = '0;

        instructionLength = lengthLut[ fetchBufferInput[(bufferPointer * 8) - 1 +: 3] ]; // get the first 3 bits of the first byte of the instruction for length
        if (bufferPointer + instructionLength <= BUFFER_SIZE) begin
            nextInstructionLength = lengthLut[ fetchBufferInput[(bufferPointer + instructionLength) * 8 +: 3] ];
        end
    end
    
    
endmodule : PreDecode

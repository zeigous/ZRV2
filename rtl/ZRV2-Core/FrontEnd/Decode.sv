`include "../common/common.svh"

module Decode(
    input clk,
    input clkEn,
    input rst,

    // flush & stall
    input Flush flush,
    input wire stall,

    // input from Fetch & i-cache   
    input FetchOut fetchInput,
    input iCacheRequest cacheInput,

    // output to rename & issue
    DecodeOut out
);

    always_ff @(posedge clk) begin
        if (clkEn) begin
            if (rst) begin
                out <= '0;
            end else begin
                if (!cacheInput.valid || flush.en) begin

                end else if (!stall) begin

                end
            end
        end
    end
    
    function DecodeOut decode(input logic [31:0] instruction, input logic [31:0] pc);
        OpDecodeType opcode = OpDecodeType'(instruction[6:0]);
        DecodeOut out = '0;

        // defaults for out
        out = 0;
        out.pc = pc;

        // decode
        case (opcode) 
            I_EBRK_CAL : begin
                out.controlSignals.opClass = NOP;
            end

            I_AUIPC : begin
                // registers & immediates
                out.imm = {instruction[31:12], 12'b0} + pc;
                out.archRd = instruction[11:7];

                // Control Signals
                out.controlSignals.hasDest = (out.archRd == 0) ? '0 : '1;
                // keep most control signals default cause rd is predetermined
                out.rdIsPredetermined = '1;
                out.controlSignals.opClass = ROB_WRITE_NOP; // ROB_WRITE_NOP so we dont issue, but we still put in the rob       
            end

            I_LUI : begin
                // registers & immediates
                out.imm = {instruction[31:12], 12'b0};
                out.archRd = instruction[11:7];

                // Control Signals
                out.controlSignals.hasDest = (out.archRd == 0) ? '0 : '1;
                // keep most control signals default cause rd is predetermined
                out.rdIsPredetermined = '1;
                out.controlSignals.opClass = ROB_WRITE_NOP; // ROB_WRITE_NOP so we dont issue, but we still put in the rob 
            end

            I_JALR : begin
                // registers & immediates
                out.imm = signed'(instruction[31:20]);
                out.archRd = instruction[11:7];
                out.archRs1 = instruction[19:15];

                // Control Signals
                out.controlSignals.hasDest = (out.archRd == 0) ? '0 : '1;
                // rd is next pc
                out.rdIsNextPc = '1;
                out.controlSignals.useImmForRs2 = '1;
                out.controlSignals.opClass = JALR;
            end

            I_JAL : begin
                // registers & immediates
                out.imm = signed'({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}) + pc;
                out.archRd = instruction[11:7];

                // Control Signals
                out.controlSignals.hasDest = (out.archRd == 0) ? '0 : '1;
                out.rdIsNextPc = '1;
                out.immIsBranchDestination = '1;
                out.controlSignals.opClass = JAL;
            end
            I_BRANCH : begin
                // registers & immediates
                out.archRs1 = instruction[19:15];
                out.archRs2 = instruction[24:20];
                out.imm = signed'({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}) + pc;

                // Control Signals
                out.immIsBranchDestination = '1;
                out.controlSignals.opClass = BRANCH;
                out.controlSignals.func = remapFunc(out.controlSignals.opClass, 7'h0, instruction[14:12]);
            end
        endcase

        decode = out;
    endfunction 


    // remap funcs
    function OpFunc remapFunc(input OpClass opClass, input logic [6:0] funct7, input logic [2:0] funct3);
        OpFunc opFunc = F_DEFAULT;

        case (opClass)
            ALU : begin 
                case ({funct7, funct3}) 
                    10'b0000000_000: opFunc = F_ADD;
                    10'b0100000_000: opFunc = F_SUB;
                    10'b0000000_100: opFunc = F_XOR;
                    10'b0000000_110: opFunc = F_OR;
                    10'b0000000_111: opFunc = F_AND;
                    10'b0000000_001: opFunc = F_SLL;
                    10'b0000000_101: opFunc = F_SRL;
                    10'b0100000_101: opFunc = F_SRA;
                    10'b0000000_010: opFunc = F_SLT;
                    10'b0000000_011: opFunc = F_SLTU;
                    default: opFunc = F_ADD; 
                endcase
            end
            LOAD : opFunc = OpFunc'(funct3);
            STORE : opFunc = OpFunc'(funct3);
            MUL : opFunc = OpFunc'(funct3[1:0]);
            DIV : opFunc = OpFunc'(funct3[2:1]);
            BRANCH : opFunc = OpFunc'(funct3);
            default : opFunc = F_DEFAULT;
        endcase
        remapFunc = opFunc;
    endfunction
endmodule : Decode

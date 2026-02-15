import com_pkg::*;

module SimpleDecoder #(
    parameter WIDTH = 32
)(
    input [WIDTH - 1 : 0] inst_in,

    output decode_instruction_t inst_out
);

    // func decode
    always_comb begin
        inst_out.func = ADD;
        case (inst_in[6:0])
            7'h13: begin
                case(inst_in[14:12])
                    3'h0: inst_out.func = ADD;
                    3'h1: inst_out.func = SLL;
                    3'h2: inst_out.func = SLT;
                    3'h3: inst_out.func = SLTU;
                    3'h4: inst_out.func = XOR;
                    3'h5: inst_out.func = (inst_in[30]) ? SRA : SRL;
                    3'h6: inst_out.func = AND;
                    3'h7: inst_out.func = OR;
                    default: inst_out.func = IL;
                endcase
            end
            7'h33: begin
                case(inst_in[14:12])
                    3'h0: inst_out.func = (inst_in[30]) ? SUB : ADD;
                    3'h1: inst_out.func = SLL;
                    3'h2: inst_out.func = SLT;
                    3'h3: inst_out.func = SLTU;
                    3'h4: inst_out.func = XOR;
                    3'h5: inst_out.func = (inst_in[30]) ? SRA : SRL;
                    3'h6: inst_out.func = AND;
                    3'h7: inst_out.func = OR;
                    default: inst_out.func = IL;
                endcase
            end
            7'h03: inst_out.func = inst_func_t'(inst_in[14:12]);
            7'h23: inst_out.func = inst_func_t'(inst_in[14:12]);
            7'h63: begin
                case(inst_in[14:12])
                    3'h0: inst_out.func = BEQ;
                    3'h1: inst_out.func = BNE;
                    3'h4: inst_out.func = BLT;
                    3'h5: inst_out.func = BGE;
                    3'h6: inst_out.func = BLTU;
                    3'h7: inst_out.func = BGEU;
                    default: inst_out.func = IL;
                endcase
            end
            7'h6F: inst_out.func = ADD;
            7'h67: inst_out.func = ADD;
            7'h37: inst_out.func = ADD;
            7'h17: inst_out.func = ADD;
            default: inst_out.func = IL;
        endcase
    end

    // rs decode
    always_comb begin
        inst_out.rd.used = 1'b0;
        inst_out.rs1.used = 1'b0;
        inst_out.rs2.used = 1'b0;

        inst_out.has_imm = 1'b0;
        inst_out.uses_pc = 1'b0;

        // rs
        inst_out.rd.sel = inst_in[11:7];
        inst_out.rs1.sel = inst_in[19:15];
        inst_out.rs2.sel = inst_in[24:20];

        case (inst_in[6:0])
            7'h13: begin
                inst_out.rd.used = 1'b1;
                inst_out.has_imm = 1'b1;
                inst_out.rs1.used = 1'b1;
            end
            7'h33: begin
                inst_out.rd.used = 1'b1;
                inst_out.rs1.used = 1'b1;
                inst_out.rs2.used = 1'b1;
            end
            7'h03: begin
                inst_out.rd.used = 1'b1;
                inst_out.has_imm = 1'b1;
                inst_out.rs1.used = 1'b1;
            end
            7'h23: begin
                inst_out.rs1.used = 1'b1;
                inst_out.has_imm = 1'b1;
                inst_out.rs2.used = 1'b1;
            end
            7'h63: begin
                inst_out.rs1.used = 1'b1;
                inst_out.rs2.used = 1'b1;
            end
            7'h6F: begin
                inst_out.rd.used = 1'b1;
                inst_out.has_imm = 1'b1;
            end
            7'h67: begin
                inst_out.rd.used = 1'b1;
                inst_out.rs1.used = 1'b1;
                inst_out.has_imm = 1'b1;
            end
            7'h37: begin
                inst_out.rd.used = 1'b1;
                inst_out.has_imm = 1'b1;
            end
            7'h17:begin
                inst_out.rd.used = 1'b1;
                inst_out.has_imm = 1'b1;
                inst_out.uses_pc = 1'b1;
            end
            default: /* */;
        endcase
    end

    // Imm decode
    always_comb begin
        inst_out.imm = 0;
        case (inst_in[6:0])
            7'h13: inst_out.imm = {{20{inst_in[31]}}, inst_in[31:20]};
            7'h03: inst_out.imm = {{20{inst_in[31]}}, inst_in[31:20]};
            7'h23: inst_out.imm = {{20{inst_in[31]}}, inst_in[31:25], inst_in[11:7]};
            7'h63: inst_out.imm = {{19{inst_in[31]}}, inst_in[7], inst_in[30:25], inst_in[11:8], 1'b0};
            7'h6F: inst_out.imm = {{11{inst_in[31]}}, inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};
            7'h67: inst_out.imm = {{20{inst_in[31]}}, inst_in[31:20]};
            7'h37: inst_out.imm = {inst_in[31:12], 12'b0};
            7'h17: inst_out.imm = {inst_in[31:12], 12'b0};
            default: inst_out.imm = 32'h0;
        endcase

        if (inst_in[14:12] == 5) begin
            inst_out.imm[10] = 0;
        end
    end
    
    // LUT for class
    always_comb begin
        inst_out.inst_class = ILLEGAL;
        case (inst_in[6:0]) 
            7'h13: inst_out.inst_class = ALU;
            7'h33: inst_out.inst_class = ALU;
            7'h03: inst_out.inst_class = LOAD;
            7'h23: inst_out.inst_class = STORE;
            7'h63: inst_out.inst_class = BRANCH;
            7'h6F: inst_out.inst_class = JAL;
            7'h67: inst_out.inst_class = JALR;
            7'h37: inst_out.inst_class = ALU;
            7'h17: inst_out.inst_class = ALU;

            default: inst_out.inst_class = ILLEGAL;
        endcase
    end
endmodule

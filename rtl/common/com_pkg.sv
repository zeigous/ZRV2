// shared stuff
/* verilator lint_off TIMESCALEMOD */
package com_pkg;
    typedef struct packed {
        logic [31:0] address;
        logic valid;
        logic redirect;
        logic jump;
        logic taken;
    } flush_t;

    // final instruction package
    typedef struct packed {
        inst_class_t inst_class;
        reg_pack_t rs1;
        reg_pack_t rs2;
        reg_pack_t rs3;
        reg_pack_t rd;
        inst_func_t func;
        logic illegal;
    } instruction_pack_t;

    typedef struct packed {
        logic [4:0] rs;
        logic [31:0] val;
        logic valid;
        logic predetermined;
    } reg_pack_t;
    
    // decode stuff
    typedef struct packed {
        inst_class_t inst_class;
        decode_reg_t rd;
        decode_reg_t rs1;
        decode_reg_t rs2;
        logic [31:0] imm;
        logic has_imm;
        logic uses_pc;
        inst_func_t func;
        logic illegal;
    } decode_instruction_2_t;

    typedef struct packed {
        inst_class_t inst_class;
        decode_reg_t rd;
        decode_reg_t rs1;
        decode_reg_t rs2;
        logic [31:0] imm;
        logic has_imm;
        logic uses_pc;
        inst_func_t func;
    } decode_instruction_t;

    typedef enum logic [3:0] {
        ALU,
        LOAD,
        STORE,
        BRANCH,
        JAL,
        JALR,
        ILLEGAL
    } inst_class_t;

    typedef enum logic [3:0] {
        /* ALU FUNCS */
        ADD     = 0,
        SUB     = 1,
        XOR     = 2,
        OR      = 3,
        AND     = 4,
        SLL     = 5,
        SRL     = 6,
        SRA     = 7,
        SLT     = 8,
        SLTU    = 9,

        /* LOAD FUNCS */
        LB      = 0,
        LH      = 1,
        LW      = 2,
        LBU     = 4,
        LHU     = 5,

        /* STORE FUNCS */
        SB      = 0,
        SH      = 1,
        SW      = 2,

        /* BRANCH FUNCS */
        BEQ     = 0,
        BNE     = 1,
        BLT     = 2,
        BGE     = 3,
        BLTU    = 4,
        BGEU    = 5,

        IL = 4'hF /* ILLEGAL */
    } inst_func_t;

    typedef struct packed {
        logic [3:0] sel;
        logic used;
    } decode_reg_t;
endpackage

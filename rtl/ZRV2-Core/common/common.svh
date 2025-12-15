`pragma once

typedef struct packed {
    logic [31:0] address;
    logic en;
    logic branch;
    logic unconditional;
    logic branchTaken;
    logic [31:0] branchPc;
} Flush;

///////////////
// Fetch 
///////////////
typedef struct packed {
    logic [31:0] pc;
    logic branch;
    logic unconditional;
    logic branchTaken;
    logic [31:0] branchAddress;
} FetchOut;

typedef struct packed {
    logic [31:0] pc;
    logic valid;
} iCacheRequest;


///////////////
// Decode 
///////////////
// post-decode instruction classes (for determining specific scheduler etc)
typedef enum logic [2:0] {
    NOP,
    ROB_WRITE_NOP,
    ALU,
    LOAD,
    STORE,
    FENCEI,
    FENCE,
    MUL,
    DIV,
    BRANCH,
    JAL,
    JALR
} OpClass;

// pre-decode opcodes
typedef enum logic [6:0] {
    I_EBRK_CAL  = 7'b1110011,
    I_AUIPC     = 7'b0010111,
    I_LUI       = 7'b0110111,
    I_JALR      = 7'b1100111,
    I_JAL       = 7'b1101111,
    I_BRANCH    = 7'b1100011,
    I_STORE     = 7'b0100011,
    I_LOAD      = 7'b0000011,
    I_ALUI      = 7'b0010011,
    I_ALU_MD    = 7'b0110011,
    I_MISC_MEM  = 7'b0001111
} OpDecodeType;

typedef enum logic [3:0] {
    // ALU Funcs
    F_ADD   = 4'h0,
    F_SUB   = 4'h1,
    F_XOR   = 4'h2,
    F_OR    = 4'h3,
    F_AND   = 4'h4,
    F_SLL   = 4'h5,
    F_SRL   = 4'h6,
    F_SRA   = 4'h7,
    F_SLT   = 4'h8,
    F_SLTU  = 4'h9,

    // LOAD Funcs
    F_LB    = 4'h0,
    F_LH    = 4'h1,
    F_LW    = 4'h2,
    F_LBU   = 4'h4,
    F_LHU   = 4'h5,

    // STORE Funcs
    F_SB    = 4'h0,
    F_SH    = 4'h1,
    F_SW    = 4'h2,

    // MULTIPLY Funcs
    F_MUL   = 4'h0,
    F_MULH  = 4'h1,
    F_MULSU = 4'h2,
    F_MULU  = 4'h3,

    // DIVIDE Funcs
    F_DIV   = 4'h0,
    F_DIVU  = 4'h1,
    F_REM   = 4'h2,
    F_REMU  = 4'h3,

    // BRANCH Funcs
    F_BEQ   = 4'h0,
    F_BNE   = 4'h1,
    F_BLT   = 4'h4,
    F_BGE   = 4'h5,
    F_BTLU  = 4'h6,
    F_BGEU  = 4'h7,

    

    // default
    F_DEFAULT = 4'h0
} OpFunc;

typedef struct packed {
    OpClass opClass;
    OpFunc func;
    logic hasDest;
    logic useImmForRs2;
    logic usePcForRs1;
} DecodeControlSignals;

typedef struct packed {
    logic [31:0] pc;
    logic [4:0] archRs1;
    logic [4:0] archRs2;
    logic [4:0] archRd;
    logic [31:0] imm;
    logic rdIsPredetermined; // imm is prederermined rd
    logic rdIsNextPc;
    logic immIsBranchDestination;
    DecodeControlSignals controlSignals;
} DecodeOut;
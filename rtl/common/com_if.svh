// verilator lint_off DECLFILENAME
`ifndef COM_INTERFACE
`define COM_INTERFACE

import com_pkg::*;
// shared interfaces
//
// IF-ID-ICACHE Interface
interface i_cache_if #(
    parameter ADR_WIDTH = 32,
    parameter RETURN_BYTES = 4
);  

    // if-icache-id
    wire [ADR_WIDTH - 1 : 0] address;
    wire req_valid;
    reg [RETURN_BYTES * 8 - 1 : 0] cache_data_out;
    reg [ADR_WIDTH - 1 : 0] cache_adr_out;
    reg data_valid;
    reg cache_miss;

    // if-id
    // branch prediction
    reg [ADR_WIDTH - 1 : 0] predicted_next_adr;
    reg branch_jump;

    // stage ports
    modport fetch(output address, output req_valid, input data_valid, output predicted_next_adr, output branch_jump);
    modport decode(input data_valid, input cache_data_out, input cache_adr_out, input predicted_next_adr, input branch_jump);
    modport i_cache(input address, input req_valid, output cache_data_out, output cache_adr_out, output data_valid, output cache_miss);
endinterface


// ID Interface
interface id1_id2_if #( // @suppress "File contains multiple design units"
    parameter WIDTH = 32,
    parameter ADR_WIDTH = 32
    );
    reg valid;
    reg [WIDTH - 1 : 0] pc;
    decode_instruction_t decoded_instruction;

    // branch prediction
    reg [ADR_WIDTH - 1 : 0] predicted_next_adr;
    reg branch_jump;

    modport decode1(output valid, output pc, output decoded_instruction, output predicted_next_adr, output branch_jump);
    modport decode2(input valid, input pc, input decoded_instruction, input predicted_next_adr, input branch_jump);
endinterface

// ID2-ID3 Interface
interface id2_id3_if #( // @suppress "File contains multiple design units"
    parameter WIDTH = 32,
    parameter ADR_WIDTH = 32
    );
    reg valid;
    reg [WIDTH - 1 : 0] pc;
    decode_instruction_t decoded_instruction;

    // branch prediction
    reg [ADR_WIDTH - 1 : 0] predicted_next_adr;

    modport decode2(output valid, output pc, output decoded_instruction, output predicted_next_adr);
    modport decode3(input valid, input pc, input decoded_instruction, input predicted_next_adr);
endinterface


`endif

// verilator lint_off DECLFILENAME
`ifndef COM_INTERFACE
`define COM_INTERFACE

// shared interfaces
interface i_cache_if #(
    parameter ADR_WIDTH = 64,
    parameter RETURN_BYTES = 16
);
    wire [ADR_WIDTH - 1 : 0] address;
    wire req_valid;
    reg [RETURN_BYTES * 8 - 1 : 0] cache_out;
    reg data_valid;
    reg cache_miss;

    // stage ports
    modport fetch(output address, output req_valid);
    modport predecode(input data_valid, input cache_out);
    modport i_cache(input address, input req_valid, output cache_out, output data_valid, output cache_miss);

    // monitor modport (read only)
    modport monitor(input address, input cache_out, input req_valid, input data_valid, input cache_miss);
endinterface

`endif

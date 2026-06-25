// Generator : SpinalHDL v1.12.3    git head : 591e64062329e5e2e2b81f4d52422948053edb97
// Component : TopLevel
// Git hash  : 028e0759e2fea2df407b098c784bea02f61d20fe

`timescale 1ns/1ps

module TopLevel (
  input  wire          io_stall,
  input  wire          io_flush_valid,
  input  wire [31:0]   io_flush_payload_addr,
  output wire          io_decodeOut_valid,
  output wire [31:0]   io_decodeOut_payload_pc,
  output wire [31:0]   io_decodeOut_payload_mem,
  input  wire          clk,
  input  wire          reset
);

  wire       [31:0]   fetch1_1_io_outToMem_addr;
  wire                fetch1_1_io_outToF2_valid;
  wire       [31:0]   fetch1_1_io_outToF2_payload_pc;
  wire                fetch2_1_io_output_valid;
  wire       [31:0]   fetch2_1_io_output_payload_pc;
  wire       [31:0]   fetch2_1_io_output_payload_mem;
  wire       [31:0]   progMem_1_io_output_mem;
  reg                 f1ToF2_valid;
  reg        [31:0]   f1ToF2_payload_pc;
  reg                 f2ToID1_valid;
  reg        [31:0]   f2ToID1_payload_pc;
  reg        [31:0]   f2ToID1_payload_mem;

  Fetch1 fetch1_1 (
    .io_outToMem_addr      (fetch1_1_io_outToMem_addr[31:0]     ), //o
    .io_outToF2_valid      (fetch1_1_io_outToF2_valid           ), //o
    .io_outToF2_payload_pc (fetch1_1_io_outToF2_payload_pc[31:0]), //o
    .io_flush_valid        (io_flush_valid                      ), //i
    .io_flush_payload_addr (io_flush_payload_addr[31:0]         ), //i
    .io_stall              (io_stall                            ), //i
    .clk                   (clk                                 ), //i
    .reset                 (reset                               )  //i
  );
  Fetch2 fetch2_1 (
    .io_memIn_mem          (progMem_1_io_output_mem[31:0]       ), //i
    .io_f1In_valid         (f1ToF2_valid                        ), //i
    .io_f1In_payload_pc    (f1ToF2_payload_pc[31:0]             ), //i
    .io_output_valid       (fetch2_1_io_output_valid            ), //o
    .io_output_payload_pc  (fetch2_1_io_output_payload_pc[31:0] ), //o
    .io_output_payload_mem (fetch2_1_io_output_payload_mem[31:0])  //o
  );
  ProgMem progMem_1 (
    .io_input_addr (fetch1_1_io_outToMem_addr[31:0]), //i
    .io_output_mem (progMem_1_io_output_mem[31:0]  ), //o
    .clk           (clk                            ), //i
    .reset         (reset                          )  //i
  );
  assign io_decodeOut_valid = f2ToID1_valid;
  assign io_decodeOut_payload_pc = f2ToID1_payload_pc;
  assign io_decodeOut_payload_mem = f2ToID1_payload_mem;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      f1ToF2_valid <= 1'b0;
      f1ToF2_payload_pc <= 32'h0;
      f2ToID1_valid <= 1'b0;
      f2ToID1_payload_pc <= 32'h0;
      f2ToID1_payload_mem <= 32'h0;
    end else begin
      f1ToF2_payload_pc <= fetch1_1_io_outToF2_payload_pc;
      f2ToID1_payload_pc <= fetch2_1_io_output_payload_pc;
      f2ToID1_payload_mem <= fetch2_1_io_output_payload_mem;
      if(io_flush_valid) begin
        f1ToF2_valid <= 1'b0;
        f2ToID1_valid <= 1'b0;
      end else begin
        f1ToF2_valid <= fetch1_1_io_outToF2_valid;
        f2ToID1_valid <= fetch2_1_io_output_valid;
      end
    end
  end


endmodule

module ProgMem (
  input  wire [31:0]   io_input_addr,
  output wire [31:0]   io_output_mem,
  input  wire          clk,
  input  wire          reset
);

  reg        [31:0]   progMem_1_spinal_port0;
  wire                _zz_progMem_1_port;
  wire                _zz_io_output_mem_1;
  wire       [7:0]    _zz_io_output_mem;
  reg [31:0] progMem_1 [0:255];

  assign _zz_io_output_mem_1 = 1'b1;
  initial begin
    $readmemb("TopLevel.v_toplevel_progMem_1_progMem_1.bin",progMem_1);
  end
  always @(posedge clk) begin
    if(_zz_io_output_mem_1) begin
      progMem_1_spinal_port0 <= progMem_1[_zz_io_output_mem];
    end
  end

  assign _zz_io_output_mem = io_input_addr[9 : 2];
  assign io_output_mem = progMem_1_spinal_port0;

endmodule

module Fetch2 (
  input  wire [31:0]   io_memIn_mem,
  input  wire          io_f1In_valid,
  input  wire [31:0]   io_f1In_payload_pc,
  output wire          io_output_valid,
  output wire [31:0]   io_output_payload_pc,
  output wire [31:0]   io_output_payload_mem
);


  assign io_output_valid = io_f1In_valid;
  assign io_output_payload_pc = io_f1In_payload_pc;
  assign io_output_payload_mem = io_memIn_mem;

endmodule

module Fetch1 (
  output wire [31:0]   io_outToMem_addr,
  output reg           io_outToF2_valid,
  output wire [31:0]   io_outToF2_payload_pc,
  input  wire          io_flush_valid,
  input  wire [31:0]   io_flush_payload_addr,
  input  wire          io_stall,
  input  wire          clk,
  input  wire          reset
);

  reg        [31:0]   pc;
  wire                when_Fetch1_l29;

  always @(*) begin
    io_outToF2_valid = 1'b1;
    if(io_flush_valid) begin
      io_outToF2_valid = 1'b0;
    end
  end

  assign io_outToF2_payload_pc = pc;
  assign io_outToMem_addr = pc;
  assign when_Fetch1_l29 = ((! io_stall) && (! io_flush_valid));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      pc <= 32'h0;
    end else begin
      if(when_Fetch1_l29) begin
        pc <= (pc + 32'h00000004);
      end
      if(io_flush_valid) begin
        pc <= io_flush_payload_addr;
      end
    end
  end


endmodule

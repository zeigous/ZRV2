import com_pkg::*;


module Ras #(
    parameter WIDTH = 32
    )(
    input clk,
    input rst,
    input clk_en,

    input flush_t flush,

    input valid,

    input [WIDTH - 1 : 0] pc,
    input [4 : 0] rs1,
    input [4 : 0] rd,

    output [WIDTH - 1 : 0] address_out
);  
    
    reg [WIDTH - 1:0] stack [8];
    reg [2:0] bottom_ptr;

    wire [2:0] next_push_idx = (bottom_ptr < 7) ? bottom_ptr + 1 : bottom_ptr;

    always_ff @(posedge clk) begin
        if (clk_en && !flush.valid && !rst && valid) begin
            if ( (rs1 == 5'h1 || rs1 == 5'h5) && (rd != 5'h1 || rd != 5'h5) ) begin
                bottom_ptr <= (bottom_ptr > 0) ? bottom_ptr - 1 : bottom_ptr;

            end else if ( (rs1 != 5'h1 || rs1 != 5'h5) && (rd == 5'h1 || rd == 5'h5) ) begin
                bottom_ptr <= next_push_idx;
                stack[next_push_idx] <= pc;

            end else if ( (rs1 == 5'h1 || rs1 == 5'h5) && (rd == 5'h1 || rd == 5'h5) && (rd != rs1)) begin
                stack[bottom_ptr] <= pc;

            end else if ( (rs1 == 5'h1 || rs1 == 5'h5) && (rd == 5'h1 || rd == 5'h5) && (rd == rs1)) begin
                bottom_ptr <= next_push_idx;
                stack[next_push_idx] <= pc;
                
            end
        end else if (flush.valid || rst) begin
            bottom_ptr <= '0;
        end
    end
    
    assign address_out = stack[bottom_ptr];
endmodule

`timescale 1 ns / 1 ps

`include "common/com_if.svh"

module testbench;
    // signals
    reg clk;
    reg rst;
    reg clk_en;

    initial begin
        rst = 1;
        clk_en = 0;

        #5 clk_en = 1;
        #10 rst = 0;

        #500
        $display("Finished");
        $finish;
    end

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

endmodule : testbench

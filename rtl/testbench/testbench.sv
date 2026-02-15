`timescale 1 ns / 1 ps

`include "common/com_if.svh"
import com_pkg::*;

module testbench;
    // signals
    reg clk;
    reg rst;
    reg clk_en;

    // signals under test
    flush_t flush = 0;
    logic stall = 0;


    // interfaces   

    // module under test

    /* verilator tracing_off */
    /* verilator tracing_on */
    initial begin
        rst = 1;
        clk_en = 0;

        #5 clk_en = 1;
        #10 rst = 0;

        #100 stall = 1;
        #110 stall = 0;

        #200 flush.valid = 1;
        #210 flush.valid = 0;

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

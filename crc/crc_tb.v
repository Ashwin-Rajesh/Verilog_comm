/*
MIT License

Copyright (c) 2021 Ashwin-Rajesh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

module crc_tb;

    localparam CRC_LEN = 32;
    // Wihtout including MSB, with LSB one
    localparam CRC_POLYNOMIAL = 32'h4C11DB7;

    reg data_in = 1'b0;
    reg clk_in  = 1'b0;
    reg reset   = 1'b0;
    reg enable  = 1'b0;

    wire[CRC_LEN-1:0] crc_out;

    crc #(CRC_LEN, CRC_POLYNOMIAL) DUT (
    .data_in(data_in),
    .clk_in(clk_in),
    .reset(reset),
    .enable(enable),
    .crc_out(crc_out)
    );

    localparam  DATA_LEN = 90;

    reg[DATA_LEN-1:0] data = "ABCFA";

    integer i;

    initial begin
        $dumpfile("crc.vcd");
        $dumpvars(0, crc_tb);

        reset   <= 1'b1;
        #1;
        reset   <= 1'b0;

        // Send data
        for(i = DATA_LEN-1; i >= 0; i = i - 1) @(negedge clk_in) begin
            enable      <= 1'b1;
            data_in     <= data[i];
        end
        // Zero padding
        for(i = 0; i < CRC_LEN; i = i + 1) @(negedge clk_in) begin
            enable      <= 1'b1;
            data_in     <= 1'b0;
        end
        

        @(negedge clk_in)
        enable  <= 1'b0;

        #10 
        $display(" CRC value : %b", crc_out);
        $display(" CRC value : %h", crc_out);
        $finish;
    end

    always #1 clk_in  <= ~clk_in;

endmodule
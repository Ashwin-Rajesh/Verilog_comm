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

module crc(
    input data_in,
    input clk_in,
    input reset,
    input enable,

    output reg [CRC_LEN-1:0] crc_out
);

    parameter CRC_LEN = 16;

    // Does not include the MSB and includes the LSB (which is always one)
    parameter CRC_POLYNOMIAL = 16'h8005;

    always @(reset)
        if(reset)
            crc_out <= 0;

    wire crc_msb = crc_out[CRC_LEN-1];

    wire[CRC_LEN-1:0] crc_gated;
    wire[CRC_LEN-1:0] crc_next;
    
    assign crc_gated = CRC_POLYNOMIAL                   & {CRC_LEN{crc_msb}};

    assign crc_next  = {crc_out[CRC_LEN-2:0], data_in}  ^ crc_gated;

    always @(posedge (clk_in && enable)) begin
        crc_out     <= crc_next;        
    end

endmodule

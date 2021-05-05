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

module spi_tb;

    localparam p_WORD_LEN   = 8;
    localparam p_CLK_DIV    = 10;

    reg r_clk = 0;

    reg[p_WORD_LEN-1:0] r_m_data = 0;
    reg r_m_dv = 0;

    wire w_sclk;
    wire w_mosi;
    wire w_miso;

    reg r_miso = 0;

    wire [p_WORD_LEN-1:0] w_m_data;

    spi_master #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) master_dut(
        .i_clk(r_clk),
        .i_data(r_m_data),
        .i_dv(r_m_dv),
        .i_miso(w_miso),

        .o_sclk(w_sclk),
        .o_mosi(w_mosi),
        .o_active(w_m_active),
        .o_data(w_m_data)
    );

    initial begin
        $dumpfile("spi.vcd");
        $dumpvars(0, spi_tb);
    
        r_m_data <= 8'hEE;

        #10
        r_m_dv      <= 1'b1;
        #5
        r_m_dv      <= 1'b0;
    end

    always #1 r_clk <= ~r_clk;

    initial #1000 $finish;

endmodule;
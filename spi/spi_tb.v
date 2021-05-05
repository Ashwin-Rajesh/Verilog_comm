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

    reg[p_WORD_LEN-1:0]     r_m_idata = 0;
    reg                     r_m_dv = 0;
    wire [p_WORD_LEN-1:0]   w_m_odata;

    // Slave 1 interface
    reg[p_WORD_LEN-1:0]     r_s1_idata = 0;
    reg                     r_s1_idv = 0;
    wire                    w_s1_odv;
    wire[p_WORD_LEN-1:0]    w_s1_odata;

    reg r_s1s = 1;

    // Slave 2 interface
    reg[p_WORD_LEN-1:0]     r_s2_idata = 0;
    reg                     r_s2_idv = 0;
    wire                    w_s2_odv;
    wire[p_WORD_LEN-1:0]    w_s2_odata;

    reg r_s2s = 1;


    wire w_sclk;
    wire w_mosi;
    wire w_miso;


    spi_master #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) master_dut(
        .i_clk(r_clk),
        .i_data(r_m_idata),
        .i_dv(r_m_dv),
        .i_miso(w_miso),

        .o_sclk(w_sclk),
        .o_mosi(w_mosi),
        .o_active(w_m_active),
        .o_data(w_m_odata)
    );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) slave1_dut(
        .i_clk(r_clk),
        .i_data(r_s1_idata),
        .i_dv(r_s1_idv),
        .i_sclk(w_sclk),
        .i_mosi(w_mosi),
        .i_ss(r_s1s),

        .o_miso(w_miso),
        .o_dv(w_s1_odv),
        .o_data(w_s1_odata)
    );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) slave2_dut(
        .i_clk(r_clk),
        .i_data(r_s2_idata),
        .i_dv(r_s2_idv),
        .i_sclk(w_sclk),
        .i_mosi(w_mosi),
        .i_ss(r_s2s),

        .o_miso(w_miso),
        .o_dv(w_s2_odv),
        .o_data(w_s2_odata)
    );

    initial begin
        $dumpfile("spi.vcd");
        $dumpvars(0, spi_tb);

        r_m_idata <= 8'b11110000;
        r_s1_idata <= 8'b01101001;
        r_s2_idata <= 8'b00001111;

        // Latch slave data
        #1
        r_s1_idv     <= 1'b1;
        r_s2_idv     <= 1'b1;
        #5;
        r_s1_idv     <= 1'b0;
        r_s2_idv     <= 1'b0;
        
        // Enable slave 1
        r_s1s        <= 1'b0;
        // Signal to master send data
        #5;
        r_m_dv      <= 1'b1;
        #5
        r_m_dv      <= 1'b0;
        // Disable slave 1
        #300;
        r_s1s        <= 1'b1;

        // Change master input to be master output
        r_m_idata    <= w_m_odata;

        // Enable slave 2
        #5;
        r_s2s        <= 1'b0;
        // Signal to master send data
        #5;
        r_m_dv      <= 1'b1;
        #5
        r_m_dv      <= 1'b0;
        // Disable slave 1
        #300;
        r_s2s        <= 1'b1;
    end

    always #1 r_clk <= ~r_clk;

    initial #1000 $finish;

endmodule;
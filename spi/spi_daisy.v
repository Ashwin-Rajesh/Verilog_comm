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

module spi_daisy;

    localparam p_WORD_LEN   = 8;
    localparam p_CLK_DIV    = 10;

    reg r_clk = 0;

    reg[p_WORD_LEN-1:0]     r_m_idata = 0;
    reg                     r_m_dv = 0;
    wire [p_WORD_LEN-1:0]   w_m_odata;
    wire                    w_m_mosi;
    wire                    w_m_miso;
    wire                    w_m_active;

    // Slave 1 interface
    reg[p_WORD_LEN-1:0]     r_s1_idata = 0;
    reg                     r_s1_idv = 0;
    wire                    w_s1_odv;
    wire[p_WORD_LEN-1:0]    w_s1_odata;
    wire                    w_s1_mosi;
    wire                    w_s1_miso;

    // Slave 2 interface
    reg[p_WORD_LEN-1:0]     r_s2_idata = 0;
    reg                     r_s2_idv = 0;
    wire                    w_s2_odv;
    wire[p_WORD_LEN-1:0]    w_s2_odata;
    wire                    w_s2_mosi;
    wire                    w_s2_miso;

    // Chip select
    reg r_ss = 1;

    wire w_sclk;

    spi_master #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) master_dut(
        .i_clk(r_clk),
        .i_data(r_m_idata),
        .i_dv(r_m_dv),
        .i_miso(w_m_miso),

        .o_sclk(w_sclk),
        .o_mosi(w_m_mosi),
        .o_active(w_m_active),
        .o_data(w_m_odata)
    );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) slave1_dut(
        .i_clk(r_clk),
        .i_data(r_s1_idata),
        .i_dv(r_s1_idv),
        .i_sclk(w_sclk),
        .i_mosi(w_s1_mosi),
        .i_ss(r_ss),

        .o_miso(w_s1_miso),
        .o_dv(w_s1_odv),
        .o_data(w_s1_odata)
    );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) slave2_dut(
        .i_clk(r_clk),
        .i_data(r_s2_idata),
        .i_dv(r_s2_idv),
        .i_sclk(w_sclk),
        .i_mosi(w_s2_mosi),
        .i_ss(r_ss),

        .o_miso(w_s2_miso),
        .o_dv(w_s2_odv),
        .o_data(w_s2_odata)
    );


    assign w_s1_mosi = w_m_mosi;

    assign w_s2_mosi = w_s1_miso;

    assign w_m_miso  = w_s2_miso;

    initial begin
        $dumpfile("spi_daisy.vcd");
        $dumpvars(0, spi_daisy);
        
        r_s1_idata  <= 8'b00000000;
        r_s2_idata  <= 8'b01010101;

        // Latch data from both slaves
        #1
        r_s1_idv    <= 1'b1;
        r_s2_idv    <= 1'b1;
        #5
        r_s1_idv    <= 1'b0;
        r_s2_idv    <= 1'b0;

        // Enable both slaves
        #5
        r_ss        <= 1'b0;
        // Signal master to send first word
        #5
        r_m_idata   <= 8'b10101010;
        #5
        r_m_dv      <= 1'b1;
        #5
        r_m_dv      <= 1'b0;
        
        // Wait for master to finish sending first word
        @(negedge w_m_active) #10

        // Signal master to send second word
        #5
        r_m_idata   <= 8'b11111111;
        #5
        r_m_dv      <= 1'b1;
        #5
        r_m_dv      <= 1'b0;

        // Wait for master to finish sending second word
        @(negedge w_m_active) #10

        // Disable slaves
        r_ss        <= 1'b1;

    end

    always #1 r_clk <= ~r_clk;

    initial #1000 $finish;

endmodule;
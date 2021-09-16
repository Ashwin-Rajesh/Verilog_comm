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

`timescale 1ns/1ns

module spi_daisy;

    localparam p_WORD_LEN   = 8;
    localparam p_CLK_DIV    = 10;

    // reg r_clk = 0;

    // reg[p_WORD_LEN-1:0]     r_m_idata = 0;
    // reg                     r_m_dv = 0;
    // wire [p_WORD_LEN-1:0]   w_m_odata;
    // wire                    w_m_mosi;
    // wire                    w_m_miso;
    // wire                    w_m_active;

    // // Slave 1 interface
    // reg[p_WORD_LEN-1:0]     r_s1_idata = 0;
    // reg                     r_s1_idv = 0;
    // wire                    w_s1_odv;
    // wire[p_WORD_LEN-1:0]    w_s1_odata;
    // wire                    w_s1_mosi;
    // wire                    w_s1_miso;

    // // Slave 2 interface
    // reg[p_WORD_LEN-1:0]     r_s2_idata = 0;
    // reg                     r_s2_idv = 0;
    // wire                    w_s2_odv;
    // wire[p_WORD_LEN-1:0]    w_s2_odata;
    // wire                    w_s2_mosi;
    // wire                    w_s2_miso;

    // // Chip select
    // reg r_ss = 1;

    // wire w_sclk;

    reg r_clk = 0;
    
    // SPI interface signals
    wire w_sclk;
    wire w_master_mosi;
    wire w_master_miso;

    wire w_slave1_mosi;
    wire w_slave1_miso;

    wire w_slave2_mosi;
    wire w_slave2_miso;

    // Both slaves use same slave select
    reg r_ss = 1'b1;

    // Master inp interface
    reg[p_WORD_LEN-1:0]     r_master_inp_data   = 0;
    reg                     r_master_inp_en     = 0;
    wire                    w_master_inp_rdy;
    // Master out interface
    wire[p_WORD_LEN-1:0]    w_master_out_data;
    wire                    w_master_out_rdy;

    // Slave 1 inp interface
    reg[p_WORD_LEN-1:0]     r_slave1_inp_data   = 0;
    reg                     r_slave1_inp_en     = 0;
    wire                    w_slave1_inp_rdy;
    // Slave 1 out interface
    wire[p_WORD_LEN-1:0]    w_slave1_out_data;
    wire                    w_slave1_out_rdy;

    // Slave 2 inp interface
    reg[p_WORD_LEN-1:0]     r_slave2_inp_data   = 0;
    reg                     r_slave2_inp_en     = 0;
    wire                    w_slave2_inp_rdy;
    // Slave 2 out interface
    wire[p_WORD_LEN-1:0]    w_slave2_out_data;
    wire                    w_slave2_out_rdy;

    spi_master #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) master_dut(
        // General signals
        .i_clk      (r_clk),
        .i_miso     (w_master_miso),
        .o_sclk     (w_sclk),
        .o_mosi     (w_master_mosi),

        // Input method
        .inp_data   (r_master_inp_data),
        .inp_en     (r_master_inp_en),
        .inp_rdy    (w_master_inp_rdy),

        // Output method
        .out_data   (w_master_out_data),
        .out_rdy    (w_master_out_rdy)
    );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN)) slave1_dut(
        // General signals
        .i_clk      (r_clk),
        .i_sclk     (w_sclk),
        .i_mosi     (w_slave1_mosi),
        .i_ss       (r_ss),
        .o_miso     (w_slave1_miso),

        // Input method
        .inp_data   (r_slave1_inp_data),
        .inp_en     (r_slave1_inp_en),
        .inp_rdy    (w_slave1_inp_rdy),

        // Output method
        .out_data   (w_slave1_out_data),
        .out_rdy    (w_slave1_out_rdy)
    );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN)) slave2_dut(
        // General signals
        .i_clk      (r_clk),
        .i_sclk     (w_sclk),
        .i_mosi     (w_slave2_mosi),
        .i_ss       (r_ss),
        .o_miso     (w_slave2_miso),

        // Input method
        .inp_data   (r_slave2_inp_data),
        .inp_en     (r_slave2_inp_en),
        .inp_rdy    (w_slave2_inp_rdy),

        // Output method
        .out_data   (w_slave2_out_data),
        .out_rdy    (w_slave2_out_rdy)
    );

    assign w_slave1_mosi = w_master_mosi;

    assign w_slave2_mosi = w_slave1_miso;

    assign w_master_miso = w_slave2_miso;

    initial begin
        $dumpfile("spi_daisy.vcd");
        $dumpvars(0, spi_daisy);
        
        r_slave1_inp_data  <= 8'b00000000;
        r_slave2_inp_data  <= 8'b01010101;
        r_master_inp_data  <= 8'b10101010;

        // Latch slave data
        #1
        r_slave1_inp_en <= 1'b1;
        r_slave2_inp_en <= 1'b1;
        #5
        r_slave1_inp_en <= 1'b0;
        r_slave2_inp_en <= 1'b0;

        // Enable both slaves
        #5
        r_ss                <= 1'b0;

        // Signal master to send first word
        #5
        r_master_inp_en     <= 1'b1;
        @(negedge w_master_inp_rdy)
        r_master_inp_en     <= 1'b0;
        
        // Wait for master to finish sending first word
        @(posedge w_master_inp_rdy) #10

        // Second word
        #5
        r_master_inp_data   <= 8'b11111111;

        // Signal master to send first word
        #5
        r_master_inp_en     <= 1'b1;
        @(negedge w_master_inp_rdy)
        r_master_inp_en     <= 1'b0;

        // Wait for master to finish sending second word
        @(posedge w_master_inp_rdy) #10

        // Disable slaves
        r_ss        <= 1'b1;

    end

    always #1 r_clk <= ~r_clk;

    initial #1000 $finish;

endmodule;
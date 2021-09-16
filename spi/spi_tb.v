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

module spi_tb;

    localparam p_WORD_LEN   = 8;
    localparam p_CLK_DIV    = 10;

    reg r_clk = 0;
    
    // SPI interface signals
    wire w_sclk;
    wire w_mosi;
    wire w_miso;

    // Master inp interface
    reg[p_WORD_LEN-1:0]     r_master_inp_data   = 0;
    reg                     r_master_inp_en     = 0;
    wire                    w_master_inp_rdy;
    // Master out interface
    wire[p_WORD_LEN-1:0]    w_master_out_data;
    wire                    w_master_out_rdy;

    // Slave select signals
    reg r_s1s = 1;
    reg r_s2s = 1;

    // Slave 1 inp interface
    reg[p_WORD_LEN-1:0]     r_slave1_inp_data   = 0;
    reg                     r_slave1_inp_en     = 0;
    wire                    w_slave1_inp_rdy;
    // Slave 1 out interface
    wire[p_WORD_LEN-1:0]    w_slave1_out_data;
    wire                    w_slave1_out_rdy;

    // Slave 2 inp interface
    reg[p_WORD_LEN-1:0]     r_slave2_inp_data = 0;
    reg                     r_slave2_inp_en     = 0;
    wire                    w_slave2_inp_rdy;
    // Slave 2 out interface
    wire[p_WORD_LEN-1:0]    w_slave2_out_data;
    wire                    w_slave2_out_rdy;

    spi_master #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) master_dut(
        // General signals
        .i_clk      (r_clk),
        .i_miso     (w_miso),
        .o_sclk     (w_sclk),
        .o_mosi     (w_mosi),

        // Input method
        .inp_data   (r_master_inp_data),
        .inp_en     (r_master_inp_en),
        .inp_rdy    (w_master_inp_rdy),

        // Output method
        .out_data   (w_master_out_data),
        .out_rdy    (w_master_out_rdy)
    );

    // spi_master #(.p_WORD_LEN(p_WORD_LEN), .p_CLK_DIV(p_CLK_DIV)) master_dut(
    //     .i_clk(r_clk),
    //     .i_data(r_master_inp_data),
    //     .i_dv(r_m_dv),
    //     .i_miso(w_miso),

    //     .o_sclk(w_sclk),
    //     .o_mosi(w_mosi),
    //     .o_active(w_m_active),
    //     .o_data(w_master_out_data)
    // );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN)) slave1_dut(
        // General signals
        .i_clk      (r_clk),
        .i_sclk     (w_sclk),
        .i_mosi     (w_mosi),
        .i_ss       (r_s1s),
        .o_miso     (w_miso),

        // Input method
        .inp_data   (r_slave1_inp_data),
        .inp_en     (r_slave1_inp_en),
        .inp_rdy    (w_slave1_inp_rdy),

        // Output method
        .out_data   (w_slave1_out_data),
        .out_rdy    (w_slave1_out_rdy)
    );

    // spi_slave #(.p_WORD_LEN(p_WORD_LEN)) slave1_dut(
    //     .i_clk(r_clk),
    //     .i_data(r_slave1_inp_data),
    //     .i_dv(r_s1_idv),
    //     .i_sclk(w_sclk),
    //     .i_mosi(w_mosi),
    //     .i_ss(r_s1s),

    //     .o_miso(w_miso),
    //     .o_dv(w_s1_odv),
    //     .o_data(w_slave1_out_data)
    // );

    spi_slave #(.p_WORD_LEN(p_WORD_LEN)) slave2_dut(
        // General signals
        .i_clk      (r_clk),
        .i_sclk     (w_sclk),
        .i_mosi     (w_mosi),
        .i_ss       (r_s2s),
        .o_miso     (w_miso),

        // Input method
        .inp_data   (r_slave2_inp_data),
        .inp_en     (r_slave2_inp_en),
        .inp_rdy    (w_slave2_inp_rdy),

        // Output method
        .out_data   (w_slave2_out_data),
        .out_rdy    (w_slave2_out_rdy)
    );

    // spi_slave #(.p_WORD_LEN(p_WORD_LEN)) slave2_dut(
    //     .i_clk(r_clk),
    //     .i_data(r_slave2_inp_data),
    //     .i_dv(r_s2_idv),
    //     .i_sclk(w_sclk),
    //     .i_mosi(w_mosi),
    //     .i_ss(r_s2s),

    //     .o_miso(w_miso),
    //     .o_dv(w_s2_odv),
    //     .o_data(w_slave2_out_data)
    // );

    initial begin
        $dumpfile("spi.vcd");
        $dumpvars(0, spi_tb);

        r_master_inp_data <= 8'b11110000;
        r_slave1_inp_data <= 8'b01101001;
        r_slave2_inp_data <= 8'b00001111;

        // Latch slave data
        #1
        r_slave1_inp_en <= 1'b1;
        r_slave2_inp_en <= 1'b1;
        #5
        r_slave1_inp_en <= 1'b0;
        r_slave2_inp_en <= 1'b0;

        // Enable slave 1
        r_s1s        <= 1'b0;

        // Signal to master send data
        #5
        r_master_inp_en <= 1'b1;
        @(negedge w_master_inp_rdy) r_master_inp_en <= 1'b0;

        // Disable slave 2
        @(posedge w_master_inp_rdy) #5;
        r_s1s        <= 1'b1;

        // Get next master input data from its current output
        r_master_inp_data    <= w_master_out_data;

        #5;
        // Enable slave 2
        r_s2s        <= 1'b0;

        // Signal to master send data
        #5
        r_master_inp_en <= 1'b1;
        @(negedge w_master_inp_rdy) r_master_inp_en <= 1'b0;

        // Disable slave 2
        @(posedge w_master_inp_rdy) #5;
        r_s2s        <= 1'b1;
    end

    always #1 r_clk <= ~r_clk;

    initial #10000 $finish;

endmodule;
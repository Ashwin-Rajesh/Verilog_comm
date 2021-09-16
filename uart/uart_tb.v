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

`timescale 1us/1us

// `include "uart_rx_v2.v"
// `include "uart_tx_v2.v"

module uart_tb;

    wire    w_signal;
    reg     r_clk           = 0;
    
    reg[7:0]    r_tx_data   = 0;
    wire[7:0]   w_rx_data;

    wire w_tx_done;
    wire w_tx_ready;
    wire w_rx_ready;
    reg  r_tx_send          = 0;

    // The clock generated is 0.5GHz
    // To get 9600Hz baud rate,
    // p_CLK_DIV = 0.5MHz/9.6MHz = 52.08
    localparam p_CLK_DIV = 52;

    uart_tx #(.p_CLK_DIV(p_CLK_DIV), .p_WORD_LEN(8)) tx_dut (        
        .i_clk(r_clk),
        .o_tx(w_signal),       // Output UART signal

        // Send enable , data and ready
        .i_send_en(r_tx_send),
        .i_send_data(r_tx_data),
        .o_send_rdy(w_tx_ready)
    );

    uart_rx #(.p_CLK_DIV(p_CLK_DIV), .p_WORD_LEN(8)) rx_dut (
        .i_clk(r_clk),
        .i_rx(w_signal),        // Input UART signal

        // Receive enable, data and ready
        .o_receive_data(w_rx_data),
        .o_receive_rdy(w_rx_ready)    
    );

    localparam p_STR_LEN = 15;

    reg[8*p_STR_LEN-1:0] r_input_string = "Hello world";

    integer r_stridx = 0;

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);        

        #1000;

        for(r_stridx = 0; r_stridx < p_STR_LEN; r_stridx = r_stridx + 1) begin
            #1  r_tx_send <= 1'b1;
            #2  r_tx_send <= 1'b0;

            @(posedge w_tx_ready) #10
            r_tx_data     <= r_input_string[r_stridx * 8 +: 8];
            #1000;
        end

        #100 $finish;
    end
    
    always #1 r_clk = ~r_clk;
endmodule;

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

`include "uart_rx.v"
`include "uart_tx.v"

'`timescale 1ns, 100ps

module uart_tb:

    wire    w_signal;
    reg     r_clk;
    
    reg[7:0]    r_tx_data;
    wire[7:0]   w_rx_data;

    wire w_tx_done;
    wire w_tx_active;
    wire w_rx_dv;
    reg  r_tx_dv;

    uart_tx tx_dut #(.p_CLK_DIV(104), .p_WORD_LEN(8)) (
        .i_clk(r_clk),
        .i_dv(r_tx_dv),
        .i_data(r_tx_data),
        
        .o_tx(w_signal),
        .o_done(w_tx_done),
        .o_active(w_tx_active)
    );

    uart_rx rx_dut #(.p_CLK_DIV(104), .p_WORD_LEN(8)) (
        .i_clk(r_clk),
        .i_rx(w_signal),

        .o_data(w_rx_data),
        .o_dv(w_rx_dv)
    );

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);
    end

    always #0.5 r_clk = ~r_clk;
endmodule;

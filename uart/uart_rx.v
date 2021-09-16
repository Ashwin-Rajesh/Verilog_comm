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

// Rx module for UART

// Paramters : 
// p_CLK_DIV    : Clock divider ratio = Internal freq / Baud rate
// p_WORD_LEN   : Number of data bits sent (including parity)

// Inputs :
// i_clk    : Clock signal
// i_rx     : Input rx line

// Receive method - Ready is asserted when data is available to read.
// o_receive_rdy    : Is it ready?
// o_receive_data   : Received data

module uart_rx
(
    input           i_clk,
    input           i_rx,

    // Receive enable, data and ready
    output reg [p_WORD_LEN-1:0] 
                    o_receive_data          = 0,
    output reg      o_receive_rdy           = 0
);
    parameter
        p_CLK_DIV  = 104,
        p_WORD_LEN = 8;
    
    localparam 
        p_WORD_WIDTH = $clog2(p_WORD_LEN+1),
        p_CLK_WIDTH  = $clog2(p_CLK_DIV+1);

    // Latches from i_data
    reg[p_WORD_LEN-1:0]   r_data = 0;            

    // Store clock count (for synchronization)
    reg[p_CLK_WIDTH-1:0]  r_clk_count = 0;       
    // Store bit currently being received
    reg[p_WORD_WIDTH-1:0] r_bit_count = 0;       
    
    // Store state machine state
    reg[2:0]            r_status = 0;          

    // Paramters for state machine states
    localparam 
        s_IDLE    = 3'b000,
        s_START   = 3'b001,
        s_DATA    = 3'b010,
        s_STOP    = 3'b011,
        s_RESTART = 3'b100;

    always @(posedge i_clk) begin
        case(r_status)
            s_IDLE: begin
                o_receive_rdy  <= 1'b1;
                r_clk_count <= 0;
                r_bit_count <= 0;

                if(i_rx == 1'b0) begin
                    o_receive_rdy   <= 1'b0;
                    r_status        <= s_START;
                end else
                    r_status        <= s_IDLE;
            end
            
            // Check after half period for low
            s_START: begin                
                if(r_clk_count < p_CLK_DIV/2 - 1) begin
                    r_clk_count <= r_clk_count + 1;
                    r_status    <= s_START;
                end     
                else begin
                    if(i_rx == 1'b0) begin
                        r_clk_count <= 0;
                        r_status    <= s_DATA;
                    end
                    else 
                        r_status    <= s_IDLE;
                end
            end

            // Receive data bits
            s_DATA: begin
                if(r_clk_count < p_CLK_DIV - 1) begin
                    r_clk_count <= r_clk_count + 1;
                    r_status    <= s_DATA;
                end
                else begin
                    r_clk_count <= 0;
                    
                    if(r_bit_count < p_WORD_LEN) begin
                        r_data[r_bit_count] <= i_rx;
                        r_status    <= s_DATA;
                        r_bit_count <= r_bit_count + 1;
                    end
                    else begin
                        o_receive_data      <= r_data;
                        r_status    <= s_STOP;
                        r_bit_count <= 0;
                    end
                end
            end

            // Send high for one baud period, then restart 
            s_STOP: begin
                if(r_clk_count < p_CLK_DIV) begin
                    r_clk_count <= r_clk_count + 1;
                    r_status    <= s_STOP;
                end
                else begin
                    r_clk_count <= 0;
                    r_status    <= s_RESTART;
                end
            end
            
            // Send o_done for one internal clock cycle
            s_RESTART: begin
                o_receive_rdy  <= 1'b0;
                r_status    <= s_IDLE;
            end
            
            default:
                r_status <= s_IDLE;
        endcase
    end

endmodule

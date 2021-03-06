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

// Tx module for UART

// Paramters : 
// p_CLK_DIV    : Clock divider ratio = Internal freq / Baud rate
// p_WORD_LEN   : Number of data bits sent (including parity)

// Inputs :
// i_clk    : Clock signal
// i_send     : Enable signal (active HIGH)
// i_data   : 9-bit data line

// Outputs :
// o_tx     : Output tx line
// 

module uart_tx
(
    input                   i_clk,
    output reg              o_tx,       // Output signal

    // Send enable , data and ready
    input                   i_send_en,
    input [p_WORD_LEN-1:0]  i_send_data,
    output                  o_send_rdy
);

    parameter 
        p_CLK_DIV  = 104,
        p_WORD_LEN = 8;
    
    localparam 
        p_WORD_WIDTH = $clog2(p_WORD_LEN+1),
        p_CLK_WIDTH  = $clog2(p_CLK_DIV+1);

    // Latches from i_send_data
    reg[p_WORD_LEN-1:0]   r_data = 0;            

    // Store clock count (for synchronization)
    reg[p_CLK_WIDTH-1:0]  r_clk_count = 0;       
    // Store bit currently being sent
    reg[p_WORD_WIDTH-1:0] r_bit_count = 0;       
    
    // Store state machine state
    reg[2:0]            r_status = 0;          

    // Paramters for state machine states
    localparam 
        s_IDLE    = 3'b000,
        s_START   = 3'b001,
        s_DATA    = 3'b010,
        s_STOP    = 3'b011;

    assign o_send_rdy = (r_status == s_IDLE);

    always @(posedge i_clk) begin
        case(r_status)
            s_IDLE: begin
                o_tx        <= 1'b1;

                r_clk_count <= 0;
                r_bit_count <= 0;

                if(i_send_en == 1'b1) begin
                    r_data      <= i_send_data;
                    r_status    <= s_START;
                end
                else
                    r_status    <= s_IDLE;
            end
            
            // Send low for 1 baud period, then send data
            s_START: begin
                o_tx        <= 1'b0;
                
                if(r_clk_count < p_CLK_DIV - 1) begin
                    r_clk_count <= r_clk_count + 1;
                    r_status    <= s_START;
                end     
                else begin
                    r_clk_count <= 0;
                    r_status    <= s_DATA;
                end
            end

            // Send data bits and then move to stop
            s_DATA: begin
                o_tx        <= r_data[r_bit_count];

                if(r_clk_count < p_CLK_DIV - 1) begin
                    r_clk_count <= r_clk_count + 1;
                    r_status    <= s_DATA;
                end  
                else begin
                    r_clk_count <= 0;
                    
                    if(r_bit_count < p_WORD_LEN - 1) begin
                        r_status    <= s_DATA;
                        r_bit_count <= r_bit_count + 1;
                    end
                    else begin
                        r_status    <= s_STOP;
                        r_bit_count <= 0;
                    end
                end   
            end

            // Send high for one baud period, then restart 
            s_STOP: begin
                o_tx        <= 1'b1;

                if(r_clk_count < p_CLK_DIV - 1) begin
                    r_clk_count <= r_clk_count + 1;
                    r_status    <= s_STOP;
                end
                else begin

                    r_clk_count <= 0;
                    r_status    <= s_IDLE;
                end
            end

            default:
                r_status <= s_IDLE;
        endcase
    end

endmodule

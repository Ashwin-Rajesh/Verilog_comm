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

module spi_master(
    // General signals
    input i_clk,
    input i_miso,
    output reg o_sclk                       = 1'b0,
    output reg o_mosi                       = 1'b0,

    // Input method
    input[p_WORD_LEN-1:0] inp_data,
    input inp_en,
    output inp_rdy,

    // Output method
    output reg [p_WORD_LEN-1:0] out_data    = 0,
    output out_rdy
);
    // Parameters
    parameter 
        p_CLK_DIV  = 100,
        p_WORD_LEN = 8;

    // Local parameters
    localparam
        p_BIT_LEN  = $clog2(p_WORD_LEN+1),
        p_CLK_LEN  = $clog2(p_CLK_DIV/2+1);
    
    // State machine states
    localparam 
        s_IDLE = 1'b0,
        s_DATA = 1'b1;

    // Keep count of clock and bits
    reg[p_CLK_LEN-1:0]  r_clk_count = 0;
    reg[p_BIT_LEN-1:0]  r_bit_count = 0;

    // Internal data register and state machine state
    reg[p_WORD_LEN-1:0] r_data      = 0;
    reg                 r_state     = 0;

    // Is the system ready?
    assign out_rdy = (r_state == s_IDLE);
    assign inp_rdy  = (r_state == s_IDLE);

    always @(posedge i_clk) begin
        case(r_state)
        s_IDLE: begin
            // Output the default values
            o_sclk          <= 1'b0;
            r_bit_count     <= 0;
            r_clk_count     <= 0;

            if(inp_en == 1'b1) begin
                r_state         <= s_DATA;
                r_data          <= inp_data;
                o_mosi          <= inp_data[p_WORD_LEN-1];
            end 
            else begin
                r_state         <= s_IDLE;
                o_mosi          <= 1'b0;
            end
        end
        
        s_DATA: begin
            if(r_clk_count < p_CLK_DIV/2 + 1) begin
                r_clk_count     <= r_clk_count + 1;
            end
            else begin
                r_clk_count     <= 0;

                if(r_bit_count < p_WORD_LEN) begin                  
                    if(o_sclk == 1'b1) begin
                        o_sclk      <= 1'b0;
                        o_mosi      <= r_data[p_WORD_LEN-1];
                        r_bit_count <= r_bit_count + 1;
                    end
                    else begin
                        o_sclk      <= 1'b1;
                        r_data      <= {r_data[p_WORD_LEN-2:0], i_miso};
                    end 
                end
                else begin
                    out_data          <= r_data;
                    r_state         <= s_IDLE;
                end
            end
        end

        default: begin
            r_state             <= s_IDLE;
        end 
        endcase
    end

endmodule;

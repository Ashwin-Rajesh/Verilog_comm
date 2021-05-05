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

module spi_slave(
    input i_clk,
    input[p_WORD_LEN-1:0] i_data,
    input i_dv,
    input i_sclk,
    input i_mosi,
    input i_ss,

    output reg o_miso,
    output reg o_dv,
    output reg [p_WORD_LEN-1:0] o_data
);
    // Parameters
    parameter 
        p_WORD_LEN = 8;

    // Local parameters
    localparam
        p_BIT_LEN  = $clog2(p_WORD_LEN+1);
    
    // State machine states
    localparam 
        s_IDLE = 1'b0,
        s_DATA = 1'b1;

    // Store data and state of state machine
    reg[p_WORD_LEN-1:0] r_data      = 0;
    reg                 r_state     = 0;

    // To detect edges
    reg r_prevsclk   = 0;

    always @(posedge i_clk) begin
        case(r_state)
            s_IDLE: begin
                o_dv    <= 1'b0;

                // Latchind data from input port
                if(i_dv == 1'b1) r_data <= i_data;
                
                // If selected, go to s_DATA state and output the MSB
                if(i_ss == 1'b0) begin
                    o_miso      <= r_data[p_WORD_LEN-1]; 
                    r_state     <= s_DATA;   
                end
                // Else, output high impedance state
                else
                    o_miso      <= 1'bz;
            end

            s_DATA: begin
                // If slave select is disabled, change to s_IDLE and
                //      latch the data to output port, and send interrupt
                if(i_ss == 1'b1) begin
                    o_data      <= r_data;
                    o_dv        <= 1'b1;
                    r_state     <= s_IDLE;
                end
                // Else, check for clock edge
                else
                    if(r_prevsclk == ~i_sclk)
                        if(i_sclk == 1'b1) begin
                            // Rising edge - Shift register
                            r_data  <= {r_data[p_WORD_LEN-2:0], i_mosi};
                        end
                        else begin
                            // Falling edge - Output MSB
                            o_miso  <= r_data[p_WORD_LEN-1];
                        end
            end

            default: begin
                r_state     <= s_IDLE;
            end
        endcase

        // Save current clock value
        r_prevsclk    <= i_sclk;
    end

endmodule;

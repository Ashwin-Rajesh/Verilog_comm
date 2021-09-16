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
    // General signals
    input i_clk,
    input i_sclk,
    input i_mosi,
    input i_ss,
    output reg o_miso                       = 1'b0,

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

    // Is the system ready?
    assign inp_rdy = r_state == s_IDLE;
    assign out_rdy = r_state == s_IDLE;

    always @(posedge i_clk) begin
        case(r_state)
            s_IDLE: begin
            
                // Latching data from input port
                if(inp_en == 1'b1) r_data <= inp_data;
                
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
                    out_data    <= r_data;
                    r_state     <= s_IDLE;
                    o_miso      <= 1'bz;
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

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

// FSM to manage input/output and clock transitions. It does not manage ACK/NACK, R/W signals
module i2c_master_fsm (
    // Input signals
    input i_clk,            // High-speed internal clock
    input i_next_state,     // Toggle SCL

    input i_start,          // Start the transaction
    input i_stop,           // Stop the transaction

    // Data r/w interface
    input i_rw,             // HIGH => Read, LOW => Write
    input[7:0] i_input,     // Input (data/address)
    output reg[7:0] o_output,  
                            // Output (data)
    // Error and status signals
    output o_active,
    output o_nextbyte,              // Ready to send or receive next byte
    output reg o_ackerror   = 0,    // Acknowledge error
    output reg o_generror   = 0,    // Some other error    

    // Connection with SCL port
    input i_scl,
    output reg o_scl = 1,

    // Connection with SDA port    reg o_scl;
    input i_sda,
    output reg o_sda = 1
);

    reg r_rw                = 0;

    // Data latched from i_input for read and to be latched to o_rd_data for write
    reg[7:0] r_data         = 0;

    // Registers storing state
    reg[3:0] r_state        = 0;
    reg[2:0] r_bitcount     = 0;

    // Definitions of states
    localparam 
        s_IDLE          = 0,
        s_START         = 1,

        // States for writing byte
        s_W_SCL_HIGH    = 2,
        s_W_SCL_LOW     = 3,
        s_RACK_SCL_LOW  = 4,
        s_RACK_SCL_HIGH = 5,

        // States for reading bytes
        s_R_SCL_HIGH    = 6,
        s_R_SCL_LOW     = 7,
        s_WACK_SCL_LOW  = 8,
        s_WACK_SCL_HIGH = 9,

        s_STOP          = 10;

    // Active => Not idle
    assign o_active         = (r_state != s_IDLE);
    assign o_nextbyte       = (r_state == s_WACK_SCL_HIGH) || (r_state == s_RACK_SCL_HIGH);

    // FSM Moore machine
    always @(posedge i_clk) begin

        if((r_state != s_STOP) && (r_state != s_IDLE) && i_stop) begin
            r_state     <= s_STOP;
        end
        else case (r_state)
            // SDA : HIGH
            // SCL : HIGH
            // Next state : s_START
            s_IDLE      : begin
                o_sda   <= 1'b1;
                o_scl   <= 1'b1;
                
                if(i_start)
                    r_state  <= s_START;
            end

            // SDA : LOW
            // SCL : HIGH
            // Next state : s_W_SCL_LOW
            s_START         : begin
                o_sda       <= 1'b0;
                o_scl       <= 1'b1;
                
                if(i_next_state) begin
                    r_bitcount  <= 0;
                    r_data      <= {i_input[6:0], i_rw};
                    r_rw        <= i_rw;
                    r_state     <= s_W_SCL_LOW;
                end
            end

            // SDA : Data bit
            // SCL : LOW
            // Next state : s_W_SCL_HIGH
            s_W_SCL_LOW     : begin
                o_sda       <= r_data[7-r_bitcount];
                o_scl       <= 1'b0;

                if(i_next_state) begin
                    r_state     <= s_W_SCL_HIGH;
                end
            end

            // SDA : Data bit
            // SCL : HIGH
            // Next state : s_W_SCL_LOW or s_RACK_SCL_LOW for ACK bit
            s_W_SCL_HIGH    : begin
                o_sda       <= r_data[7-r_bitcount];
                o_scl       <= 1'b1;

                if(i_next_state) begin
                    if(r_bitcount == 7) begin
                        r_state     <= s_RACK_SCL_LOW;
                        r_bitcount  <= 0;
                    end else begin
                        r_state     <= s_W_SCL_LOW;
                        r_bitcount  <= r_bitcount + 1;
                    end                        
                end
            end

            // SDA : ACK from slave
            // SCL : LOW
            // Next state : s_RACK_SCL_HIGH
            s_RACK_SCL_LOW  : begin
                o_sda       <= 1'b1;
                o_scl       <= 1'b0;

                if(i_next_state) begin
                    r_state     <= s_RACK_SCL_HIGH;

                end
            end

            // SDA : ACK from slave
            // SCL : HIGH
            // Next state : s_R_SCL_LOW for read and s_W_SCL_LOW for write
            s_RACK_SCL_HIGH  : begin
                o_sda       <= 1'b1;
                o_scl       <= 1'b1;

                // if(i_sda == 1'b1) begin
                //     r_state     <= s_STOP;
                //     o_ackerror  <= 1'b1;
                // end

                if(i_next_state) begin
                    r_bitcount      <= 0;
                    if(r_rw) begin
                        r_data      <= 0;
                        r_state     <= s_R_SCL_LOW;
                    end else begin
                        r_data      <= i_input;
                        r_state     <= s_W_SCL_LOW;
                    end
                end
            end

            // SDA : Data bit from slave
            // SCL : HIGH
            // Next state : s_R_SCL_HIGH
            s_R_SCL_LOW     : begin
                o_sda       <= 1'b1;
                o_scl       <= 1'b0;

                if(i_next_state) begin
                    r_data[7-r_bitcount] <= i_sda;
                    r_state     <= s_R_SCL_HIGH;
                end
            end

            // SDA : Data bit from slave
            // SCL : HIGH
            // Next state : s_R_SCL_LOW or s_WACK_SCL_LOW for ACK bit
            s_R_SCL_HIGH    : begin
                o_sda       <= 1'b1;
                o_scl       <= 1'b1;

                if(i_next_state) begin
                    if(r_bitcount == 7) begin
                        r_state     <= s_WACK_SCL_LOW;
                        r_bitcount  <= 0;
                    end else begin
                        r_state     <= s_R_SCL_LOW;
                        r_bitcount  <= r_bitcount + 1;
                    end                        
                end
            end

            // SDA : LOW (send acknowledge to slave)
            // SCL : LOW
            // Next state : s_WACK_SCL_HIGH
            s_WACK_SCL_LOW  : begin
                o_scl       <= 1'b0;
                o_sda       <= 1'b0;

                if(i_next_state) begin
                    r_state     <= s_WACK_SCL_HIGH;
                end
            end

            // SDA : LOW (ACK to slave)
            // SCL : LOW
            // Next state : s_R_SCL_LOW for read, s_W_SCL_LOW for write
            s_WACK_SCL_HIGH  : begin
                o_scl       <= 1'b1;
                o_sda       <= 1'b0;

                if(i_next_state) begin
                    o_output       <= r_data;
                    if(r_rw)
                        r_state     <= s_R_SCL_LOW;
                    else
                        r_state     <= s_W_SCL_LOW;
                end
            end

            // SDA : LOW
            // SCL : HIGH       (stop is when SDA goes l->h when SCL is high)
            // Next state : s_IDLE
            s_STOP          : begin
                o_scl       <= 1'b1;
                o_sda       <= 1'b0;

                if(i_next_state)
                    r_state         <= s_IDLE;
            end
        endcase
    end

endmodule

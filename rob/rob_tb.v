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

module rob_tb;

    localparam 
        p_WORD_LEN = 16,
        p_PID_LEN  = 4,
        p_ROB_SIZE = 8;

    reg r_clk   = 0;
    reg r_rst   = 0;

    wire[p_PID_LEN-1 : 0]   w_min_pid;
    wire[p_PID_LEN-1 : 0]   w_max_pid;

    reg[p_PID_LEN-1 : 0]    r_reset_pid = 0;

    reg[p_PID_LEN-1:0]      r_inp_pid   = 0;
    reg[p_WORD_LEN-1:0]     r_inp_data  = 0;
    reg                     r_inp_en    = 0;
    wire                    w_inp_ack;
    wire                    w_inp_valid;

    reg[p_PID_LEN-1:0]      r_rand_pid = 0;

    wire[p_WORD_LEN-1:0]    w_out_data;
    wire w_out_valid;
    reg r_out_en                        = 0;

    rob #(.p_WORD_LEN(p_WORD_LEN),
        .p_PID_LEN(p_PID_LEN),
        .p_ROB_SIZE(p_ROB_SIZE)
    ) DUT (
        // Control signals
        .i_clk(r_clk),
        .i_reset(r_rst),
        .i_reset_pid(r_reset_pid),

        // Minimum and maximum packet ID in the ROB
        .o_min_pid(w_min_pid),
        .o_max_pid(w_max_pid),

        // Add a packet
        .i_inp_pid(r_inp_pid),
        .i_inp_data(r_inp_data),
        .i_inp_en(r_inp_en),
        .o_inp_ack(w_inp_ack),
        .o_inp_valid(w_inp_valid),

        // Remove the first packet (PID of this can be found from o_min_pid)
        .o_out_data(w_out_data),
        .i_out_en(r_out_en),
        .o_out_valid(w_out_valid)
    );

    integer i;

    initial begin
        $dumpfile("rob.vcd");
        $dumpvars(0, DUT);

        r_rst   <= 1'b1;
        @(negedge r_clk);
        r_rst   <= 1'b0;

        for(i = 0; i < 6; i = i + 1) begin
            
            // Send data
            while(!w_out_valid) @(negedge r_clk) begin
                r_rand_pid  <= $random;

                r_inp_data  <= r_rand_pid;
                r_inp_pid   <= r_rand_pid;
                r_inp_en    <= 1;
            end
            r_inp_en        <= 0;
            
            // Pop data
            while(w_out_valid) @(negedge r_clk) begin
                r_out_en    <= 1;
            end
            r_out_en        <= 0;

        end

        #10 
        $finish;
    end

    always #1 r_clk  <= ~r_clk;

endmodule

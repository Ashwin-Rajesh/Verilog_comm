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

module rob #(
    parameter p_WORD_LEN    = 8,    // Length of data
    parameter p_PID_LEN     = 8,    // Size of packet ID
    parameter p_ROB_SIZE    = 8     // Give this as max difference expected between packet ids
) (
    // Control signals
    input i_clk,
    input i_reset,
    input[p_PID_LEN-1:0] 
        i_reset_pid,                // The packet ID to start from on reset. If not needed, just ground it

    // Minimum and maximum packet ID in the ROB
    output [p_PID_LEN-1 : 0] 
            o_min_pid,
    output [p_PID_LEN-1 : 0] 
            o_max_pid,

    // Packet input interface
    input[p_PID_LEN-1:0]
                i_inp_pid,          // Packet ID
    input[p_WORD_LEN-1:0]
                i_inp_data,         // Data of the packet
    input       i_inp_en,           // Add the packet
    output reg  o_inp_ack,          // The packet was successfully added
    output reg  o_inp_valid,        // An asynchronous output that can be used to lookup if a packet ID exists in the ROB

    // Remove the first packet (PID of this can be found from o_min_pid)
    output[p_WORD_LEN-1:0]
            o_out_data,         // Data in the packet
    input   i_out_en,           // Remove the packet
    output  o_out_valid         // Is the entry valid? (might not have reached yet) 
);
    // Expected address length required
    localparam 
        p_ROB_ADDR_LEN = $clog2(p_ROB_SIZE);

    // ROB memory
    reg [p_WORD_LEN-1:0]        r_data_mem [p_ROB_SIZE-1:0];
    reg [p_ROB_SIZE-1:0]        r_valid_mem;                // Is the entry here valid?

    // Pointers
    reg [p_PID_LEN-1:0]         r_min_pid = 0;              // Minimum packet ID in the ROB (PID of tail)
    reg [p_ROB_ADDR_LEN:0]      r_tail = 0;                 // Tail index in the ROB (read then increment)    
    reg [p_ROB_ADDR_LEN:0]      r_head = 0;                 // index of max packet ID entry in the ROB

    // Helper signals
    wire w_tail_flag    = r_tail[p_ROB_ADDR_LEN];
    wire w_head_flag    = r_head[p_ROB_ADDR_LEN];
    wire[p_ROB_ADDR_LEN-1 : 0] w_tail_addr    
                        = r_tail[p_ROB_ADDR_LEN-1:0];
    wire[p_ROB_ADDR_LEN-1 : 0] w_head_addr    
                        = r_head[p_ROB_ADDR_LEN-1:0];

    // Size/length of ROB (head - tail)
    reg[p_ROB_ADDR_LEN-1:0] r_size;
    always @(*) begin
        case({w_head_flag, w_tail_flag})
            2'b00   : r_size <= r_head - r_tail;
            2'b01   : r_size <= {1'b1, w_head_addr}
                             - {1'b0, w_tail_addr};
            2'b10   : r_size <= r_head - r_tail;
            2'b11   : r_size <= r_head - r_tail;
        endcase
    end

    assign o_min_pid = r_min_pid;
    assign o_max_pid = r_min_pid + r_size;

    // Helper signal : Memory index corresponding to i_inp_pid
    wire[p_ROB_ADDR_LEN:0] 
        w_inp_idx = r_tail + (i_inp_pid - r_min_pid);
    wire[p_ROB_ADDR_LEN-1:0]
        w_inp_idx_addr = w_inp_idx[p_ROB_ADDR_LEN-1:0];

    // Combinational logic for defining valid signal for i_inp_pid
    always @(*) begin
        // If input PID < current tail PID, it is not in memory and so, not valid
        if(i_inp_pid < r_min_pid || i_inp_pid > o_max_pid) begin
            o_inp_valid <= 0;
        end
        // Else, look it up in memory
        else
            o_inp_valid <= r_valid_mem[w_inp_idx_addr];
    end

    // Empty and full signals
    assign o_empty = (r_tail == r_head);

    // Output data and valid signals are asynchronous
    assign o_out_data  = o_out_valid ? r_data_mem[w_tail_addr] : {p_WORD_LEN{1'b1}};
    assign o_out_valid = r_valid_mem[w_tail_addr];

    // Input is always ready for now
    assign o_inp_rdy   = 1'b1;

    always @(posedge i_clk) begin
        // Synchronous reset
        if(i_reset) begin
            o_inp_ack   <= 0;

            r_min_pid   <= 0;
            r_tail      <= 0;
            r_head      <= 0;
            r_valid_mem <= 0;
            
            r_min_pid   <= i_reset_pid;
        end
        // If not 
        else begin
            if(i_inp_en) begin
                // If input PID < current tail PID, just cant add
                if(i_inp_pid < r_min_pid) begin
                    o_inp_ack   <= 0;
                end
                // If input PID < max PID, add in the middle
                else if(i_inp_pid <= o_max_pid) begin
                    o_inp_ack   <= 1;
                    r_valid_mem[w_inp_idx_addr]
                                <= 1;
                    r_data_mem[w_inp_idx_addr]
                                <= i_inp_data;
                end
                // If input PID > max PID, and it can fit, add and modify head
                else if(i_inp_pid - r_min_pid < p_ROB_SIZE) begin
                    o_inp_ack   <= 1;
                    r_valid_mem[w_inp_idx_addr]
                                <= 1;
                    r_data_mem[w_inp_idx_addr]
                                <= i_inp_data;

                    r_head      <= w_inp_idx;
                end
                // If it cant fit, dont send ack
                else begin
                    o_inp_ack   <= 0;
                end
            end
            // If we are not trying to add, dont acknowledge
            else
                o_inp_ack       <= 0;
            
            // Output from the ROB
            if(i_out_en && o_out_valid) begin
                
                r_valid_mem[w_tail_addr]
                                <= 0;
                r_tail          <= r_tail + 1;
                r_min_pid       <= r_min_pid + 1;
            end
        end
    end
endmodule

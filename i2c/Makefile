# MIT License
#
# Copyright (c) 2021 Ashwin-Rajesh
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Name of project
proj_name 	= i2c

# Source files used
source 		= i2c_master.v i2c_slave.v tristate_port.v i2c_master_fsm.v

# Testbench code
testbench	= $(proj_name)_tb.v

# Result of compilation
object		= $(proj_name).out

# Data file to load to memory
data		= 

# Waveform file
wave		= $(proj_name).vcd

i2c_master_fsm.out : i2c_master_fsm.v tristate_port.v i2c_master_fsm_tb.v
	iverilog i2c_master_fsm_tb.v -o i2c_master_fsm.out

i2c_master_fsm.vcd : i2c_master_fsm.out
	./i2c_master_fsm.out

fsm_test : i2c_master_fsm.vcd
	gtkwave i2c_master_fsm.vcd i2c_master_fsm.gtkw 
.PHONY: fsm_test

i2c_master_fsm_arb.out : i2c_master_fsm.v tristate_port.v i2c_master_fsm_tb_arb.v
	iverilog i2c_master_fsm_tb_arb.v -o i2c_master_fsm_arb.out

i2c_master_fsm_arb.vcd : i2c_master_fsm_arb.out
	./i2c_master_fsm_arb.out

fsm_arb_test : i2c_master_fsm_arb.vcd
	gtkwave i2c_master_fsm_arb.vcd i2c_master_fsm_arb.gtkw 
.PHONY: fsm_test

# Verilog_comm

Implementation of common digital communication protocols in verilog, for use in FPGAs

---

# Index
1) [UART (Universal Asynchronous Receiver/Transmitter)](uart/uart.md)
2) [SPI (Serial Peripheral Interconnect)](spi/spi.md)
3) [CRC (Cyclic redundancy check)](crc/crc.md)
4) [I2C (Inter-IC)](i2c/i2c.md)

---

# Tools used

1) Icarus verilog for compilation
2) GTKwave for visualization
3) Draw.io for flowcharts

---

# Prefix notation

This is the notation used (for the most part) as prefix for identifier names to indicate their type

Prefix | Meaning
:-----:|:-------:
```i_```| Input port
```o_```| Output port
```p_```| Parameter (or localparam)
```r_```| Register
```w_```| Wire
```s_```| State definitions (as localparam)

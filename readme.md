# Verilog blocks

Behavioral verilog implementations of components including peripherals for communication protocols and other components commonly used in design of digital systems. Primarily meant for use in FPGAs

This is mostly a learning exercise for me, for practicing writing and verifying RTL code

---

## Index

#### Peripherals
1) [UART master, slave](uart/uart.md) : Universal Asyncrhnronous Read/Transmit
2) [SPI master, slave](spi/spi.md) : Serial Peripheral Interconnect
3) [I2C master, slave](i2c/i2c.md) : Inter-Integrated Circuit

#### Computation
1) [CRC](crc/crc.md) : Cyclic Redundance Check

#### Memory
1) [FIFO](fifo/fifo.md) : First In First Out
2) [ROB](rob/rob.md) : Re-Order Buffer

---

## Planned

1) Wishbone, AXI wrappers and interfaces for existing peripherals
2) Checksum
3) AES encryption, SHA hashing
4) GPIO
5) NVIC
6) Programmable timer
7) Programmable counter

---

# Prefix notation

This is the notation used (for the most part) as prefix for identifier names to indicate their type

| Prefix | Meaning
| -----|-------
| ```i_```| Input port
| ```o_```| Output port
| ```p_```| Parameter (or localparam)
| ```r_```| Register
| ```w_```| Wire
| ```s_```| State definitions (as localparam)

---

# Tools used

1) Icarus verilog for compilation
2) Makefiles for build automation
3) GTKwave for visualization of waveforms
4) Sigrok, pulseview for protocol decoding (from .vcd files)
5) Draw.io for flowcharts

---

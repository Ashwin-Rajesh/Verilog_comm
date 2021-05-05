# SPI Protocol

# Features

- Synchronous
- Serial
- Full duplex
- Master-slave architecture
- Single master multiple slave

# Popular uses
- For interfacing microcontrollers with sensors or other modules (SD cards, EEPROMs, etc)

# Interface

![](./docs/spi_circuit.png)

- One clock pin
  - ```SCLK```    : Sent by master to slaves
    - Data is sample on the rising edge of clock
- 2 data pins
  - ```MOSI```    : Master Out Slave In
    - MSB first
  - ```MISO```    : Master In Slave Out
    - LSB first
- Select pins for each slave
  - ```SS```      : Slave select (Active ```LOW```)
- Any number of bits can be sent or received - no concept of packets

Often, peripheral devices call MOSI as SDI (Serial Data In) and MISO as SDO (Serial Data Out), and Slave select as CS (Chip Select)

# Protocol

Master In Slave Out
![](./docs/spi_miso.png)

Master Out Slave In
![](./docs/spi_mosi.png)

Both of these can happen simultaneously. 

Quite often (not always), the SPI protocol is implemented using shift registers. For example, MAX5290 DACs have these shift registers. But, ADXL345 accelerometers do not have these.

![](./docs/spi_ringbuff.png)

So, the SPI protocol acts like a ring buffer in this case.

# Multiple slaves and daisy chaining

Using multiple slaves with seperate slave select pins
![SPI multiple slaves](./docs/spi_circuit_multiple_slaves.png)

If we are short on pins, and we know that the slaves use shift register, we can use "daisy chaining" with a single pin.
![SPI daisy chaining](./docs/spi_circuit_daisy_chaining.png)

---


---

# References

1) [CircuitBasics](https://www.circuitbasics.com/basics-of-the-spi-communication-protocol/)
2) [MaximIntegrated](https://www.maximintegrated.com/en/design/technical-documents/app-notes/3/3947.html)
3) [ADXL345 Accelerometer](https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL345.pdf)
4) [MAX5295 DAC](https://datasheets.maximintegrated.com/en/ds/MAX5290-MAX5295.pdf)
5) 
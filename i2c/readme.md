# I2C

## Specification

- Two lines, SDA and SCL
- ```SDA``` : Data
- ```SCL``` : Clock

#### Single master and single slave:
![](docs/i2c_ckt.drawio.svg)

```Master``` : Controls the clock signal and initiates all transactions
```Slave``` : Just responds to the master

#### Waveform
![](docs/i2c_wave.drawio.svg)

#### Multiple slaves
![](docs/i2c_ckt_multislave.drawio.svg)

---

## References

- https://i2c.info/i2c-bus-specification
- https://www.nxp.com/docs/en/application-note/AN10216.pdf
- 

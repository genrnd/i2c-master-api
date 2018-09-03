Tiny TCL API for Intel Avalon-MM i2c master
-------------------------------------------

Small API for Intel Avalon-MM I2C Master core allows to work with core via
system-console. System-console is the tool distributed with Intel Quartus Prime
software package.

Basically, API was created for control of i2c expander (TCA9534), which is used
in Intel Cyclone 10GX FPGA Kit for controlling of SFP+ signals. FPGA can't
transmit something to optics via SFP+ until TX_DISABLE signal become 0 (it
default to 1).

We found that Intel provides Intel Avalon-MM I2C Master Core in Platform
Designer (also the tool from Quartus package), but does not provide any API for
it.

Features:

  * written in TCL
  * natively requires JTAG connection but can be used with any backend
  * uses busy-waiting to check for busy/ready bits
  * tested on Intel Cyclone 10GX FPGA Kit
  * tested with F=156.25 MHz
  * do not support interrupts 

Two function should be implemented to provide backend for API:

  * iord: to write one byte to the core
  * iowr: to read one byte from the core

There are two ready-to-use backends implemented:

  * system-console: iowr() calls master_write_32(), iord() calls
                    master_read_32()
  * debug: iowr() prints data to stdout, iord() returns constant and prints
           address to stdout 

API contents:

  * intel-i2c-api.tcl: API functions
  * intel-i2c-regs.tcl: Intel I2C Master Core registers definition
  * intel-i2c-test.tcl: test script which calls API functions and can be used
                        to debug API 
  * intel-i2c-debug-io.tcl: dummy debug I/O functions which just print to stdout 
  * intel-i2c-syscon-io.tcl: functions accessing i2c master via system-console.
                             Assuming that i2c master core is connected via JTAG 
                             Avalon-MM Bridge

Can be used as example:

  * tca9534.tcl: i2c expander API. Allows to set/clear/read expanders GPIO
  * c10gxkit-sfp.tcl: functions for controlling of SFP+ signals in Intel
                      Cyclone 10GX FPGA Kit
  * c10gxkit-init.tcl: script which performs initialization of SFP+ signals.
                       Written for Intel Cyclone 10GX FPGA Kit

Links
=====

  * https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ug/ug_embedded_ip.pdf, chapter 12: Intel FPGA Avalon-MM I2C Master Core
  * http://www.ti.com/lit/ds/symlink/tca9534.pdf: TCA9534 expander

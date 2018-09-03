#############################################################
# API implements algorithm described in programming model in
# Intel Avalon I2C Master datasheed.
#
# See Figure 43, 
# https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/ug/ug_embedded_ip.pdf, chapter 12
# 
##############################################################

set top_dir $::env(SYSTEM_CONSOLE_TOPDIR_PATH)

# registers and bits definitions
source $top_dir/i2c/intel-i2c-regs.tcl

# input/output functions
source $top_dir/i2c/intel-i2c-wrapped-io.tcl

##############################################################
# Return codes
##############################################################
set I2C_ACK 0
set I2C_NOACK 1

###############################################################
# I/O wrapper functions. They convert register addresses into
# 32-bit address space
#
# intel_i2c_iowr
# intel_i2c_iord
###############################################################

proc intel_i2c_iowr { base reg value } {
  iowr $base [ expr { $reg * 4 } ] $value
}

proc intel_i2c_iord { base reg } {
  return [ iord $base [ expr { $reg * 4 } ] ]
}

#####################################################################
# i2c_init
#            This function inititlizes timings for the scl/sda
#            and then enables the core. This must be run before
#            any other i2c code is executed
#inputs
#      base = the base address of the component
#      clk = frequency of the clock driving this component  ( in Hz)
#      speed = SCL speed ie 100K, 400K ...            (in Hz)
#####################################################################

proc intel_i2c_init { base clk speed } {
  global INTEL_I2C_CTRL
  global INTEL_I2C_ISR 
  global INTEL_I2C_CTRL_EN_MSK 
  global INTEL_I2C_SCL_LOW 
  global INTEL_I2C_SCL_HIGH
  global INTEL_I2C_SDA_HOLD

  set scl_low [ expr int ( $clk / ( 2 * $speed ) ) ]
  set scl_high $scl_low
  set sda_hold [ expr { $scl_low * 2 } ]

  # turn off the core
  intel_i2c_iowr $base $INTEL_I2C_CTRL 0x0 

  # clear status register
  intel_i2c_iowr $base $INTEL_I2C_ISR [ intel_i2c_iord $base $INTEL_I2C_ISR ]

  # initialize timings
  intel_i2c_iowr $base $INTEL_I2C_SCL_LOW  $scl_low 
  intel_i2c_iowr $base $INTEL_I2C_SCL_HIGH $scl_high 
  intel_i2c_iowr $base $INTEL_I2C_SDA_HOLD 1
  #intel_i2c_iowr $base $INTEL_I2C_SDA_HOLD $sda_hold

  # turn on the core
  intel_i2c_iowr $base $INTEL_I2C_CTRL $INTEL_I2C_CTRL_EN_MSK 
}

######################################################################
# i2c_wait_tx_ready
#      Waits for transmitter readiness. Monitors TX_READY bit 
#      in status register
# 
# inputs
#      base = the base address of the component
######################################################################
proc i2c_wait_tx_ready { base } {
  global INTEL_I2C_ISR
  global INTEL_I2C_ISR_TX_READY_MSK

  set ready 0
  while { $ready == 0 } {
    set sr [ intel_i2c_iord $base $INTEL_I2C_ISR ]
    set ready [ expr { $sr & $INTEL_I2C_ISR_TX_READY_MSK } ]
  
    # add sleep here if you need, like this:
    # exec sleep 0.1
  }
}

######################################################################
# i2c_wait_rx_ready
#      Waits for receiver readiness. Monitors RX_READY bit 
#      in status register
# 
# inputs
#      base = the base address of the component
######################################################################
proc i2c_wait_rx_ready { base } {
  global INTEL_I2C_ISR
  global INTEL_I2C_ISR_RX_READY_MSK

  set ready 0
  while { $ready == 0 } {
    set sr [ intel_i2c_iord $base $INTEL_I2C_ISR ]
    set ready [ expr { $sr & $INTEL_I2C_ISR_RX_READY_MSK } ]
  
    # add sleep here if you need, like this:
    # exec sleep 0.1
  }
}

######################################################################
# intel_i2c_start
#             Sets the start bit and then sends the first byte which
#             is the address of the device + the write bit.
# inputs
#       base = the base address of the component
#       add = address of I2C device
#       rd =  1== read    0== write
# return value
#        0(I2C_ACK)  if address is acknowledged
#        1(I2C_NACK) if address was not acknowledged
##########################################################################
proc intel_i2c_start { base add rd } {
  global INTEL_I2C_TFR_CMD
  global INTEL_I2C_TFR_CMD_STA_MSK
  global INTEL_I2C_ISR
  global INTEL_I2C_ISR_NACK_MSK
  global I2C_NOACK
  global I2C_ACK

  # wait for transmitter
  i2c_wait_tx_ready $base

  # address shifted by one and the read/write bit
  set addr_rd [ expr { ( $add << 1 ) + ( 0x1 & $rd ) } ]

  # set start bit which will start the transaction
  intel_i2c_iowr $base $INTEL_I2C_TFR_CMD [ expr { $INTEL_I2C_TFR_CMD_STA_MSK | $addr_rd } ]
  
  set sr  [ intel_i2c_iord $base $INTEL_I2C_ISR ]
  set nack [ expr { $sr & $INTEL_I2C_ISR_NACK_MSK } ]

  if { $nack != 0 } {
    return $I2C_NOACK
  } else {
    return $I2C_ACK
  }
}

#######################################################################
# int intel_i2c_read
#      assumes that any addressing and start has already been done.
#      reads one byte of data from the slave. 
# inputs
#      base = the base address of the component
#      last = on the last read there must not be a ack
#
# return value
#      byte read back.
#######################################################################
proc intel_i2c_read { base last } {
  global INTEL_I2C_TFR_CMD_STO_MSK
  global INTEL_I2C_TFR_CMD
  global INTEL_I2C_RX_DATA

  if { $last } {
    # start a read and stop bit
    set mask [ expr { $INTEL_I2C_TFR_CMD_STO_MSK } ] 
    intel_i2c_iowr $base $INTEL_I2C_TFR_CMD $mask
  } else {
    # start read
    intel_i2c_iowr $base $INTEL_I2C_TFR_CMD 0x0
  }

  # wait for data reception
  i2c_wait_rx_ready $base

  return [ intel_i2c_iord $base $INTEL_I2C_RX_DATA ]
}

##################################################################
# int intel_i2c_write
#            assumes that any addressing and start
#            has already been done.
#            writes one byte of data to the slave.  
#            If last is set the stop bit set.
# inputs
#      base = the base address of the component
#      data = byte to write
#      last = on the last read there must not be a ack
#
# return value
#       0(I2C_ACK) if acknowledged
#       1(I2C_NACK) if not acknowledged
####################################################################
proc intel_i2c_write { base  data last } {
  global INTEL_I2C_TFR_CMD 
  global INTEL_I2C_TFR_CMD_STO_MSK 
  global INTEL_I2C_ISR
  global INTEL_I2C_ISR_NACK_MSK
  global I2C_NOACK 
  global I2C_ACK

  i2c_wait_tx_ready $base

  if { $last } {
    # start write and stop bit
    intel_i2c_iowr $base $INTEL_I2C_TFR_CMD [ expr { $data | $INTEL_I2C_TFR_CMD_STO_MSK } ] 
  } else {
    intel_i2c_iowr $base $INTEL_I2C_TFR_CMD $data
  }

  set sr  [ intel_i2c_iord $base $INTEL_I2C_ISR ]
  set nack [ expr { $sr & $INTEL_I2C_ISR_NACK_MSK } ]

  if { $nack != 0 } {
    return $I2C_NOACK
  } else {
    return $I2C_ACK
  }
}


######################################################
# I2C expander functions. Compatible with TI TCA9534 #
######################################################

set top_dir $::env(SYSTEM_CONSOLE_TOPDIR_PATH)

source $top_dir/i2c/intel-i2c-api.tcl

# i2c address
set TCA9534_ADDR       0x20

# TCA9534 registers
set TCA9534_INP_PORT   0
set TCA9534_OUT_PORT   1
set TCA9534_POL_INV    2 
set TCA9534_CONFIG     3

###########################################################
# expander_write 
#      Writes data byte to specified register
#
# input 
#      base = base address for accessing of i2c subsystem
#      reg = register address
#      data = data to be written 
###########################################################
proc expander_write { base reg data } {
  global TCA9534_ADDR

  intel_i2c_start $base $TCA9534_ADDR 0  
  intel_i2c_write $base $reg 0 
  intel_i2c_write $base $data 1
} 

###########################################################
# expander_read  
#      Reads data byte from specified register
#
# input 
#      base = base address for accessing of i2c subsystem
#      reg = register address
#
# return
#      byte read from expander
###########################################################
proc expander_read { base reg } {
  global TCA9534_ADDR

  # write register address only
  intel_i2c_start $base $TCA9534_ADDR 0  
  intel_i2c_write $base $reg 1 

  # read data with separate transaction
  intel_i2c_start $base $TCA9534_ADDR 1  
  return [ intel_i2c_read $base 1 ]
} 


###########################################################
# expander_set_bit
#      Set or clear bit in register 
#
# input 
#      base = base address for accessing of i2c subsystem
#      reg = register address
#      bit = bit number (0..7)
#      value = non-zero - set bit, 0 - clear bit
#
# return
#      byte read from expander
###########################################################
proc expander_set_bit { base reg bit value } {
  set data [ expander_read $base $reg ]
  set bitmask [ expr { 1 << $bit } ]
  if { $value } {
    set data [ expr { $data | $bitmask } ] 
  } else {
    set data [ expr { $data & ~$bitmask } ]
  }

  expander_write $base $reg $data
}

#####################################################################
# expander_rd_inp_port
#      Reads input port register. Each bit in byte represents
#      corresponding input pin value. 
#
# input 
#      base = base address for accessing of i2c subsystem
#
# return 
#      byte representing input pins values
######################################################################
proc expander_rd_inp_port { base } {
  global TCA9534_INP_PORT
  return [ expander_read $base $TCA9534_INP_PORT ]
}

#####################################################################
# expander_wr_out_port
#      Writes to output port register. Each bit in byte represents
#      corresponding output pin value. 
#
# input 
#      base = base address for accessing of i2c subsystem
#      out  = output pins mask
######################################################################
proc expander_wr_out_port { base out } {
  global TCA9534_OUT_PORT
  expander_write $base $TCA9534_OUT_PORT $out
}

#####################################################################
# expander_wr_pol_inv
#      Writes polarity inversion register. Each bit in byte represents
#      inversion of corresponding pin value:
#        - 1 -- inverted
#        - 0 -- normal (default)
#
# input 
#      base = base address for accessing of i2c subsystem
#      inv = polarity inversion mask
######################################################################
proc expander_wr_pol_inv { base inv } {
  global TCA9534_POL_INV
  expander_write $base $TCA9534_POL_INV $cfg
}


#####################################################################
# expander_wr_config
#      Writes configuration to expander. Each bit in byte represents
#      I/O direction. 0 -- output, 1 -- input (default)
#
# input 
#      base = base address for accessing of i2c subsystem
#      config = configuration mask
######################################################################
proc expander_wr_config { base cfg } {
  global TCA9534_CONFIG
  expander_write $base $TCA9534_CONFIG $cfg
}


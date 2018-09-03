#
# Functions for controlling of SFP+ management I/O signals on
# Intel Cyclone 10 GX Kit.
# 
set top_dir $::env(SYSTEM_CONSOLE_TOPDIR_PATH)
source $top_dir/i2c/intel-i2c-api.tcl
source $top_dir/tca9534/expander.tcl

# I/O control is made by means of TCA9534 i2c expander 
# (see https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/ug/ug-c10-gx-fpga-devl-kit.pdf, chapter 4.9.3) and contains following signals:

# P0, red led, out
set C10GXKIT_SFP_RLED   0  

# P1, green led, out 
set C10GXKIT_SFP_GLED   1

# P2, tx_disable, out 
set C10GXKIT_SFP_TXDIS  2

# P3, tx fault, in
set C10GXKIT_SFP_TFLT   3

# P4, rate select 1, out
set C10GXKIT_SFP_RS1    4

# P5, rx loss of signal, in
set C10GXKIT_SFP_RLOS   5

# P6, rate select 0, out
set C10GXKIT_SFP_RS1    6

# P7, mod absent, in
set C10GXKIT_SFP_PRSN   7

# TCA9534 expander configuration byte. Each bit represents direction:
#   - 1 -- input
#   - 0 -- output
set C10GXKIT_EXP_CFG    0xA8

# default mask of SFPs output port
set C10GXKIT_EXP_DEFAULT 0x57 

#
# Base addresses for sfp0 & sfp1 i2c controllers
#
set C10GXKIT_SFP0_BASE  0x900000
set C10GXKIT_SFP1_BASE  0x0

########################################################################
#  c10gxkit_sfp_base 
#  returns base address by port index
#######################################################################
proc c10gxkit_sfp_base { port } {
  global C10GXKIT_SFP0_BASE
  global C10GXKIT_SFP1_BASE
  if { $port == 0 } { 
    return $C10GXKIT_SFP0_BASE 
  } else {
    return $C10GXKIT_SFP1_BASE
  }
}

#########################################################################
# c10gxkit_exp_init 
#
#     Initializes i2c controller, writes configuration to expanders and
#     initializes expander with default output values
#########################################################################
proc c10gxkit_exp_init { } {
  global C10GXKIT_SFP0_BASE
  global C10GXKIT_EXP_CFG
  global C10GXKIT_EXP_DEFAULT

  # FIXME: implement for loop here
  intel_i2c_init $C10GXKIT_SFP0_BASE 156200000 100000
  expander_wr_config $C10GXKIT_SFP0_BASE $C10GXKIT_EXP_CFG 
  expander_wr_out_port $C10GXKIT_SFP0_BASE $C10GXKIT_EXP_DEFAULT
}

#########################################################################
# c10gxkit_exp_set_pin
#     set or clear output expander pin on corresponding SFP port 
#
# input
#     port = SFP port index, 0 or 1
#     pin = pin index to set value to
#     value = pin value, non-zero or 0 
#
# example
#     clear TX_DISABLE pin value:
#       c10gxkit_exp_set_pin 0 C10GXKIT_SFP_TXDIS 0
#
#########################################################################
proc c10gxkit_exp_set_pin { port pin value } {
  global TCA9534_OUT_PORT
  set base [ c10gxkit_sfp_base $port ]

  expander_set_bit $base $TCA9534_OUT_PORT $pin $value 
}

#########################################################################
# c10gxkit_exp_get_pin
#     get value of expander pin on corresponding SFP port 
#
# input
#     port = SFP port index, 0 or 1
#     pin = pin index to set value to
#
# example
#     read RXLOS pin value:
#       c10gxkit_exp_get_pin 0 C10GXKIT_SFP_RLOS
#
#########################################################################
proc c10gxkit_exp_get_pin { port pin } {
  set base [ c10gxkit_sfp_base $port ]
  set inp [ expander_rd_inp_port $base ]

  return [ expr { ($inp >> $pin) & 1 } ]
}


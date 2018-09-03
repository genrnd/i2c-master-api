#! /usr/bin/tclsh

set top_dir $::env(SYSTEM_CONSOLE_TOPDIR_PATH)

source $top_dir/c10gx-kit/sfp-ctl.tcl

c10gxkit_exp_init

# clear TX DISABLE (enable TX)
c10gxkit_exp_set_pin 0 $C10GXKIT_SFP_TXDIS 0

exec sleep 1

set rxlos [ c10gxkit_exp_get_pin 0 $C10GXKIT_SFP_RLOS ]
set modabs [ c10gxkit_exp_get_pin 0 $C10GXKIT_SFP_PRSN ]

puts "MOD_ABS = $modabs, RX_LOS = $rxlos"


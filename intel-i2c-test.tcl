#! /usr/bin/tclsh

set top_dir $::env(SYSTEM_CONSOLE_TOPDIR_PATH)

source $top_dir/i2c/intel-i2c-api.tcl

set base 0x0

puts "i2c init"
intel_i2c_init $base 50000000 110000

puts "i2c start reading"
intel_i2c_start $base 0x55 1

puts "i2c read"
set read [ intel_i2c_read $base 0 ]"
puts "read: $read"

puts "i2c read last"
set read [ intel_i2c_read $base 1 ]"

puts "read: $read"

puts "i2c start writing"
intel_i2c_start $base 0x55 0

puts "i2c write"
intel_i2c_write $base 0xaa 0

puts "i2c write last"
intel_i2c_write $base 0xee 1


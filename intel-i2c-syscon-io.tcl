#
# I/O callbacks for accessing FPGA registers via system-console.
# It is assumed that system-console interface is claimed to the moment 
# of usage of these functions.
# Functions accessing system-console via global variable 'claim_path_gl'
#
set top_dir $::env(SYSTEM_CONSOLE_TOPDIR_PATH)

proc iowr { base reg data } {
  global claim_path_gl

  set addr [ expr { $base + $reg } ]
  master_write_32 $claim_path_gl $addr $data
  puts [ format "WR\[ %08x \]\[ %02x \] = %04x" $base $reg $data ]
}

proc iord { base reg } {
  global claim_path_gl

  set addr [ expr { $base + $reg } ]
  set data [ master_read_32 $claim_path_gl $addr 1 ]

  puts [ format "RD\[ %08x \]\[ %02x \] = %04x" $base $reg $data ]
  return $data
}



proc iowr { base reg data } {
  puts [ format "WR\[ %02x \]\[ %02x \] = %02x" $base $reg $data ]
}

proc iord { base reg } {
  puts [ format "RD\[ %02x \]\[ %02x \] = 0" $base $reg ]
  return 3
}


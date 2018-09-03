###################################################################
# Intel Avalon i2c Master Core registers                  
#
# all registers are 32 bits wide, on 32 bit address boundaries
#
# registers definitions has been taken from 
# https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/ug/ug_embedded_ip.pdf, chapter 12
#

#
# Command register
#
set INTEL_I2C_TFR_CMD                  0

# bits
set   INTEL_I2C_TFR_CMD_STA_MSK        0x200
set   INTEL_I2C_TFR_CMD_STA_OFST       9

set   INTEL_I2C_TFR_CMD_STO_MSK        0x100
set   INTEL_I2C_TFR_CMD_STO_OFST       8

# used during data write
set   INTEL_I2C_TFR_CMD_DATA_MSK       0xff
set   INTEL_I2C_TFR_CMD_DATA_OFST      0

# used during slave address write
set   INTEL_I2C_TFR_CMD_AD_MSK         0xfe
set   INTEL_I2C_TFR_CMD_AD_OFST        1

set   INTEL_I2C_TFR_CMD_RW_D_MSK       0x1
set   INTEL_I2C_TFR_CMD_RW_D_OFST      0

#
# Receive Data FIFO
#
set INTEL_I2C_RX_DATA                  1

# bits
set   INTEL_I2C_RX_DATA_MASK           0xff


#
# Control register
#
set INTEL_I2C_CTRL                    2

# bits
set   INTEL_I2C_CTRL_RX_DATA_FIFO_THD_MSK    0x30
set   INTEL_I2C_CTRL_RX_DATA_FIFO_THD_OFST   4

set   INTEL_I2C_CTRL_TFR_CMD_FIFO_THD_MSK    0xc
set   INTEL_I2C_CTRL_TFR_CMD_FIFO_THD_OFST   2

set   INTEL_I2C_CTRL_BUS_SPEED_MSK    0x2
set   INTEL_I2C_CTRL_BUS_SPEED_OFST   1

set   INTEL_I2C_CTRL_EN_MSK           0x1
set   INTEL_I2C_CTRL_EN_OFST          0


#
# Interrupt Status Enable Register
#
set INTEL_I2C_ISER                    3

# TODO: bits

#
# Interrupt Status Register
# 
set INTEL_I2C_ISR                     4

# bits
set   INTEL_I2C_ISR_RX_OVER_MSK       0x10
set   INTEL_I2C_ISR_RX_OVER_OFST      4

set   INTEL_I2C_ISR_ARBLOST_MSK       0x8 
set   INTEL_I2C_ISR_ARBLOST_OFST      3

set   INTEL_I2C_ISR_NACK_MSK          0x4 
set   INTEL_I2C_ISR_NACK_OFST         2

set   INTEL_I2C_ISR_RX_READY_MSK      0x2 
set   INTEL_I2C_ISR_RX_READY_OFST     1

set   INTEL_I2C_ISR_TX_READY_MSK      0x1
set   INTEL_I2C_ISR_TX_READY_OFST     0

#
# Status Register
# 
set INTEL_I2C_SR                      5

set   INTEL_I2C_SR_CORE_STATUS_MSK    0x1
set   INTEL_I2C_SR_CORE_STATUS_OFST   0

#
# TFR CMD FIFO Level
# 
set INTEL_I2C_CMD_FIFO_LEVEL          6

# TODO: bits

#
# RX_DATA FIFO Level
# 
set INTEL_I2C_RX_DATA_FIFO_LEVEL      7

# TODO: bits

#
# SCL Low Count
#
set INTEL_I2C_SCL_LOW                 8

set INTEL_I2C_SCL_LOW_MSK             0xffff
set INTEL_I2C_SCL_LOW_OFST            0

#
# SCL High Count
#
set INTEL_I2C_SCL_HIGH                9

set INTEL_I2C_SCL_HIGH_MSK            0xffff
set INTEL_I2C_SCL_HIGH_OFST           0

#
# SDA Hold Count
#
set INTEL_I2C_SDA_HOLD                10

set INTEL_I2C_SDA_HOLD_MSK            0xffff
set INTEL_I2C_SDA_HOLD_OFST           0


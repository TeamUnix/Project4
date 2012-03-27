--------------------------------------------------------------------------------
--! @file
--! @ingroup	RTL
--! @brief		WB output port
--! @details    General Purpose Wishbone output port. Width identical
--! 			to Wishbone datawidth, with granularity similar to width
--! @author		Morten Opprud Jakobsen \n
--!				AU-HIH \n                                            
--!				morten@hih.au.dk \n 
--! @version  	1.0
----------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
library work;
	use work.def_pkg.all;

entity WBS_adcs is
	port	(
			--! Wishbone Slave interface
			--Input
			clk_i					: in		std_logic;									--! Clock input from SYSCON
			rst_i					: in		std_logic;									--! Reset for Wishbone interface
			cyc_i					: in		std_logic;									--! cycle input, asserted when cycle is in progress
			stb_i					: in		std_logic;									--! Strobe input, similar to Chip Select
			we_i					: in		std_logic;									--! Write Enable: High=WR, Low=RD
			dat_i					: in		wb_dat_typ;									--! data from host
			adr_i					: in		wb_lad_typ;									--! Low address input
			--Ouput
			ack_o					: out		std_logic;									--! Slave acknowledge output, asserted after sucessful cycle
			err_o					: out		std_logic;									--! Error output, abnormal cycle termination
			rty_o					: out		std_logic;									--! Retry output, slave not ready
			dat_o					: out		wb_dat_typ									--! data to host
			--! Output port
			);
end WBS_adcs;

architecture RTL of WBS_adcs is


begin




end RTL;
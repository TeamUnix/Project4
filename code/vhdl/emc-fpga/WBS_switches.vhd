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

entity WBS_switches is
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
			dat_o					: out		wb_dat_typ;									--! data to host
			-------------------------------------------------
			--! Intput port
			sw						:in			std_logic_vector(7 downto 0)
			);
end WBS_switches;

architecture RTL of WBS_switches is

			signal Q				: std_logic_vector(7 downto 0);

begin

--!  Concurrent assignments
	err_o				<=	'0';
	rty_o				<=	'0';
	--dat_o(7 downto 0)	<=	Q;
	Q					<=	sw;
	ack_o				<=	stb_i and cyc_i;  --! asynhronous cycle termination is OK here.
	
--!  Processes                                             --
--! Wishbone write to Q register
	Reg : process(clk_i)
		begin
			if(clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					dat_o <= Revision_c;          --! Revision readable at reset 
				else
					if ((cyc_i and stb_i and not we_i) = '1') then
						case adr_i is
							when A_WBO_REG1 =>
								dat_o(7 downto 0)	<= Q;
							when others =>
							--Ack_o <= '0'; 
						end case;
						
					else
						Q <= Q;
					end if;
				end if;
			end if;
	end process Reg;
	
end RTL;
--------------------------------------------------------------------------------
--! @file
--! @ingroup	RTL
--! @brief		Cpu interface
--! @details    This block synchronizes all signals from the CPU to the FPGA's 
--!				clock domain
--! @author		Morten Opprud Jakobsen \n
--!				AU-HIH \n                                            
--!				morten@hih.au.dk \n 
--! @version  	1.0
--! @todo Full in decoding of control signals and sampling of the Add/Data busses		
--!				Calculate and simulate and verify number of nessecery CPU Waitstates
--------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.ALL;
library work;
	use work.def_pkg.ALL;
  
entity CpuInterface is
	generic	( 
				AddrWidth : integer := 7;												--DataWidth of Address bus
				DataWidth : integer := 16												--DataWidth of Databus in and out
				);

	port	(
			--Input
			Clk					: in     std_logic;												-- Clock signal synchronous to CPU signals
			Rst					: in     std_logic;												-- Asynchronous Reset
			CpuRd_i				: in     std_logic;												-- CPU Read strobe
			CpuWr_i				: in     std_logic;												-- CPU Write strobe
			CpuCs_i				: in     std_logic;												-- CPU Chip Select
			D_i					: in     std_logic_vector ( DataWidth-1 downto 0 );	-- Data bus from application
			CpuA_i				: in     std_logic_vector ( AddrWidth-1 downto 0 );	-- CPU Address Input
			CpuD_i				: in     std_logic_vector ( DataWidth-1 downto 0 );	-- CPU Data Input
			--Output
			Wr_o					: out    std_logic;												-- Write strobe (single clock) to application
			Rd_o					: out    std_logic;												-- Read strobe (single clock) to application
			A_o					: out    std_logic_vector ( AddrWidth-1 downto 0 );	-- Address bus to application 
			D_o					: out    std_logic_vector ( DataWidth-1 downto 0 );	-- Data bus to application
			CpuD_o				: out    std_logic_vector ( DataWidth-1 downto 0 )	-- CPU Data Output
			);
end CpuInterface ;

architecture RTL of CpuInterface is
---- ADD HERE !!!!!!!!!!!!!


begin

--------------------------------------------------------------------------------
--                         Synchronize input signals                          --
--------------------------------------------------------------------------------


---- ADD HERE !!!!!!!!!!!!!

process (Clk,Rst)
begin  
	if Rst = '1' then
		Wr_o		<= '0';
		Rd_o		<= '0';
		A_o		<= (others => '0');
		D_o		<= (others => '0');
		CpuD_o	<= (others => '0');
	elsif (Clk'event and Clk = '1') then
		if CpuCs_i = '1' then
			A_o	<= CpuA_i;							--Adress routing
			if CpuRd_i = '1' then					--Reading
				Rd_o		<= CpuRd_i;
				Wr_o		<= CpuWr_i;
				CpuD_o	<= D_i;						--Wishbone data out to Cpu data input
			elsif CpuWr_i = '1' then				--Writing
				Wr_o		<= CpuWr_i;					
				Rd_o		<= CpuRd_i;
				D_o		<= CpuD_i;					--Cpu data output to wishbone data input
			else
				Wr_o		<= CpuWr_i;					
				Rd_o		<= CpuRd_i;
				D_o		<= CpuD_i;
				CpuD_o	<= (others => '0');
			end if;
		else
			Wr_o		<= '0';					
			Rd_o		<= '0';
			D_o		<= (others => '0');
			A_o		<= (others => '0');
			CpuD_o	<= (others => '0');
      end if;
   end if;
end process;



end;

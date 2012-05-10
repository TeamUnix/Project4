--------------------------------------------------------------------------------
--! @file
--! @defgroup	RTL RTL - All files that compromise the physical (FPGA) design
--! @brief		Cputest_structure
--! @details    This module connects all the internal slaves, the host and the  
--!				syscon with the interconn. 
--! @image 		html CpuTestSch.JPG "Cpu Test structure connections"
--! @author		Morten Opprud Jakobsen \n
--!				morten@opprud.dk \n 
--! @version  	see svn log for details
--------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.ALL;
library work;
	use work.def_pkg.ALL;

entity Wrapper is
	port	(
			--Input
			Clock				: in		std_logic;							--! Clock signal synchronous to CPU signals
			nRst_i				: in		std_logic;							--! LPC Reset
			Rst_i				: in		std_logic;							--! FPGA Reset
			nCpuCs_i			: in		std_logic;							--! CPU Chip Select
			nCpuRd_i			: in		std_logic;							--! CPU Read strobe
			nCpuWr_i			: in		std_logic;							--! CPU Write strobe
			CpuA_i				: in		wb_adr_typ;							--! CPU Address Input
			sw					: in		std_logic_vector(7 downto 0);
			--Inoutput
			CpuD				: inout	wb_dat_typ;								--! External Bi-directional databus
			--Output
			Dbus_En				: out		std_logic;							--! Enable signal for DATABUS latches on LPC2478 board, connect to CS
			Abus_En				: out		std_logic;							--! Enable signal for ADDRESSBUS latches on LPC2478 board, connect to gnd
			irq_o				: out		std_logic;
			led					: out		std_logic_vector ( 7 downto 0 )		--! Test output port
			);
end Wrapper ;

architecture struct of Wrapper is													--! Architecture declarations

--! Internal signal declarations
--active high CPU signals
			signal CpuCs_i		: std_logic;											-- CPU Chip Select
			signal CpuRd_i		: std_logic;											-- CPU Read strobe
			signal CpuWr_i		: std_logic;											-- CPU Write strobe
			signal CpuD_o		: wb_dat_typ;											-- CPU Data Output
--			signal CpuD_i		: wb_dat_typ;											-- CPU Data Input
  
-- WB signals
			signal clk_o		: std_logic;											-- system clock
			signal rst_o		: std_logic;											-- system reset
			signal ack_i		: std_logic;											-- Aknowledge input from selected slave
			signal err_i		: std_logic;											-- Error input from selected slave
			signal rty_i		: std_logic;											-- Retry input from selected slave
			signal stb_o		: std_logic;											-- Strobe signal
			signal cyc_o		: std_logic;											-- Valid bus cycle in progress
			signal we_o			: std_logic;											-- Write indicator
			signal cyc_i		: std_logic;											-- Active during a valid bus cycle
			signal we_i			: std_logic;											-- Write indicator
			signal adr_i		: wb_lad_typ;											-- Lower Address bus for selecting address space inside slave
			signal adr_o		: wb_adr_typ;											-- Address bus output from Master
			signal cti_i		: wb_cti_typ;											-- ycle Type Identifier
			signal cti_o		: wb_cti_typ;											-- cyle type identifier
			signal dat_i		: wb_dat_typ;											-- Data input from selected slave
			signal dat_o		: wb_dat_typ;											-- Databus from Master
			signal s_dat_i		: wb_dat_typ;											-- Databus common to all slaves
			signal s_dat_o		: wb_s_dat_typ		( Num_s downto 0 );			-- Array of Databusses from all Slaves
			signal stb_i		: std_logic_vector( Num_s downto 0 );
			signal ack_o		: std_logic_vector( Num_s downto 0 );			-- Bus of Ack responses from all Slaves
			signal err_o		: std_logic_vector( Num_s downto 0 );			-- Bus of Err responses from all Slaves
			signal rty_o		: std_logic_vector( Num_s downto 0 );			-- Bus of Rty responses from all Slaves
  
-- Out test port
			signal s_led		: std_logic_vector( 7 downto 0);				-- Bus of Rty responses from all Slaves
			signal switch		: std_logic_vector( 7 downto 0);
			signal irq_add1		: std_logic_vector(AddrRange-1 downto 0);
			signal s_irq		: std_logic; --_vector(Num_irqs-1 downto 0);
			signal irq			: std_logic;
			signal reset		: std_logic;

begin
--! Architecture concurrent statements
--! Drive Databus during read
	CpuD <= CpuD_o when nCpuCs_i = '0' and nCpuRd_i = '0' else (others => 'Z');
	CpuCs_i <= not nCpuCs_i;
	CpuRd_i <= not nCpuRd_i;
	CpuWr_i <= not nCpuWr_i;
	reset	<= (not nRst_i or not Rst_i);

--! Enable Databus latches when CS is set (see LPC2478 OEM manual)
	Dbus_En <= nCpuCs_i;
	Abus_En <= '0';
  	
--! LED Port o
	led		<= s_led;
--! Switch port
	switch	<= sw;
--! IQR port
	irq_o	<= irq;
  	
--! Instantiate and port map
	Host1 : entity work.host(struct)
		port map	(
					--! Sys signals 
					Clk     => clk_o,
					clk_i   => clk_o,
					Rst     => rst_o,
					rst_i   => rst_o,
					--! to CPU signals 
					CpuA_i  => CpuA_i,
					CpuCs_i => CpuCs_i,
					--CpuD_i  => CpuD_i,
					CpuD_i  => CpuD,
					CpuRd_i => CpuRd_i,
					CpuWr_i => CpuWr_i,
					CpuD_o  => CpuD_o,
					--! to Interconn signals
					ack_i   => ack_i,
					err_i   => err_i,
					rty_i   => rty_i,
					dat_i   => dat_i,
					adr_o   => adr_o,
					stb_o   => stb_o,
					cti_o   => cti_o,
					cyc_o   => cyc_o,
					we_o    => we_o,
					dat_o   => dat_o
					);

	Intercon1 : entity work.Intercon(RTL)
		port map	(
					--! System signals 
					clk_i   => clk_o,
					rst_i   => rst_o,
					--! to/from Host signals
					ack_o   => ack_i,
					err_o   => err_i,
					rty_o   => rty_i,
					m_dat_o => dat_i,
					adr_i   => adr_o,
					stb_i   => stb_o,
					cti_i   => cti_o,
					cyc_i   => cyc_o,
					we_i    => we_o,
					m_dat_i => dat_o,
					--! to/from WB slaves signals
					adr_o   => adr_i,
					cti_o   => cti_i,
					cyc_o   => cyc_i,
					we_o    => we_i,
					s_dat_o => s_dat_i,
					stb_o   => stb_i,
					ack_i   => ack_o,
					err_i   => err_o,
					rty_i   => rty_o,
					s_dat_i => s_dat_o
					);

	Syscon1 : entity work.Syscon(RTL)
		port map	(
					Reset => reset,
					clk_i => Clock,
					rst_o => rst_o,
					clk_o => clk_o
					);	

	irq_reg	: entity work.WBS_irq_reg(RTL)
		port map	(
					clk_i => clk_o,
					rst_i => rst_o,
					cyc_i => cyc_i,
					stb_i => stb_i(IRQ_REG_WBS),
					we_i => we_i,
					adr_i => adr_i,
					ack_o => ack_o(IRQ_REG_WBS),
					err_o => err_o(IRQ_REG_WBS),
					rty_o => rty_o(IRQ_REG_WBS),
					dat_o => s_dat_o(IRQ_REG_WBS),
					irq_i => s_irq,
					add_1 => irq_add1,
--					add_2 => (others => '0'),
					irq_o => irq
					);
					
	switches : entity work.WBS_switches(RTL)
		port map 	(
					clk_i	=> clk_o,
					rst_i	=> rst_o,
					cyc_i	=> cyc_i,
					stb_i	=> stb_i(SWITCH_WBS),
					we_i	=> we_i,
					adr_i	=> adr_i,
					ack_o	=> ack_o(SWITCH_WBS),
					err_o	=> err_o(SWITCH_WBS),
					rty_o	=> rty_o(SWITCH_WBS),
					dat_o	=> s_dat_o(SWITCH_WBS),
					sw_i	=> switch,
					irq_o	=> s_irq,
					irq_add	=> irq_add1
					);
	
	leds : entity work.WBS_leds(RTL)
		port map 	(
					clk_i	=> clk_o,
					rst_i	=> rst_o,
					cyc_i	=> cyc_i,
					stb_i	=> stb_i(LED_WBS),
					we_i 	=> we_i,
					dat_i	=> s_dat_i,
					adr_i	=> adr_i,
					ack_o	=> ack_o(LED_WBS),
					err_o	=> err_o(LED_WBS),
					rty_o	=> rty_o(LED_WBS),
					dat_o	=> s_dat_o(LED_WBS),
					leds	=> s_led
					);

end struct;
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
	use IEEE.numeric_std.all;
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
--			dat_i					: in		wb_dat_typ;									--! data from host
			adr_i					: in		wb_lad_typ;									--! Low address input
			--Ouput
			ack_o					: out		std_logic;									--! Slave acknowledge output, asserted after sucessful cycle
			err_o					: out		std_logic;									--! Error output, abnormal cycle termination
			rty_o					: out		std_logic;									--! Retry output, slave not ready
			dat_o					: out		wb_dat_typ;									--! data to host
			-------------------------------------------------
			--! Intput port
			sw_i					: in		std_logic_vector(7 downto 0);
			--! Output port
			irq_add					: out		std_logic_vector(AddrRange-1 downto 0);
			irq_o					: out		std_logic := '0'
			);
end WBS_switches;

architecture RTL of WBS_switches is

	--Constants
	constant N				: integer := 18;--17;
	constant M				: integer := 3;

	--Types
	type state_type is	(
								START,
								IDLE,
								WAIT0,
								OUT0
								);
	--Signals
	signal state_reg		: state_type;
	signal state_next		: state_type;
	signal sw_o				: std_logic_vector(7 downto 0);
	signal q1_reg			: unsigned(N-1 downto 0) := (others => '1');
	signal q1_next			: unsigned(N-1 downto 0) := (others => '1');
	signal q2_reg			: unsigned(M-1 downto 0) := (others => '1');
	signal q2_next			: unsigned(M-1 downto 0) := (others => '1');

begin

--!  Concurrent assignments
	err_o				<=	'0';
	rty_o				<=	'0';
	ack_o				<=	stb_i and cyc_i;  --! asynhronous cycle termination is OK here.
	
--! IRQ address
	irq_add(AddrRange-1 downto LAddrRange)		<= BA_WBS_3;
	irq_add(LAddrRange-1 downto 0)				<= WBS_REG1;
	
--!  Processes                                             --
	Reg : process(clk_i)
		begin
			if(clk_i'event and clk_i = '1') then
				if (rst_i = '1') then
					dat_o(7 downto 0)	<= sw_i;
					dat_o(15 downto 8)	<= (others => '0');
				else
					if ((cyc_i and stb_i and not we_i) = '1') then
						case adr_i is
							when WBS_REG1 =>
								dat_o(7 downto 0)	<= sw_o;
								dat_o(15 downto 8)	<= (others => '0');
							when others =>
						end case;
					else
					end if;
				end if;
			end if;
	end process Reg;
	
	-- state register
	process(clk_i, rst_i)
	begin
		if	(rst_i = '1') then
			state_reg		<= START;
			q1_reg			<= (others => '0');
			q2_reg			<= (others => '0');
		elsif (clk_i'event and clk_i='1') then
			state_reg		<= state_next;
			q1_reg			<= q1_next;
			q2_reg			<= q2_next;
		end if;
	end process;
	
	-- next state/output logic
	process(state_reg, q1_reg, q1_next, q2_reg, q2_next, sw_i, sw_o)
	begin
		state_next		<= state_reg;
		q1_next			<= q1_reg;
		q2_next			<= q2_reg;
		case state_reg is
		-- Start state ------------------------------------------
			when START =>
				state_next <= IDLE;
				sw_o <= sw_i;
--				dat_o(7 downto 0)	<= sw_i;
-- 				dat_o(15 downto 8)	<= (others => '0');
		-- Idle state -------------------------------------------
			when IDLE =>
				q2_next <= q2_reg-1;
				if	(q2_next = 0) then
					irq_o <= '0';
					if	(sw_i = sw_o) then
						state_next <= IDLE;
					else
						q1_next		<= (others => '1');
						state_next	<= WAIT0;
					end if;
				else
					state_next <= IDLE;
				end if;
		-- Wait state -------------------------------------------
			when WAIT0 =>
				if	(sw_i = sw_o) then
					state_next <= IDLE;
				else
					q1_next <= q1_reg-1;
					if	(q1_next = 0) then
						state_next <= OUT0;
					else
						state_next <= WAIT0;
					end if;
				end if;
		-- Output state -----------------------------------------
			when OUT0 =>
				sw_o		<= sw_i;
--				dat_o(7 downto 0)	<= sw_i;
--				dat_o(15 downto 8)	<= (others => '0');
				irq_o		<= '1';
				q2_next		<= (others => '1');
				state_next	<= IDLE;
		end case;
	end process;
	
end RTL;
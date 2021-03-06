-- ARM7 Bus functional model
--
-- Author:  Morten@HIH.AU.DK
-- Version: 0.1
-- Date:    04.04.2011
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the
-- Free Software  Foundation, Inc., 59 Temple Place, Suite 330,
-- Boston, MA  02111-1307  USA
--

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE std.textio.all;
USE work.txt_util.all;

-- package declaration similar to "entity"
package arm_emc_package is
	constant CYCLE		: time		:= 13.89 ns;-- 13.89ns @ 72MHz
	--Read
	constant WAITOEN	: integer	:= 1;		-- Waitstates from CS to Output Enable
	constant WAITRD		: integer	:= 6;		-- Waitsattes from CS to Read Access
	--Write
	constant WAITWEN	: integer	:= 1;		-- Waitstates from CS to Write Enable
	constant WAITWR		: integer	:= 6;		-- Waitstates from CS to Write Access
  
  
  -- WAITTURN - Bus turnaround 
  -- WAITPAGE - Wait states async page mode read

	-- EMC timing, adjust to fit electricaldatasheet
	-- Read timing
	constant Tr_CSLAV  	: time := 2.54 ns;									-- Max time
	constant Tr_CSLOEL  : time := ((CYCLE*WAITOEN)-0.78 ns);				-- Min time 
	constant Tr_OELOEH  : time := (((WAITRD-WAITOEN+1)*CYCLE) -0.59 ns);	-- Min time
	constant Tr_OEHANV  : time := 0.20 ns;									-- Typ time
	constant Tr_CSHOEH  : time := 0 ns;										-- Typ time
	
	-- Write timing
	constant Tw_CSLAV  	: time := 2.54 ns;									-- Max time
	constant Tw_CSLWEL  : time := ((1+WAITWEN)*CYCLE)-0.88 ns;				-- Min time
	constant Tw_CSLDV  	: time := 4.79 ns;									-- Max time
	constant Tw_WELWEH  : time :=  ((WAITWR-WAITWEN+1)*CYCLE)-0.78 ns;		-- Min time
	constant Tw_WEHANV  : time := CYCLE;									-- Min time
	constant Tw_WEHDNV  : time := 0.78 ns + CYCLE;							-- Min time

  -- ARM EMC interface
  type arm_emc_t is record
      nCpuCs_i	: std_logic;
      nCpuRd_i	: std_logic;
      nCpuWr_i	: std_logic;
      CpuA_i  	: std_logic_vector(15 downto 0);
      CpuD    	: std_logic_vector(15 downto 0);
  end record;

  -- Write EMC
  procedure arm_16bit_write (	signal clk: in std_logic;
                        		signal uio: out arm_emc_t;
                        		addr      : in std_logic_vector (15 downto 0);
                        		data      : in std_logic_vector (15 downto 0);
                        		file log  : TEXT
                       	   );

  -- Read EMC
  procedure arm_16bit_read (	signal clk: in std_logic;
                        		signal uio: out arm_emc_t;
                        		addr      : in std_logic_vector (15 downto 0);
                        		--data      : in std_logic_vector (15 downto 0);
                        		file log  : TEXT
                       	   );


  -- Compare two std_logic_vectors (handles don't-care)
  function compare (d1 : std_logic_vector; d2 : std_logic_vector) return boolean;

end arm_emc_package;

-- implementation of functional units
package body arm_emc_package is

    -- Write EMC
    procedure arm_16bit_write (	signal clk: in std_logic;
                          		signal uio: out arm_emc_t;
                          		addr      : in std_logic_vector (15 downto 0);
                          		data      : in std_logic_vector (15 downto 0);
                          		file log  : TEXT
                         	   ) is

    begin
        --print (log, "EMC write: 0x" & hstr(addr) & " : 0x" & hstr(data));
		    -- start cycle; 
        -- setup addr
        uio.CpuA_i <= addr;
		  wait for Tw_CSLAV;
        -- assert CS
        uio.nCpuCs_i <= '0';
        wait for (Tw_CSLDV);
        -- setup data
        uio.CpuD <= data;
        -- wait for WE to be set
        wait for (Tw_CSLWEL-Tw_CSLDV);
        uio.nCpuWr_i <= '0';
        -- write happens
        wait for (Tw_WELWEH);
		  uio.nCpuWr_i <= '1';
		  uio.nCpuCs_i <= '1';
        wait for Tw_WEHDNV;
        --invalidate data and addr
        uio.CpuA_i <= (others => 'U');
        uio.CpuD  <= (others => 'Z');
		    -- deassert cs
        uio.nCpuCs_i <= '1';
        

    end arm_16bit_write;

    -- Read EMC
    procedure arm_16bit_read (	signal clk: in std_logic;
                          		signal uio: out arm_emc_t;
                          		addr      : in std_logic_vector (15 downto 0);
                          		--data      : out std_logic_vector (15 downto 0);
                          		file log  : TEXT
                         	   ) is
--      variable data : std_logic_vector(15 downto 0);
    begin
        --  print (log, "EMC read: 0x" & hstr(addr) & " : 0x" & hstr(data));
		    -- start cycle;
        -- assert CS
        uio.nCpuCs_i <= '0'; 
        wait for Tr_CSLAV;
        -- setup address
        uio.CpuA_i <= addr;
        wait for (Tr_CSLOEL-Tr_CSLAV); 
		  -- assert RD (OE)
        uio.nCpuRd_i <= '0';
        wait for (Tr_OELOEH-Tr_CSHOEH);
        --sample data
        --data  <= uio.CpuD;
        --print (log, "EMC read: 0x" & hstr(addr) & " : 0x" & hstr(uio.CpuD));
        --deassert CS
        uio.nCpuCs_i <= '1';
        wait for Tr_CSHOEH; 
        --deassert RD (OE)
        uio.nCpuRd_i <= '1';
        wait for Tr_OEHANV; 
        -- invalidate Address
        uio.CpuA_i <= (others => 'U');

    end arm_16bit_read;

    -- Compare two std_logig_vectors (handles don't-care)
    function compare (d1 : std_logic_vector; d2 : std_logic_vector) return boolean is
--        variable i : natural;
    begin
        for i in d1'range loop
            if (not (d1(i)='-' or d2(i)='-')) then
                if (d1(i)/=d2(i)) then
                    return false;
                end if;
            end if;
        end loop;
        return true;
    end compare;

end arm_emc_package;

--------------------------------------------------------------------------------
--! @file
--! @ingroup	RTL
--! @brief		Definitions package
--! @details    Defines constants and types for use in the project
--! @author		Morten Opprud Jakobsen \n
--!				AU-HIH \n                                            
--!				morten@hih.au.dk \n 
--! @version  	1.0
--! @version  	see svn log for details
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;

package def_pkg is

  --! Common type declarations in the project
  subtype DWord     is    std_logic_vector (31 downto 0);
  subtype Word      is    std_logic_vector (15 downto 0);
  subtype Byte      is    std_logic_vector (7 downto 0);
  subtype QBit      is    std_logic_vector (3 downto 0);
  subtype Int6      is    integer range 0 to 63;   -- 6 bit integer
  subtype Int8      is    integer range 0 to 255;  -- 8 bit integer
  subtype Int10     is    integer range 0 to 1023; -- 10 bit integer

  type CommandType is (Idle,Rd16,Wr16);
  type BfmCommandType is
    record
      Cmd:  CommandType;
      A:    std_logic_vector (15 downto 0);
      D:    std_logic_vector (15 downto 0);
    end record;

--! Project Constants

--! FPGA revision: xxxx.yyyy.zzzzzzzz
--! xxxx: Main revision. yyyy: sub-revision. zzzzzzzz: build
  constant Revision_c:        Word        := X"0101";	--rev 0.00.1  
   
--! Wishbone Constants and types
  constant Num_s:         integer := 3;  --! Number of slaves  connected to the Intercon
  constant Num_m:         integer := 1;  --! Number of masters connected to the Intercon
  constant Num_irqs:	  integer := 1;	 --! Number of IRQ slaves
  constant Datawidth:     integer := 16; --! Number of bits in datainterface
  constant AddrRange:     integer := 7;  --! Number of bits in Address space (was 16)
  constant LAddrRange:    integer := 4;  --! Number of bits in Low Address space, which connects to slaves
  constant HAddrRange:    integer := 3;  --! Number of bits in High Address space, used for decoding in Intercon
  constant Num_bytes:     integer := 2;  --! Number of databytes
  constant tga_width:     integer := 1;  --! Number of bits in Address Tags
  constant tgc_width:     integer := 1;  --! Number of bits in Cycle Tags
  constant tgd_width:     integer := 1;  --! Number of bits in Data Tags
  constant cti_width:     integer := 3;  --! Number of bits in cti vector (always 3)

  --! Type definition for sizing vectors
  subtype wb_adr_typ is   std_logic_vector (AddrRange-1 downto 0);  --! Full Address range
  subtype wb_lad_typ is   std_logic_vector (LAddrRange-1 downto 0); --! Address range for slave connections
  subtype wb_had_typ is   std_logic_vector (HAddrRange-1 downto 0); --! Address range for decoding in Intercon
  subtype wb_sel_typ is   std_logic_vector (Num_bytes-1 downto 0);	--! 
  subtype wb_dat_typ is   std_logic_vector (Datawidth-1 downto 0);	--! WB datawidth is 16
  subtype wb_cti_typ is   std_logic_vector (cti_width-1 downto 0);	--!

  --! Master interface type definitions - arrays of vectors from above
  subtype wb_m_size is    std_logic_vector (Num_m-1 downto 0);
  type wb_m_adr_typ is    array (Num_m-1 downto 0) of wb_adr_typ;
  type wb_m_sel_typ is    array (Num_m-1 downto 0) of wb_sel_typ;
  type wb_m_dat_typ is    array (Num_m-1 downto 0) of wb_dat_typ;
  type wb_m_cti_typ is    array (Num_m-1 downto 0) of wb_cti_typ;

  --! Other Wishbone specific type definitions.
  type wb_p_dat_typ is    array (2**LAddrRange-1 downto 0) of wb_dat_typ;

  --! Slave interface type definitions  - arrays of vectors from above
  subtype wb_s_size is    std_logic_vector (Num_s downto 0);

  --type wb_s_dat_typ is    array (Num_s downto 0) of wb_dat_typ;
  type wb_s_dat_typ is    array (natural range <>) of wb_dat_typ;
--  type wb_irqs_dat_typ is    array (Num_irqs-1 downto 0) of wb_adr_typ;
  type wb_irqs_dat_typ is    array (2 downto 0) of std_logic_vector (6 downto 0);


  constant cti_classic:   wb_cti_typ := "000";

--! Other constant definitions                            
  --! Misc constants
  constant Low :  std_logic := '0';
  constant High: std_logic:= '1';

--! Wishbone slave constants
  constant IRQ_REG_WBS 	: integer := 1;
  constant LED_WBS 		: integer := 2;
  constant SWITCH_WBS	: integer := 3;
--  constant ADC_WBS		: integer := 4;

--! High Address constants
  constant BA_WBS_1		:	wb_had_typ	:= "000";  --! 0x00 Base addresses for IRQ register
  constant BA_WBS_2		:	wb_had_typ	:= "001";  --! 0x01 Base addresses for LEDs
  constant BA_WBS_3		:	wb_had_typ	:= "010";  --! 0x02 Base addresses for Switches
--  constant BA_WBS_4		:	wb_had_typ	:= "011";  --! 0x03 Base addresses for Analog to digital converter

--! Low Address constants (Memory map) 
  constant WBS_REG1:        wb_lad_typ := "0000"; -- 0x0
  constant WBS_REG2:        wb_lad_typ := "0001"; -- 0x2

end def_pkg; 

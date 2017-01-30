--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:04:51 01/29/2017
-- Design Name:   
-- Module Name:   F:/programmation/VHDL/UART/UART_tb.vhd
-- Project Name:  UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY UART_tb IS
END UART_tb;
 
ARCHITECTURE behavior OF UART_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART
    PORT(
         Rx : IN  std_logic;
         Tx : OUT  std_logic;
         CLK : IN  std_logic;
         RST : IN  std_logic;
         CS : IN  std_logic;
         RW : IN  std_logic;
         INT : OUT  std_logic;
         address : IN  std_logic_vector(1 downto 0);
         data : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Rx : std_logic := '1';
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal CS : std_logic := '1';
   signal RW : std_logic := '1';
   signal address : std_logic_vector(1 downto 0) := "11";

	--BiDirs
   signal data : std_logic_vector(7 downto 0);

 	--Outputs
   signal Tx : std_logic;
   signal INT : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART PORT MAP (
          Rx => Rx,
          Tx => Tx,
          CLK => CLK,
          RST => RST,
          CS => CS,
          RW => RW,
          INT => INT,
          address => address,
          data => data
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 
		--data<="00000000";
		wait for 78 us;
		Rx<='0';
		wait for 104.2 us;
		Rx<='1';
		wait for 104.2 us;
		Rx<='1';
		wait for 104.2 us;
		Rx<='0';
		wait for 104.2 us;
		Rx<='1';
		wait for 104.2 us;
		Rx<='0';
		wait for 104.2 us;
		Rx<='1';
		wait for 104.2 us;
		Rx<='1';
		wait for 104.2 us;
		Rx<='1';
      wait;
   end process;

END;

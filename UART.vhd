----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:53:10 01/19/2017 
-- Design Name: 
-- Module Name:    UART - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART is
    Port ( Rx : in  STD_LOGIC;
           Tx : out  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  CS : in STD_LOGIC;
			  RW :in STD_LOGIC;
			  INT: out STD_LOGIC;
			  address: in STD_LOGIC_VECTOR(1 downto 0);
           data : inout  STD_LOGIC_VECTOR(7 downto 0));
end UART;

architecture Behavioral of UART is

signal baud_clk : std_logic :='0';  --l'horloge pour le générateur de baud
signal baud_clk_counter: integer range 0 to 5207 := 0; --pour compter le nombre de tics avant de changer l'etat d'horloge
signal transmit_serial_counter: integer range 0 to 10 := 10;--pour savoir a quel bit on est dans la transmition/réception
signal baud_clk_reset : std_logic :='0';
signal baud_clk_reset_previous : std_logic :='0';
signal serial_out_buffer : STD_LOGIC_VECTOR(10 downto 0):="01001010011";
signal transmit : std_logic :='0';
signal busy : std_logic :='0';

begin

process(CLK,RST)
begin
	if(RST='1') then
		baud_clk <='0';
		baud_clk_counter <=0;
	elsif(baud_clk_reset='1' and baud_clk_reset_previous='0') then
		baud_clk <='0';
		baud_clk_counter <=0;
		baud_clk_reset_previous<='1';
	elsif(baud_clk_reset='0' and baud_clk_reset_previous='1') then
		baud_clk_reset_previous<='0';
	elsif rising_edge(CLK) then
		if (baud_clk_counter = 5207) then
			baud_clk <=NOT(baud_clk);
			baud_clk_counter <=0;
		else
				baud_clk_counter<=baud_clk_counter+1;
		end if;
	end if;	
end process;

process(transmit,RST)
begin
	if(RST='1') then
		transmit_serial_counter<=10;
		transmit<='0';
	elsif(transmit='1' and transmit_serial_counter=10) then
			baud_clk_reset<='1';
			transmit_serial_counter<=0;
	elsif(transmit_serial_counter<10 and rising_edge(baud_clk)) then
			transmit<='0';
			baud_clk_reset<='0';
			transmit_serial_counter<=transmit_serial_counter+1;	
	end if;
end process;

process(CS,RW,address)
begin
	if(CS='1') then
		if(RW='1') then
			if(address="00") then
				serial_out_buffer(8 downto 1)<=data;
			elsif(address="11") then
				transmit<=data(1);
			end if;
		else
			if(address="00") then
				data<=serial_out_buffer(8 downto 1);
			elsif(address="1X") then
				data(0)<=busy;
			end if;
		end if;
	else
		data<="ZZZZZZZZ";
	end if;
end process;

process(transmit_serial_counter)
begin
	if(transmit_serial_counter<10) then
		busy<='1';
	else
		busy<='0';
	end if;
end process;
Tx<=serial_out_buffer(transmit_serial_counter);
INT<=data(1);
end Behavioral;


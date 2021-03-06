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
signal baud_clk_counter: integer range 0 to 2603 := 0; --pour compter le nombre de tics avant de changer l'etat d'horloge

signal transmit_serial_counter: integer range 0 to 11 := 11;--pour savoir a quel bit on est dans la transmition/réception
signal serial_out_buffer : STD_LOGIC_VECTOR(11 downto 0):="110001110101";
signal transmit : std_logic :='0';

signal recieve_serial_counter: integer range 0 to 10 := 10;
signal serial_in_buffer : STD_LOGIC_VECTOR(10 downto 0):="00000000000";
signal busy : std_logic :='0';

signal recieve_finished_flag : std_logic :='0';
signal transmit_finished_flag : std_logic :='0';
signal transmit_finished_flag_aquit : std_logic :='1';
signal transmit_finished_IE : std_logic :='0';
signal recieve_finished_IE : std_logic :='0';


begin

process(CLK,RST,transmit,Rx)
begin
	if(RST='1') then
	elsif((rising_edge(transmit) or falling_edge(Rx)) and busy='0') then
	  baud_clk <='0';
     baud_clk_counter <=0;
	elsif rising_edge(CLK) then
		if (baud_clk_counter = 2603) then
			baud_clk <=NOT(baud_clk);
			baud_clk_counter <=0;
		else
				baud_clk_counter<=baud_clk_counter+1;
		end if;
	end if;	
end process;

process(baud_clk,transmit,RST)
begin
	if(RST='1') then
		transmit_serial_counter<=11;
		transmit_finished_flag_aquit<='0';
	elsif(rising_edge(transmit) and transmit_serial_counter=11 and recieve_serial_counter=10) then
		if(baud_clk='0') then
			transmit_serial_counter<=1;
		else
			transmit_serial_counter<=0;
		end if;
		transmit_finished_flag_aquit<='1';
	elsif(falling_edge(baud_clk)) then
		if(transmit_serial_counter<11) then
			transmit_serial_counter<=transmit_serial_counter+1;
		end if;
	end if;
end process;

process(baud_clk,RST,Rx)
begin
	if(RST='1') then
		recieve_serial_counter<=10;
	elsif(falling_edge(Rx) and recieve_serial_counter=10 and transmit_serial_counter=11) then
		recieve_serial_counter<=0;
	elsif(rising_edge(baud_clk)) then
		if(recieve_serial_counter<10) then
			serial_in_buffer(recieve_serial_counter)<=Rx;
			recieve_serial_counter<=recieve_serial_counter+1;
		end if;
	end if;
end process;


process(transmit_serial_counter,recieve_serial_counter)
begin
	if(transmit_serial_counter<11 or recieve_serial_counter<10) then
		busy<='1';
	else
		busy<='0';
	end if;
end process;

process(transmit_serial_counter,transmit_finished_flag_aquit)
begin
	if(transmit_serial_counter=11 and transmit_finished_flag_aquit='1') then
		transmit_finished_flag<='1';
	else 
	transmit_finished_flag<='0';
	end if;
end process;

data<= serial_in_buffer(8 downto 1) when CS='1' and RW='0' and address="00" else
		 serial_out_buffer(9 downto 2) when CS='1' and RW='0' and address="01" else
		 busy & transmit & transmit_finished_flag &
		 transmit_finished_IE & recieve_finished_flag &
		 recieve_finished_IE & "00" when CS='1' and RW='0' and address="11" else
		 "ZZZZZZZZ" when RW='1';
		 
transmit<= data(1) when CS='1' and RW='1' and address="11" and busy='0';
transmit_finished_flag_aquit<= data(2) when CS='1' and RW='1' and address="11" and busy='0' else 'Z';
transmit_finished_IE<= data(3) when CS='1' and RW='1' and address="11" and busy='0';
recieve_finished_flag<= data(4) when CS='1' and RW='1' and address="11" and busy='0';
recieve_finished_IE<= data(4) when CS='1' and RW='1' and address="11" and busy='0';
serial_out_buffer(9 downto 2)<= data when CS='1' and RW='1' and address="01" and busy='0';


Tx<=serial_out_buffer(transmit_serial_counter);
--INT<=transmit_finished_flag and transmit_finished_IE;
INT<=baud_clk;
end Behavioral;


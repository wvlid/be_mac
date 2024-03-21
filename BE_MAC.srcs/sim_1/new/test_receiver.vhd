----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2024 05:49:57 PM
-- Design Name: 
-- Module Name: test_receiver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_receiver is
--  Port ( );
end test_receiver;

architecture Behavioral of test_receiver is

component receiver is 
port (  
        clk : in std_logic ; 
        reset : in std_logic ; 
    
        RBYTEP : out std_logic ; --pulse 8bits qui reset tout les 8 pulses ?   
        RCLEANP : out std_logic ; --jeter les trames 
        RCVNGP : out std_logic ; -- bit de rcv
        RDATAO : out std_logic_vector(7 downto 0) ; -- bit de data sortie 
        RDONEP : out std_logic ;  -- bit de fin de taches 
        RENABP : in std_logic ; -- quand tu commences à process
        RSMATIP : out std_logic ; -- quand les adresses match 
        RSTARTP : out std_logic ; -- start tache quand on recoir 
        RDATAI : in std_logic_vector(7 downto 0) ; -- on recoit de la data in
        
       
        TABORTP: in std_logic ;    
        TAVAILP : in std_logic ; 
        TDATAI : in std_logic_vector(7 downto 0);
        TDATAO : out std_logic_vector(7 downto 0) ; 
        TDONEP : out std_logic ;  
        TFINISHP : in std_logic ;
        TLASTP : in std_logic ; 
        TREADDP : out std_logic ;
        TRNSMTP : out std_logic;
        TSTARTP : out std_logic;
        TSOCOLP : out std_logic);
         
    --signal recv_address : bit_vector(47 downto 0) ;                                                   
    end component ;  





signal clock : std_logic :='0'; 
signal rst : std_logic ; 
signal rbytep_test : std_logic := '0'; 
signal rcleanp_test : std_logic := '0'; 
signal rcvngp_test : std_logic := '0'; 
signal rdatao_test : std_logic_vector(7 downto 0) ;  
signal rdonep_test : std_logic := '0'; 
signal renabp_test : std_logic := '1'; 
signal rsmatip_test : std_logic := '0'; 
signal rstartp_test : std_logic := '0'; 
signal rdatai_test : std_logic_vector(7 downto 0);

signal tabortp_test : std_logic := '0'; 
signal tavailp_test : std_logic := '0'; 
signal tdatai_test : std_logic_vector(7 downto 0); 
signal tdatao_test : std_logic_vector(7 downto 0) ;  
signal tdonep_test : std_logic := '0'; 
signal tfinishp_test : std_logic := '1'; 
signal tlastp_test : std_logic := '0'; 
signal treaddp_test : std_logic := '0'; 
signal trnsmtp_test : std_logic := '0';
signal tstartp_test : std_logic := '0';
signal tsocolp_test : std_logic := '0';


constant Periode : time :=100ns ;

begin



rcv : receiver port map(clk => clock,
                        reset =>rst,
                        
                        rbytep => rbytep_test,
                        rcleanp => rcleanp_test,
                        rcvngp => rcvngp_test,
                        rdatao =>rdatao_test,
                        rdonep=> rdonep_test,
                        renabp => renabp_test,
                        rsmatip=>rsmatip_test, 
                        rstartp =>rstartp_test, 
                        rdatai=> rdatai_test,
                        
                        tabortp => tabortp_test, 
                        tavailp => tavailp_test,   
                        tdatai=>tdatai_test,
                        tdatao => tdatao_test,   
                        tdonep =>tdonep_test,
                        tfinishp => tfinishp_test,  
                        tlastp => tlastp_test,
                        treaddp => treaddp_test, 
                        trnsmtp => trnsmtp_test,
                        tstartp => tstartp_test,
                        tsocolp => tsocolp_test);
                        


clock_process : process
begin
    clock <= not(clock) ; 
    wait for Periode/2; 
end process ; 

renabp_test <= '1' ; 
rdatai_test <= "10101011", "00100000" after 900 ns,"00010000" after 1600 ns, "00001000" after 2400 ns, "00000100" after 3200 ns, "00000010" after 4000 ns, "00000001" after 4800 ns,"00000000" after 5600 ns, "10101011" after 6400 ns;
rst <='0', '1' after 200 ns ;

tavailp_test <= '1';
trnsmtp_test <= '1';
tabortp_test <= '0';
tsocolp_test <= '0';
tfinishp_test <= '0', '1' after 1500 ns;

tdatai_test<= "00001010","11000011" after 800 ns; 




end Behavioral;

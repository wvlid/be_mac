----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2024 09:34:00 AM
-- Design Name: 
-- Module Name: main_process - Behavioral
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity receiver is
    port(
    
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
        
         
        
end receiver;






architecture Behavioral of receiver is

    signal rcvngp_aux : std_logic := '0'; 
    signal rsmatip_aux : std_logic := '0';
    signal trnsmtp_aux : std_logic := '0';
    signal tsocolp_aux : std_logic := '0';
    signal cpt : integer := 0 ;
    signal compteur : integer := 0 ;
    constant host_address : std_logic_vector(47 downto 0) := "001000000001000000001000000001000000001000000001" ; 
                                                     --"00100000 00010000 00001000 00000100 00000010 00000001"
    constant dest_address : std_logic_vector(47 downto 0) := "111100001111000011110000111100001111000011110000" ;
                                                      --"11110000"
     
    
begin


reception : process

    variable i: integer :=0;

begin

    wait until clk'Event and clk='1' ;
    rstartp <='0';
    rdonep <= '0';
    rcleanp <= '0';
    rbytep <= '0';
    
    if reset= '0' then 
        rsmatip_aux <= '0';
        rcvngp_aux <= '0';
        rbytep<='0';
        i := 5;
        cpt <= 0;
        
    else
        if (renabp ='1') then 
            
            if (cpt = 0) then
            
                if (RDATAI ="10101011" and rcvngp_aux = '0') then
                    rstartp <= '1';
                    rcvngp_aux <= '1' ; 
                elsif (rcvngp_aux ='1' and rsmatip_aux ='0') then
                    if (host_address(7+8*i downto 8*i) = rdatai) then
                        if (i = 0) then 
                            i := 5;
                            rsmatip_aux <= '1';    
                        else 
                            i := i -1;
                        end if; -- end if cpt nb octets adr dest
                    else
                        rcvngp_aux <= '0';
                    end if; --rsmatip
                elsif  rsmatip_aux = '1' then 
                    if rdatai /= "10101011" then 
                        rdatao <= rdatai;
                        rbytep<='1';
                    else 
                        rdonep <='1';
                        rcvngp_aux <= '0';
                        rsmatip_aux <= '0';
                        RDATAO<= "ZZZZZZZZ";
                    end if; -- trm rdatao 
                end if; -- SFT , rec ok
                
                cpt <= cpt +1;
                
            elsif (cpt = 7) then
                cpt <= 0;
            
            
            else 
                cpt <= cpt +1;
            
            end if;
            
        end if;
    end if;
        
end process ;




transmission : process

    variable i: integer :=0;
    variable d :integer :=0;

begin

    wait until clk'Event and clk='1' ;
    tstartp <='0';
    --trnsmtp_aux <= '0';
    tdonep <= '0';
    treaddp <= '0';
 

    
    if reset= '0' then 
        i := 5;
        d := 0;
        tstartp <='0';
        trnsmtp_aux<= '0';
        tdonep <= '0';
        treaddp <= '0'; 
        compteur <= 0;      
    else
        if (compteur = 0) then 
            if (tavailp ='1') then
                tstartp <= '1';
                trnsmtp_aux <= '1';
                tdatao <= "10101011"; -- SFD
                
                if trnsmtp_aux = '1' then
                    if (tabortp ='1' and tsocolp_aux='1') then
                        trnsmtp_aux <= '0';
                    else
                        if (d=0) then
                            tdatao <= dest_address(7+8*i downto 8*i);
                            treaddp <= '1';
                            i := i-1;
                            if(i = 0) then 
                                d := 1;
                            end if;
                        else
                            tdatao <=host_address(7+8*i downto 8*i);
                            treaddp <= '1';
                            i := i-1;
                        end if;
                        if (tfinishp = '0') then
                            tdatao <= tdatai;
                        else
                            tdatao <="10101011"; --EFD
                            trnsmtp_aux<= '0';
                            tdonep <= '1', '0' after 100 ns;
                             
                        end if;
                    end if;
                end if;
            end if;
            compteur <= compteur +1;
        elsif (compteur = 7) then
                compteur <= 0;
        else
            compteur <= compteur +1;
         
        end if;
    end if;
        
end process ;



collision: process
begin

    wait until clk'Event and clk='1' ;
    if (rcvngp_aux = '1' and trnsmtp_aux='1') then
        tsocolp_aux <= '1';
    end if;
end process;
    


tsocolp <= tsocolp_aux;
trnsmtp<=trnsmtp_aux;
RCVNGP <= rcvngp_aux;
RSMATIP <= rsmatip_aux;

end Behavioral;

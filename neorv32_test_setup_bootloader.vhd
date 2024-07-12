library ieee;
use ieee.std_logic_1164.all;

-- UART Sender Example Entity
entity uart_sender_example is
    port (
        clk : in std_logic;
        rst : in std_logic;
        uart0_txd_o : out std_logic
    );
end entity uart_sender_example;

architecture rtl of uart_sender_example is
    signal tx_data : std_logic_vector(7 downto 0) := "01000001"; -- 'A' in ASCII
begin
    process (clk, rst)
    begin
        if rst = '1' then
            uart0_txd_o <= '0'; -- Initialize to idle state
        elsif rising_edge(clk) then
            uart0_txd_o <= tx_data(0); -- Send the least significant bit of 'A'
        end if;
    end process;
end architecture rtl;

-- Main Design Entity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_test_setup_bootloader is
  generic (
    CLOCK_FREQUENCY   : natural := 48000000; -- clock frequency of clk48 in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 8*1024     -- size of processor-internal data memory in bytes
  );
  port (
    clk48       : in  std_ulogic; -- global clock, rising edge
    usr_btn     : in  std_ulogic; -- global reset, low-active, async
    gpio_0      : out std_ulogic; -- UART0 send data
    gpio_1      : in  std_ulogic; -- UART0 receive data
    rgb_led0_r  : out std_logic; -- red channel
    rgb_led0_g  : out std_logic; -- green channel
    rgb_led0_b  : out std_logic  -- blue channel
  );
end entity neorv32_test_setup_bootloader;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is

  signal con_gpio_o : std_ulogic_vector(63 downto 0);

  -- Instantiate UART sender
  uart_sender_inst: uart_sender_example
    port map (
      clk        => clk48,
      rst        => usr_btn,
      uart0_txd_o => gpio_0 -- Send data through UART TX line
    );

begin

  -- Instantiate the NEORV32 core
  neorv32_top_inst: neorv32_top
    generic map (
      CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk48 in Hz
      INT_BOOTLOADER_EN            => true,              -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
      CPU_EXTENSION_RISCV_C        => true,              -- implement compressed extension?
      CPU_EXTENSION_RISCV_M        => true,              -- implement mul/div extension?
      CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
      MEM_INT_IMEM_EN              => true,              -- implement processor-internal instruction memory
      MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
      MEM_INT_DMEM_EN              => true,              -- implement processor-internal data memory
      MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
      IO_GPIO_NUM                  => 8,                 -- number of GPIO input/output pairs (0..64)
      IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
      IO_UART0_EN                  => true               -- implement primary universal asynchronous receiver/transmitter (UART0)?
    )
    port map (
      clk_i       => clk48,       -- global clock, rising edge
      rstn_i      => usr_btn,     -- global reset, low-active, async
      gpio_o      => con_gpio_o,  -- parallel output
      uart0_txd_o => gpio_0,      -- UART0 send data
      uart0_rxd_i => gpio_1       -- UART0 receive data
    );

  -- GPIO output --
  rgb_led0_b <= not con_gpio_o(0);
  rgb_led0_r <= '1';
  rgb_led0_g <= '1';

end architecture neorv32_test_setup_bootloader_rtl;

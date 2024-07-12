library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    signal tx_counter : integer := 0; -- Counter to manage transmission timing
begin
    process (clk, rst)
    begin
        if rst = '1' then
            uart0_txd_o <= '0'; -- Initialize to idle state
            tx_counter <= 0;
        elsif rising_edge(clk) then
            if tx_counter < 8 then
                uart0_txd_o <= tx_data(tx_counter); -- Send the bit of 'A'
                tx_counter <= tx_counter + 1;
            else
                tx_counter <= 0; -- Reset counter after sending all bits
            end if;
        end if;
    end process;
end architecture rtl;

-- UART Receiver Example Entity
entity uart_receiver_example is
    port (
        clk : in std_logic;
        rst : in std_logic;
        uart0_rxd_i : in std_logic;
        received_char : out std_logic_vector(7 downto 0);
        led : out std_logic
    );
end entity uart_receiver_example;

architecture rtl of uart_receiver_example is
    signal rx_data : std_logic_vector(7 downto 0) := (others => '0');
begin
    process (clk, rst)
    begin
        if rst = '1' then
            rx_data <= (others => '0');
        elsif rising_edge(clk) then
            rx_data <= rx_data(6 downto 0) & uart0_rxd_i; -- Shift in received bit
        end if;
    end process;

    received_char <= rx_data;
    led <= rx_data(0); -- Display the least significant bit on an LED (for demonstration)
end architecture rtl;

-- NEORV32 Test Setup Bootloader Entity
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
  uart_sender_inst: entity work.uart_sender_example
    port map (
      clk        => clk48,
      rst        => usr_btn,
      uart0_txd_o => gpio_0
    );

  -- Instantiate UART receiver
  uart_receiver_inst: entity work.uart_receiver_example
    port map (
      clk          => clk48,
      rst          => usr_btn,
      uart0_rxd_i  => gpio_1,
      received_char => open, -- Connect this to your desired logic
      led          => rgb_led0_g -- Display the received bit on an LED (for demonstration)
    );

  -- ... (Other existing architecture code)

end architecture neorv32_test_setup_bootloader_rtl;

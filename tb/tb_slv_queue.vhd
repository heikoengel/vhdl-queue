--====================================================================--
-- tb_slv_queue.vhd
--====================================================================--
--
-- Copyright (C) 2021 Heiko Engel
--
-- This source file may be used and distributed without restriction provided
-- that this copyright statement is not removed from the file and that any
-- derivative work contains the original copyright notice and the associated
-- disclaimer.
--
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version.
--
-- This source is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
-- for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
--
-- Date: 2021-12-18
--
--====================================================================--
library ieee;
use ieee.std_logic_1164.all;

package SlvQueue is
  new work.queue_pkg generic map(ItemType => std_logic_vector(31 downto 0));

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.SlvQueue.all;

entity tb_slv_queue is

end entity tb_slv_queue;

architecture sim of tb_slv_queue is

  signal asd : std_logic_vector(31 downto 0);
  shared variable queue : Queue;

begin  -- architecture sim

  STIMULI_P : process is
    variable data : std_logic_vector(31 downto 0);
  begin  -- process STIMULI_P
    -- expect queue to be empty
    assert (queue.size = 0) report "Queue not empty" severity error;

    ---------------------------------------------------------------------------
    report "Testing push/pop front/back" severity note;
    ---------------------------------------------------------------------------
    -- add one entry
    queue.push_back(x"0000_0000");
    assert queue.size = 1 report "Queue not empty" severity error;
    -- read back entry
    data := queue.pop_back;
    assert data = x"0000_0000" report "Unexpected queue output" severity error;
    assert queue.size = 0 report "Queue not empty" severity error;
    -- add 3 entries in total from both sides
    queue.push_back(x"0000_0001");
    queue.push_front(x"0000_0002");
    queue.push_back(x"0000_0003");
    -- pop all 3 entries from the front
    assert queue.size = 3 report "unexpected queue size" severity error;
    assert queue.pop_front = x"0000_0002" report "unexpected queue output" severity error;
    assert queue.size = 2 report "unexpected queue size" severity error;
    assert queue.pop_front = x"0000_0001" report "unexpected queue output" severity error;
    assert queue.size = 1 report "unexpected queue size" severity error;
    assert queue.pop_front = x"0000_0003" report "unexpected queue output" severity error;
    assert queue.size = 0 report "unexpected queue size" severity error;

    ---------------------------------------------------------------------------
    report "Testing queue.insert" severity note;
    ---------------------------------------------------------------------------
    -- insert at front
    queue.insert(0, x"0000_0123");
    assert queue.size = 1 report "unexpected queue size" severity error;
    -- insert at out of range index, no change
    queue.insert(2, x"0000_0124");
    assert queue.size = 1 report "unexpected queue size" severity error;
    -- insert at 1
    queue.insert(1, x"0000_0125");
    assert queue.size = 2 report "unexpected queue size" severity error;
    -- insert another entry at 1
    queue.insert(1, x"0000_0126");
    -- queue should now contain [0x123, 0x126, 0x125]
    assert queue.size = 3 report "unexpected queue size" severity error;
    assert queue.pop_front = x"0000_0123" report "unexpected queue output" severity error;
    assert queue.pop_front = x"0000_0126" report "unexpected queue output" severity error;
    assert queue.pop_back = x"0000_0125" report "unexpected queue output" severity error;

    ---------------------------------------------------------------------------
    report "Testing queue.delete" severity note;
    ---------------------------------------------------------------------------
    assert queue.size = 0 report "unexpected queue size" severity error;
    -- delete from emtpy queue, no change
    queue.delete(0);
    assert queue.size = 0 report "unexpected queue size" severity error;
    -- fill queue with 6 values
    for i in 0 to 5 loop
      queue.push_back(std_logic_vector(to_unsigned(i, 32)));
    end loop;  -- i
    assert queue.size = 6 report "unexpected queue size" severity error;
    -- delete [0] = 0
    queue.delete(0);
    assert queue.size = 5 report "unexpected queue size" severity error;
    -- delete [1] = 2
    queue.delete(1);
    assert queue.size = 4 report "unexpected queue size: "  & integer'image(queue.size)  severity error;
    assert queue.pop_front = x"0000_0001" report "unexpected queue output" severity error;
    assert queue.size = 3 report "unexpected queue size: "  & integer'image(queue.size)  severity error;
    -- delete from out-of-range indices, expect no change
    queue.delete(100);
    queue.delete(queue.size);
    assert queue.size = 3 report "unexpected queue size: "  & integer'image(queue.size)  severity error;

    report "Testbench done" severity note;
    wait;
  end process STIMULI_P;

end architecture sim;

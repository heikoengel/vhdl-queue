# Generic VHDL Queue Implementation

Generic VHDL Queue implementation losely aligned to SystemVerilog
queues. The package is parametrized with the queue entry data type, so
it can be used with any VHDL data type. Examples could be queues of
`integer`, `std_logic_vector`, `real`, records or custom types.

## Methods

| Method      | Description                                            |
| ---         | ---                                                    |
| size        | returns the number of items in the queue               |
| insert      | inserts the given item at the specified index position |
| delete      | deletes the item at the specified index position       |
| push\_front | inserts the given element at the front of the queue    |
| push\_back  | inserts the given element at the end of the queue      |
| pop\_front  | removes and returns the first element of the queue     |
| pop\_back   | removes and returns the last element of the queue      |

## Examples

### Queue of `integer`
```VHDL
package IntegerQueue is
  new work.queue_pkg generic map(ItemType => integer);
```

### Queue of `std_logic_vector`
```VHDL
package SlvQueue is
  new work.queue_pkg generic map(ItemType => std_logic_vector(31 downto 0));
```

### Integer queue usage example
```VHDL
  QUEUE_IF_P : process is
    variable queue : Queue;
    variable data : integer;
  begin
    -- add integers 0 to 9 at the end of the queue
    for i in range 0 to 9 loop
      queue.push_back(i);
    end loop;
    -- add another entry to the start of the queue
    queue.push_front(1);
    -- get the first entry from the front
    data := queue.pop_front;
    -- get the last entry
    data := queue.pop_back;
    -- get the number of items in the queue
    data := queue.size;
    -- remove the 3rd item
    queue.remove(2);
    [...]
```

See full examples in the `tb` subfolder.

## Running the testbenches

Example usage with Model/QuestSim:

```bash
vcom -2008 pkg/queue_pkg.vhd tb/tb_integer_queue.vhd tb/tb_slv_queue.vhd
vsim -c work.tb_slv_queue -do "run 10 ns; q -f"
vsim -c work.tb_integer_queue -do "run 10 ns; q -f"
```

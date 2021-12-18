--====================================================================--
-- queue_pkg.vhd
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

package queue_pkg is

  generic (
    type ItemType);

  type Queue is protected

    -- inserts the given element at the front of the queue
    procedure push_front (
      data : in ItemType);

    -- inserts the given element at the end of the queue
    procedure push_back (
      data : in ItemType);

    -- removes and returns the last element of the queue
    impure function pop_back
      return ItemType;

    -- removes and returns the first element of the queue
    impure function pop_front
      return ItemType;

    -- inserts the given item at the specified index position
    procedure insert (
      index : in natural;
      data  : in ItemType);

    -- returns the number of items in the queue
    impure function size
      return natural;

    -- deletes the item at the specified index position
    procedure delete (
      index : in natural);

  end protected;


end package queue_pkg;

package body queue_pkg is

  type Queue is protected body

  type QueueItem;
  type ItemPtr is access QueueItem;

  type QueueItem is record
    data      : ItemType;
    next_item : ItemPtr;
  end record QueueItem;

  variable root : ItemPtr := null;

  -----------------------------------------------------------------------------
  -- pop_front(): removes and returns the first element of the queue
  -----------------------------------------------------------------------------
  impure function pop_front
    return ItemType is
    variable data : ItemType;
    variable item : ItemPtr := root;
  begin  -- function pop_front
    if item /= null then
      data := item.data;
      root := item.next_item;
      deallocate(item);
    else
      report "Queue.pop_front on emtpy queue" severity warning;
    end if;
    return data;
  end function pop_front;

  -----------------------------------------------------------------------------
  -- pop_back(): removes and returns the last element of the queue
  -----------------------------------------------------------------------------
  impure function pop_back
    return ItemType is
    variable data : ItemType;
    variable item : ItemPtr := root;
  begin  -- function pop_back
    if item = null then
      report "Queue.pop_back on empty queue" severity warning;
      return data;
    end if;
    if item.next_item = null then
      -- only one item in the queue
      data := item.data;
      deallocate(item);
      root := null;
      return data;
    end if;

    -- go to the 2nd last item in the queue
    while item.next_item.next_item /= null loop
      item := item.next_item;
    end loop;
    -- return the data from the last item and remove it
    data           := item.next_item.data;
    deallocate(item.next_item);
    item.next_item := null;
    return data;
  end function pop_back;

  -----------------------------------------------------------------------------
  -- push_back(data): inserts the given element at the end of the queue
  -----------------------------------------------------------------------------
  procedure push_back (
    data : in ItemType) is
    variable item    : ItemPtr := root;
    variable newItem : ItemPtr;
  begin  -- procedure push_back
    -- prepre new item
    newItem           := new QueueItem;
    newItem.data      := data;
    newItem.next_item := null;
    -- Queue is empty, add newItem as the first item
    if item = null then
      root := newItem;
      return;
    end if;
    -- Queue is not empty, iterate to the end of the list
    while item.next_item /= null loop
      item := item.next_item;
    end loop;
    -- append item to the queue
    item.next_item := newItem;
  end procedure push_back;

  -----------------------------------------------------------------------------
  -- push_front(): inserts the given element at the front of the queue
  -----------------------------------------------------------------------------
  procedure push_front (
    data : in ItemType) is
    variable item    : ItemPtr := root;
    variable newItem : ItemPtr;
  begin  -- procedure push_front
    newItem           := new QueueItem;
    newItem.data      := data;
    newItem.next_item := root;
    root              := newItem;
  end procedure push_front;

  -----------------------------------------------------------------------------
  -- insert(index, data): inserts the given item at the specified index position
  -----------------------------------------------------------------------------
  procedure insert (
    index : in natural;
    data  : in ItemType) is
    variable item    : ItemPtr := root;
    variable i : natural;
    variable newItem : ItemPtr;
  begin  -- procedure insert
    newItem           := new QueueItem;
    newItem.data      := data;
    if index = 0 then
      -- insert at the front
      newItem.next_item := root;
      root := newItem;
      return;
    end if;
    if item = null then
      report "Queue.insert index out of range - index: " & integer'image(index) &
        " size: " & integer'image(size) severity warning;
      return;
    end if;

    i := 0;
    while item /= null loop
      if i = index - 1 then
        -- one before the target position: insert as next
        newItem.next_item := item.next_item;
        item.next_item := newItem;
        return;
      end if;
      i := i + 1;
      item := item.next_item;
    end loop;
    report "Queue.insert index out of range - index: " & integer'image(index) &
      " size: " & integer'image(size) severity warning;
  end procedure insert;

  -----------------------------------------------------------------------------
  -- size: returns the number of items in the queue
  -----------------------------------------------------------------------------
  impure function size
    return natural is
    variable item  : ItemPtr := root;
    variable items : natural;
  begin  -- function size
    items := 0;
    while item /= null loop
      items := items + 1;
      item  := item.next_item;
    end loop;
    return items;
  end function size;

  -----------------------------------------------------------------------------
  -- deletes the item at the specified index position
  -----------------------------------------------------------------------------
  procedure delete (
    index : in natural) is
    variable item  : ItemPtr := root;
    variable tmp_ptr : ItemPtr;
    variable i : natural;
  begin -- procedure delete
    if item = null or (item.next_item = null and index > 0)  then
      report "Queue.delete index out of range - index: " & integer'image(index) &
        " size: " & integer'image(size) severity warning;
      return;
    end if;
    if index = 0 then
      if item.next_item = null then
        -- delete the only item
        deallocate(item);
        root := null;
        return;
      else
        -- delete first item
        root := item.next_item;
        deallocate(item);
        return;
      end if;
    end if;

    i := 0;
    while item /= null loop
      if i = index - 1 then
        -- one before the target index
        if item.next_item /= null then
          -- not the last item in the queue: update pointers to skip the next
          -- item and delete it.
          tmp_ptr := item.next_item.next_item;
          deallocate(item.next_item);
          item.next_item := tmp_ptr;
          return;
        else
          report "Queue.delete index out of range - index: " & integer'image(index) &
            " size: " & integer'image(size) severity warning;
          return;
        end if;
      end if;
      item := item.next_item;
      i    := i + 1;
    end loop;
    report "Queue.delete index out of range - index: " & integer'image(index) &
      " size: " & integer'image(size) severity warning;
  end procedure delete;

  end protected body;

end package body queue_pkg;

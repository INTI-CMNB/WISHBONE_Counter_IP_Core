Copyright (c) 2005 Juan Pablo D. Borgna <jpborgna en inti.gov.ar>
Copyright (c) 2006 Salvador E. Tropea <salvador en inti gov ar>
Copyright (c) 2005-2006 Instituto Nacional de Tecnología Industrial

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 2.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 02111-1307, USA

  This counter generate a pulse after counting a determined ammount of clock
pulses.
  It have two 8 bits registers to indicate the ammount of pulses to count.
Using a generic you can configure the counter width from 8 to 16 bits.
  You must load the high byte first because the value to count is loaded after
the low byte is loaded. During the first count you'll lose one clock pulse.

Registers:
----------

All are 8 bits.

Address   | Mode | Name        | Description
-----------------------------------------------------------------------------
    0     |   W  | SCOUNTER_LO | Divisor Low
-----------------------------------------------------------------------------
    1     |   W  | SCOUNTER_HI | Divisor High
-----------------------------------------------------------------------------

Generics:
---------

MOD_WIDTH integer range 9 to 16:=16; -- Bits for the counter (9 a 16)
MOD_START : integer:=0;              -- Starting divisor (after reset)



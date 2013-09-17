/'
 ' FROST x86 microkernel
 ' Copyright (C) 2010-2013  Stefan Schmidt
 ' 
 ' This program is free software: you can redistribute it and/or modify
 ' it under the terms of the GNU General Public License as published by
 ' the Free Software Foundation, either version 3 of the License, or
 ' (at your option) any later version.
 ' 
 ' This program is distributed in the hope that it will be useful,
 ' but WITHOUT ANY WARRANTY; without even the implied warranty of
 ' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ' GNU General Public License for more details.
 ' 
 ' You should have received a copy of the GNU General Public License
 ' along with this program.  If not, see <http://www.gnu.org/licenses/>.
 '/

#include "debug.bi"
#include "kernel.bi"
#include "video.bi"

namespace debug
    
    '' this function allows a loglevel to be set which is used by a wrapper for the video-code
    sub set_loglevel (level as ubyte)
        loglevel = level
    end sub
    
    #if defined (FROST_DEBUG)
		dim shared com_initialized as boolean = false
		
		sub init_com (baseport as ushort, baud as uinteger, parity as ubyte, bits as ubyte)
			baud = 115200\baud
			
			out(baseport+1, 0)
			
			out(baseport+3, &h80)
			
			out(baseport, lobyte(baud))
			out(baseport+1, hibyte(baud))
			
			out(baseport+3, ((parity and &h07) shl 3) or ((bits-5) and &h03))
			
			out(baseport+2, &hC7)
			out(baseport+4, &h0B)
		end sub
		
		sub serial_init ()
			init_com(&h3F8, 19200, 0, 8)
			com_initialized = true
		end sub
		
		sub serial_putc (char as ubyte)
			if (com_initialized) then
				while((inp(&h3F8+5) and &h20) = 0) : wend
				out(&h3F8, char)
			end if
		end sub
	#endif
end namespace

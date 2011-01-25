ULINETSOCKET

An Objective-C asynchronous TCP socket class based on NetSocket by Dustin Mierau. It can simplify and even speed up networking in your application. NetSocket buffers both reads and writes behind the scenes, this allows you to read the data at the most convenient time and not worry if a call to send will block or not. Through a series of callbacks, a delegate is notified of socket events ( e.g. connected, disconnected, data available ). To make all of this possible, NetSocket uses new MacOS X networking APIs, mainly CFSocket ( part of the CoreFoundation CFNetwork API ).


LICENSE

This code is released under the zlib license:

	Copyright Dustin Mierau.
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	   1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.

	   2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.

	   3. This notice may not be removed or altered from any source
	   distribution.

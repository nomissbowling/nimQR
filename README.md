nimQR
=====

Nim QR code generator scanner lib zbar


Requirements
------------

- include and link as submodules

	- QR-Code-generator (test v1.8.0) source [https://github.com/nayuki/QR-Code-generator]( https://github.com/nayuki/QR-Code-generator )
	- zbar (test 0.23.91) source [https://github.com/mchehab/zbar]( https://github.com/mchehab/zbar )
		- zbar binaries [https://linuxtv.org/downloads/zbar/binaries/]( https://linuxtv.org/downloads/zbar/binaries/ )
			- libzbar
			- libiconv


- depends on other nim packages

	- pixie (read/write PNG etc) [https://github.com/treeform/pixie]( https://github.com/treeform/pixie )
	- pixie/imageplanes (clone fork from https://github.com/nomissbowling/pixie.git) [https://github.com/nomissbowling/pixie/tree/ImagePlane]( https://github.com/nomissbowling/pixie/tree/ImagePlane )
	- stdnim (bindings to C++ std classes for Nim) [https://github.com/nomissbowling/stdnim]( https://github.com/nomissbowling/stdnim )


License
-------

MIT License

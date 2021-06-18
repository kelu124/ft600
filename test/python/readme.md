pi@upw:~ $ echo Y | sudo tee /sys/module/usbcore/parameters/old_scheme_first
Y
pi@upw:~ $ cat /sys/module/usbcore/parameters/old_scheme_first
Y
pi@upw:~ $ echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend
-1
pi@upw:~ $ cat /sys/module/usbcore/parameters/autosuspend
-1


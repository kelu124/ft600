sudo rm /usr/lib/libftd3xx.so
sudo cp libftd3xx.so /usr/lib/
sudo cp libftd3xx.so.0.6.2 /usr/lib/
sudo cp 51-ftd3xx.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo ldconfig -v

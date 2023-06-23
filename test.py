from srcs.HID.Keyboard import Keyboard

k = Keyboard('./srcs/HID/keymaps/EN.json')
k.write("Hello World")
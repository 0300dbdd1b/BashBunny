import time
import sys
import os

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from HID.Mouse import Mouse
from HID.Keyboard import Keyboard

class DuckyInterpreter:
	def __init__(self, keyboard, mouse):
		self.mouse = mouse
		self.keyboard = keyboard
		self.commands = {
			'STRING': self.__type_string__,
			'DELAY': self.__delay__,
			'REM': self.__rem__,
			'//': self.__rem__,
		}
		self.special_keys = ['ENTER', 'SPACE', 'CTRL', 'ALT', 'SHIFT', 'WINDOWS', 'COMMAND', 'ESC', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12']
	def __type_string__(self, params):
		return self.keyboard.write(' '.join(params))
			
	def __delay__(self, params):
		time.sleep(int(params[0])/1000)
		return True
	
	def __rem__(self, params):
		return True

	def __handle_special_keys__(self, command, params):
		if command == 'WINDOWS' or command == 'COMMAND':
			if params:
				return self.keyboard.inject_custom_keystroke('META', params[0])
			else:
				return self.keyboard.inject_keystroke('META')
		else:
			if params:
				return self.keyboard.inject_custom_keystroke(command, params[0])
			else:
				return self.keyboard.inject_keystroke(command)

	def __execute_line__(self, line):
		parts = line.split()
		if parts:
			command = parts[0]
			params = parts[1:]
			if command in self.commands:
				if self.commands[command](params):
					return True
				else:
					print(f"Can't process line : {line}")
					return False
			elif command in self.special_keys:
				if self.__handle_special_keys__(command, params):
					return True
				else:
					print(f"Can't process line : {line}")
					return False
			else:
				print(f"Unknown command : {command}")
				return False
		else:
			return True

	def execute(self, script_path):
			with open(script_path, 'r') as f:
				for line in f.read().splitlines():
					if self.__execute_line__(line) == False:
						return False
				return True

if __name__ == "__main__":
	if len(sys.argv) == 2:
		script_path = sys.argv[1]
		keyboard = Keyboard(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'HID', 'keymaps', 'EN.json'))  # replace with your keymap file
		mouse = Mouse()
		interpreter = DuckyInterpreter(keyboard, mouse)
		if not interpreter.execute(script_path):
			print("Script execution failed.")
		else:
			print("Script executed successfully.")
	else:
		keyboard = Keyboard(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'HID', 'keymaps', 'EN.json'))  # replace with your keymap file
		mouse = Mouse()
		interpreter = DuckyInterpreter(keyboard, mouse)
		while True:
			line = input(">> ")
			if line == 'EXIT':
				break
			interpreter.__execute_line__(line)



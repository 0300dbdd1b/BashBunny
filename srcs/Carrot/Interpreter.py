import time
import sys
import os

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from HID.Mouse import Mouse
from HID.Keyboard import Keyboard

class CarrotInterpreter:
	def __init__(self, keyboard, mouse):
		self.mouse = mouse
		self.keyboard = keyboard
		self.commands = {
			'STRING': self.__type_string__,
			'DELAY': self.__delay__,
			'REM': self.__rem__,
			'//': self.__rem__,
			'ENTER': self.__enter__,
			'SPACE': self.__space__,
			'CTRL': self.__ctrl__,
			'WINDOWS': self.__gui__,
			'COMMAND': self.__gui__
		}

	def __type_string__(self, params):
		return self.keyboard.write(''.join(params))
			
	def __delay__(self, params):
		time.sleep(int(params[0])/1000)
		return True
	
	def __rem__(self, params):
		return True
	
	def __enter__(self, params):
		return self.keyboard.inject_keystroke('ENTER')
	
	def __space__(self, params):
		return self.keyboard.inject_keystroke('SPACE')
	
	def __ctrl__(self, params):
		if not params[0]:
			return self.keyboard.inject_keystroke('CTRL')
		else:
			return self.keyboard.inject_custom_keystroke('CTRL', params[0])

	def __gui__(self, params):
		if not params[0]:
			return self.keyboard.inject_keystroke('META')
		else:
			return self.keyboard.inject_custom_keystroke('META', params[0])

	def __execute_line__(self, line):
		parts = line.split()
		command = parts[0]
		params = parts[1:]
		if command in self.commands:
			if self.commands[command](params):
				return True
			else:
				print(f"Can't process line : {line}")
				return False
		else:
			print(f"Unknown command : {command}")
	
	def execute(self, script_path):
			with open(script_path, 'r') as f:
				for line in f.read().splitlines():
					if self.__execute_line__(line) == False:
						return False
				return True

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("Usage: python3 Interpreter.py <script_path>")
		exit

	script_path = sys.argv[1]
	keyboard = Keyboard(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'HID', 'keymaps', 'EN.json'))  # replace with your keymap file
	mouse = Mouse()
	interpreter = CarrotInterpreter(keyboard, mouse)

	if not interpreter.execute(script_path):
		print("Script execution failed.")
	else:
		print("Script executed successfully.")
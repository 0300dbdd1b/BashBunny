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
			'ENTER': self.__enter__
		}

	def __type_string__(self, params):
		self.keyboard.write(''.join(params))
		return True
	
	def __delay__(self, params):
		time.sleep(int(params[0])/1000)
		return True
	
	def __rem__(self, params):
		return True
	
	def __enter__(self, params):
		self.keyboard.write('\n')
		return True
	
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

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("Usage: python3 CarrotInterpreter.py <script_path>")
		exit

	script_path = sys.argv[1]
	keyboard = Keyboard("keymap.json")  # replace with your keymap file
	mouse = Mouse()
	interpreter = CarrotInterpreter(keyboard, mouse)

	if not interpreter.execute(script_path):
		print("Script execution failed.")
		exit
	print("Script executed successfully.")
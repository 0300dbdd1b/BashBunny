class Mouse:
	def __init__(self):
		return

	def write_report(self, report):
		with open('/dev/hidg1', 'wb') as fd:
			fd.write(report)

	def move(self, x, y):
		# Check that values are in valid range
		assert -127 <= x <= 127
		assert -127 <= y <= 127

		# Send report
		self.write_report(bytes([0x00, x, y, 0x00]))

	def click(self, button):
		"""Clicks a mouse button. 
		1 = left
		2 = right
		3 = middle
		"""
		# Check that button is a valid value
		assert 1 <= button <= 3

		# Send report for button press
		self.write_report(bytes([button, 0x00, 0x00, 0x00]))
		# Send report for button release
		self.write_report(bytes([0x00, 0x00, 0x00, 0x00]))

	def scroll(self, value):
		"""Scrolls the wheel. Positive for up, negative for down."""
		assert -127 <= value <= 127
		# Send report for scroll
		self.write_report(bytes([0x00, 0x00, 0x00, value]))

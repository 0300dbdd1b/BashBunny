import json 

MODIFIERS = {
    'CTRL': 0x01,
    'SHIFT': 0x02,
    'ALT': 0x04,
    'META': 0x08,
    'RIGHTCTRL': 0x10,
    'RIGHTSHIFT': 0x20,
    'RIGHTALT': 0x40,
    'RIGHTMETA': 0x80,
}

class Keyboard:
    def __init__(self, json_filepath):
        self.load_keymap(json_filepath)
    
    def load_keymap(self, filepath):
        with open(filepath, 'r') as file:
            self.keymap = json.load(file)
        return self.keymap
    
    def write_report(self, report):
        with open('/dev/hidg0', 'wb') as fd:
            fd.write(report)
    
    def inject_keystroke(self, keystroke):
        modifiers = []
        keys = keystroke.split('+')
        for key in keys:
            if key in self.keymap:
                keycode = self.keymap[key]['keycode']
                modifier = self.keymap[key]['modifier']
                
                if modifier != "NONE" and modifier not in modifiers:
                    modifiers.append(modifier)
        
        report = bytearray([0] * 8)
        for modifier in modifiers:
            report[0] |= MODIFIERS.get(modifier, 0)
        
        if keys:
            last_key = keys[-1]
            if last_key in self.keymap:
                keycode = self.keymap[last_key]['keycode']
                report[2] = int(keycode, 16)
        
        self.write_report(report)
        
        # Release keys
        report = bytearray([0] * 8)
        self.write_report(report)
    
    def write(self, string):
        for char in string:
            if char == '\t':
                self.inject_keystroke('TAB')
            elif char == '\n':
                self.inject_keystroke('ENTER')
            elif char in self.keymap:
                self.inject_keystroke(char)
            else:
                print("Unknown Keymap")

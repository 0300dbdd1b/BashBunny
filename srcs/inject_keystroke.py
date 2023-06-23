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

def load_keymap(filepath):
    with open(filepath, 'r') as file:
        keymap = json.load(file)
    return keymap

def write_report(report):
    with open('/dev/hidg0', 'wb') as fd:
        fd.write(report)

def inject_keystroke(filepath, keystroke):
    keymap = load_keymap(filepath)
    
    modifiers = []
    keys = keystroke.split('+')
    for key in keys:
        if key in keymap:
            keycode = keymap[key]['keycode']
            modifier = keymap[key]['modifier']
            
            if modifier != "NONE" and modifier not in modifiers:
                modifiers.append(modifier)

    report = bytearray([0] * 8)
    for modifier in modifiers:
        report[0] |= MODIFIERS.get(modifier, 0)

    if keys:
        last_key = keys[-1]
        if last_key in keymap:
            keycode = keymap[last_key]['keycode']
            report[2] = int(keycode, 16)

    write_report(report)

# Example usage
inject_keystroke('json.txt', 'CTRL+ALT+DELETE')

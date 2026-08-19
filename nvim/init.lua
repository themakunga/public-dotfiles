local loader = require('core.loader')

loader.load('settings.options')
loader.load('settings.keymaps')
loader.load('commands.init')

loader.load('plugins.init')
print("initial load file")

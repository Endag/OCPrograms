local versionMajor = "1"
local versionMinor = "0"

--[[
    Gui functions
    Needs a screen tier 2 or tier 3
    All x, y coordinates are relative to the gui, not the screen
------------------------------------------------------------------------
gui.Version()
  returns the version of the library

gui.clearScreen()
  clears the screen to background color, sets top and back line 

gui.setTop(text)
  prints a text centered on the top line

gui.setBottom(text)
  prints a text centered on the bottom line

gui.newGui(x, y, w, h, frame, text, bg, fg)
  setup a new gui 
  frame = true/false
  needs: x, y, w, h, frame

gui.displayGui(guiID)
  displays the whole gui and his widgets
  needs to be called before handling the gui
  first call of runGui will do it

gui.newLabel(guiID, x, y, text, bg, fg)
  register a new label to gui
  returns id of the label
  needs: guiID, x, y, text)

gui.newCheckbox(guiID, x, y, status)
  register a new checkbox to the gui
  returns id of the checkbox
  status can be true or false

gui.newRadio(guiID, x, y)
  registers a new radio button
  returns id of the radio button
  a gui can have only one set of radio buttons

gui.newButton(guiID, x, y, text, func)
  register a new button to gui
  returns id of the button
  func will be called if button is clicked with func(guiID, buttonID)
  needs: guiID, x, y, text

gui.newText(guiID, x, y, lenght, text, func)
  register a new text input to gui
  returns id of the text input
  func will be called if input is finished and enter is pressed with func(guiID, textID, text)
  needs: guiID, x, y, lenght, text

gui.newProgress(guiID, x, y, lenght, maxValue, value, func, number)
  register a new progress bar to the gui
  returns the id of the progress bar
  func will be called if value reached max value with func(guiID, progressID)
  if number is given, it displays a % value in the middle on top of the bar
  Progressbar will be paused if an text input is active
  needs: guiID, x, y, lenght, maxValue, value

gui.newVProgress(guiID, x, y, lenght, maxValue, value, func, direction)
  register a new vertical progress bar to the gui
  returns the id of the progress bar
  func will be called if value reached max value with func(guiID, progressID)
  If direction is 0 or not given, the bar runs from top to bottom.
  If direction is 1 then bar runs from bottom to top
  Progressbar will be paused if an text input is active
  needs: guiID, x, y, lenght, maxValue, value

gui.newList(guiID, x, y, width, height, tab, func, text)
  register a new selection list to the gui
  tab = table with entries
  returns the id of the list
  func will be called, if scrolling in list, or entry is selected with func(guiID, listID, selectedID, selectedText)
  needs: guiID, x, y, width, height, tab

gui.newFrame(guiID, x, y, width, height, text)
  register a new frame to the gui
  needs: guiID, x, y, width, height

gui.newHLine(guiID, x, y, width)
  register a new horizontal line
  
gui.getCheckboxStatus(guiID, widgetID)
  returns the status of the checkbox (true = enabled or false = disabled)

gui.getSelected(guiID, listID)
  returns the number and the text of the selected entrie in a list

gui.setMax(guiID, progressID, maxValue)
  set the maximum value of a progress bar

gui.setValue(guiID, progressID, value)
  set the value of a progress bar

gui.resetProgress(guiID, progressID)
  resets a progress bar to 0, so it can be used again

gui.setText(guiID, widgetID, text)
  sets text of an element 
  can be used on label, text inputs and lists

gui.getText(guiID, widgetID)
  returns text of an input field
  can be used on label, text inputs and lists

gui.setEnable(guiID, widgetID, state)
  enable or disable element
  state = true/false

gui.setVisible(guiID, widgetID, state)
  shows or hides an element
  state = true/false
  will also enable or disable the element. setEnable needs to be called if state is set back to true

gui.clearList(guiID, listID)
  clears a list to use it again

gui.insertList(guiID, listID, value)
  insert an entry into a list

gui.getRadio(guiID)
  resturns id of the selected radio button or -1 if none is selected

gui.runGui(guiID)
  needs to be called in a loop to run gui actions
  it's possible to setup guis and run each seperated.

gui.showError(msg1, msg2, msg3)
  displays a centered error message, with exit program as button

gui.showMsg(msg1, msg2, msg3)
  displays a message box

gui.getYesNo(msg1, msg2, msg3)
  displays a yes-No question
  returns true or false

gui.exit()
  clears the screen to black and exits the program

---------------------------------------------------------------

Example:

local component = require("component")
local gpu = component.gpu
local gui = require("gui")

local prgName = "Test"
local version = gui.Version()

function buttonCallback(guiID, id)
  local result = gui.getYesNo("", "Do you really want to exit?", "")
  if result == true then
    gui.exit()
  end
  gui.displayGui(myGui)
end

myGui = gui.newGui(2, 2, 78, 23, true)
button = gui.newButton(myGui, "center", 21, "exit", buttonCallback)

gui.clearScreen()
gui.setTop(prgName .. " " .. version)
while true do
  gui.runGui(myGui)
end

]]


local component = require("component")
local gpu = component.gpu
local event = require("event")
local ser = require("serialization")
local computer = require("computer")

local gui = {}

local colorScreenBackground = 0xC0C0C0
local colorScreenForeground = 0x000000
local colorTopLineBackground = 0x0000FF
local colorTopLineForeground = 0xFFFFFF
local colorBottomLineBackground = 0x0000FF
local colorBottomLineForeground = 0xFFFFFF
local colorFrameBackground = 0xC0C0C0
local colorFrameForeground = 0x000000
local colorButtonBackground = 0x0000FF
local colorButtonForeground = 0xFFFFFF
local colorButtonClickedBackground = 0x00FF00
local colorButtonClickedForeground = 0xFFFFFF
local colorButtonDisabledBackground = 0x000000
local colorButtonDisabledForeground = 0xFFFFFF
local colorTextBackground = 0x000000
local colorTextForeground = 0xFFFF00
local colorInputBackground = 0x0000FF
local colorInputForeground = 0xFFFFFF
local colorProgressBackground = 0x000000
local colorProgressForeground = 0x00FF00
local colorProgressNumberForeground = 0xFFFF00
local colorListBackground = 0x0000FF
local colorListForeground = 0xFFFFFF
local colorListActiveBackground = 0x00FF00
local colorListActiveForeground = 0xFFFF00
local colorListDisabledBackground = 0x000000
local colorListDisabledForeground = 0xFFFF00
local colorVProgressBackground = 0x000000
local colorVProgressForeground = 0x00FF00

local screenWidth, screenHeight = gpu.getResolution()

function gui.Version()
  return versionMajor .. "." .. versionMinor, versionMajor, versionMinor
end

-- displays the gui frame, if set or just clears the display area
local function _displayFrame(gui)
  gpu.setBackground(gui.bg)
  gpu.setForeground(gui.fg)
  gpu.fill(gui.x, gui.y, gui.width, gui.height, " ")
  if gui.frame == true then
    gpu.fill(gui.x, gui.y, 1, gui.height, "¦")
    gpu.fill(gui.x + gui.width - 1, gui.y, 1, gui.height, "¦")
    gpu.fill(gui.x, gui.y, gui.width, 1, "=")
    gpu.fill(gui.x, gui.y + gui.height - 1, gui.width, 1, "=")
    gpu.set(gui.x, gui.y, "ã")
    gpu.set(gui.x + gui.width - 1 , gui.y, "¬")
    gpu.set(gui.x, gui.y + gui.height - 1 , "L")
    gpu.set(gui.x + gui.width - 1 , gui.y + gui.height - 1, "-")
    if gui.text then
      gpu.set(gui.x + math.floor((gui.width/2)) - math.floor((string.len(gui.text)/2)), gui.y, gui.text)
    end
  end
end

-- displays a frame
local function _displayAFrame(guiID, frameID)
  gpu.setBackground(guiID.bg)
  gpu.setForeground(guiID.fg)
  gpu.fill(guiID[frameID].x, guiID[frameID].y, 1, guiID[frameID].height, "¦")
  gpu.fill(guiID[frameID].x + guiID[frameID].width - 1, guiID[frameID].y, 1, guiID[frameID].height, "¦")
  gpu.fill(guiID[frameID].x, guiID[frameID].y, guiID[frameID].width, 1, "=")
  gpu.fill(guiID[frameID].x, guiID[frameID].y + guiID[frameID].height - 1, guiID[frameID].width, 1, "=")
  gpu.set(guiID[frameID].x, guiID[frameID].y, "ã")
  gpu.set(guiID[frameID].x + guiID[frameID].width - 1 , guiID[frameID].y, "¬")
  gpu.set(guiID[frameID].x, guiID[frameID].y + guiID[frameID].height - 1 , "L")
  gpu.set(guiID[frameID].x + guiID[frameID].width - 1 , guiID[frameID].y + guiID[frameID].height - 1, "-")
  if guiID[frameID].text then
    gpu.set(guiID[frameID].x + math.floor((guiID[frameID].width/2)) - math.floor((string.len(guiID[frameID].text)/2)+1), guiID[frameID].y, "¦" .. guiID[frameID].text .. "?")
  end
end

--display a horizontal line
local function _displayHLine(guiID, lineID)
  gpu.setBackground(guiID.bg)
  gpu.setForeground(guiID.fg)
  gpu.fill(guiID[lineID].x, guiID[lineID].y, guiID[lineID].width, 1, "=")
end

-- displays a checkbox
local function _displayCheckbox(guiID, checkboxID)
  if guiID[checkboxID].visible == true then
    gpu.setBackground(guiID.bg)
    gpu.setForeground(guiID.fg)
    local x = 0
    x =guiID.x + guiID[checkboxID].x
    if guiID[checkboxID].status == true then
      gpu.set(x, guiID[checkboxID].y, "[v]")
    else
      gpu.set(x, guiID[checkboxID].y, "[ ]")
    end
  end
end

-- displays a radio button
local function _displayRadio(guiID, radioID)
  if guiID[radioID].visible == true then
    gpu.setBackground(guiID.bg)
    gpu.setForeground(guiID.fg)
    local x = 0
    x =guiID.x + guiID[radioID].x
    if guiID[radioID].status == true then
      gpu.set(x, guiID[radioID].y, "(x)")
    else
      gpu.set(x, guiID[radioID].y, "( )")
    end
  end
end

-- displays a label
local function _displayLabel(guiID, labelID)
  if guiID[labelID].visible == true then
    gpu.setBackground(guiID[labelID].bg)
    gpu.setForeground(guiID[labelID].fg)
    local x = 0
    if guiID[labelID].x == "center" then
      x = guiID.x + math.floor((guiID.width / 2)) - math.floor((string.len(guiID[labelID].text)) / 2)
    else
      x =guiID.x + guiID[labelID].x
    end
    gpu.set(x, guiID[labelID].y, guiID[labelID].text)
  end
end

-- displays a button
local function _displayButton(guiID, buttonID)
  if guiID[buttonID].visible == true then
    if guiID[buttonID].active == true then
      gpu.setBackground(colorButtonClickedBackground)
      gpu.setForeground(colorButtonClickedForeground)
    elseif guiID[buttonID].enabled == false then
      gpu.setBackground(colorButtonDisabledBackground)
      gpu.setForeground(colorButtonDisabledForeground)
    else
      gpu.setBackground(colorButtonBackground)
      gpu.setForeground(colorButtonForeground)
    end
    local x = 0
    if guiID[buttonID].x == "center" then
      x = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[buttonID].lenght / 2))
    else
      x = guiID.x + guiID[buttonID].x
    end
    gpu.fill(x, guiID[buttonID].y, guiID[buttonID].lenght, 1, " ")
    gpu.set(x, guiID[buttonID].y, guiID[buttonID].text)
  end
end

-- displays a text
local function _displayText(guiID, textID)
  if guiID[textID].visible == true then
    gpu.setBackground(colorTextBackground)
    gpu.setForeground(colorTextForeground)
    local x = 0
    if guiID[textID].x == "center" then
      x = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[textID].lenght) / 2)
    else
      x = guiID.x + guiID[textID].x
    end
    gpu.fill(x, guiID[textID].y , guiID[textID].lenght, 1, " ")
    gpu.set(x, guiID[textID].y, string.sub(guiID[textID].text, 1, guiID[textID].lenght))
  end
end

-- displays a progress bar
local function _displayProgress(guiID, progressID)
  if guiID[progressID].visible == true then
    gpu.setBackground(colorProgressForeground)
    gpu.setForeground(colorProgressBackground)
    local x = 0
    if guiID[progressID].x == "center" then
      x = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[progressID].lenght) / 2)
    else
      x = guiID.x + guiID[progressID].x
    end
    local proz = math.floor(100 / guiID[progressID].max * guiID[progressID].value)
    if proz > 100 then
      proz = 100
      if guiID[progressID].finished == false and guiID[progressID].func then
	guiID[progressID].func(guiID, progressID)
      end
      guiID[progressID].finished = true
    end
    local pos = math.floor(guiID[progressID].lenght / 100 * proz)
    gpu.fill(x, guiID[progressID].y , pos, 1, " ")
    gpu.setBackground(colorProgressBackground)
    gpu.setForeground(colorProgressForeground)
    gpu.fill(x + pos, guiID[progressID].y , guiID[progressID].lenght - pos, 1, " ")
    gpu.setBackground(guiID.bg)
    gpu.setForeground(guiID.fg)
    if guiID[progressID].displayNumber == true then
      gpu.fill(x, guiID[progressID].y - 1, guiID[progressID].lenght, 1, " ")
      gpu.set(x + (math.floor(guiID[progressID].lenght / 2)) - 1, guiID[progressID].y - 1, proz .. "%")
    end
  end
end

-- displays a vertical progress bar
local function _displayVProgress(guiID, progressID)
  if guiID[progressID].visible == true then
    local x = 0
    if guiID[progressID].x == "center" then
      x = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[progressID].lenght) / 2)
    else
      x = guiID.x + guiID[progressID].x
    end
    local proz = math.floor(100 / guiID[progressID].max * guiID[progressID].value)
    if proz > 100 then
      proz = 100
      if guiID[progressID].finished == false and guiID[progressID].func then
	guiID[progressID].func(guiID, progressID)
      end
      guiID[progressID].finished = true
    end
    local pos = math.floor(guiID[progressID].lenght / 100 * proz)
    if guiID[progressID].direction == 0 then
      gpu.setBackground(colorProgressForeground)
      gpu.setForeground(colorProgressBackground)
      gpu.fill(x, guiID[progressID].y , 1, pos, " ")
      gpu.setBackground(colorProgressBackground)
      gpu.setForeground(colorProgressForeground)
      gpu.fill(x, guiID[progressID].y + pos, 1, guiID[progressID].lenght - pos, " ")
    end
    if guiID[progressID].direction == 1 then
      gpu.setBackground(colorProgressBackground)
      gpu.setForeground(colorProgressForeground)
      gpu.fill(x, guiID[progressID].y, 1, guiID[progressID].lenght, " ")
      gpu.setBackground(colorProgressForeground)
      gpu.setForeground(colorProgressBackground)
      gpu.fill(x, guiID[progressID].y + guiID[progressID].lenght - pos , 1, pos, " ")
    end
  end
end

-- display list
local function _displayList(guiID, listID)
  if guiID[listID].visible == true then
    if guiID[listID].enabled == true then
      gpu.setBackground(colorListBackground)
      gpu.setForeground(colorListForeground)
    else
      gpu.setBackground(colorListDisabledBackground)
      gpu.setForeground(colorListDisabledForeground)
    end
    gpu.fill(guiID[listID].x, guiID[listID].y, guiID[listID].width, guiID[listID].height, " ")
    gpu.fill(guiID[listID].x, guiID[listID].y, guiID[listID].width, 1, "=")
    if guiID[listID].text then
      gpu.set( guiID[listID].x + (guiID[listID].width/2) - (string.len(guiID[listID].text)/2), guiID[listID].y, "¦" .. guiID[listID].text .. "?")
    end
    if guiID[listID].active + guiID[listID].height - 3 > #guiID[listID].entries then
      l = #guiID[listID].entries
    else
      l = guiID[listID].active + guiID[listID].height - 3
    end
    gpu.fill(guiID[listID].x, guiID[listID].y +guiID[listID].height - 1, guiID[listID].width, 1, "=")
    gpu.set(guiID[listID].x, guiID[listID].y + guiID[listID].height - 1, "[<]")
    gpu.set(guiID[listID].x + guiID[listID].width - 3, guiID[listID].y + guiID[listID].height - 1, "[>]")
    for v = guiID[listID].active, l  do
      if v == guiID[listID].selected then
	gpu.setBackground(colorListActiveBackground)
	gpu.setForeground(colorListActiveForeground)
      else
	if guiID[listID].enabled == true then
	  gpu.setBackground(colorListBackground)
	  gpu.setForeground(colorListForeground)
	else
	  gpu.setBackground(colorListDisabledBackground)
	  gpu.setForeground(colorListDisabledForeground)
	end
      end
      gpu.fill(guiID[listID].x, guiID[listID].y + v - guiID[listID].active + 1, guiID[listID].width, 1 , " ")
      gpu.set(guiID[listID].x + 1, guiID[listID].y + v - guiID[listID].active + 1, guiID[listID].entries[v] )
    end
  end
end

function _drawWidget(guiID, widgetID)

	if guiID[widgetID].type == "label" then
      _displayLabel(guiID, widgetID)
    elseif guiID[widgetID].type == "button" then
      _displayButton(guiID, widgetID)
    elseif guiID[widgetID].type == "text" then
      _displayText(guiID, widgetID)
    elseif guiID[widgetID].type == "progress" then
      _displayProgress(guiID, widgetID)
    elseif guiID[widgetID].type == "vprogress" then
      _displayVProgress(guiID, widgetID)
    elseif guiID[widgetID].type == "list" then
      _displayList(guiID, widgetID)
    elseif guiID[widgetID].type == "frame" then
      _displayAFrame(guiID, widgetID)
    elseif guiID[widgetID].type == "hline" then
      _displayHLine(guiID, widgetID)
    elseif guiID[widgetID].type == "checkbox" then
      _displayCheckbox(guiID, widgetID)
    elseif guiID[widgetID].type == "radio" then
      _displayRadio(guiID, widgetID)
    end
end

-- display the gui and all widgets
function gui.displayGui(guiID)
  _displayFrame(guiID)
  
  for i = 1, #guiID do
    _drawWidget(guiID, i)
  end
end


function gui.exit()
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, screenWidth, screenHeight, " ")
  os.exit()
end

function gui.clearScreen()
  gpu.setBackground(colorScreenBackground)
  gpu.setForeground(colorScreenForeground)
  gpu.fill(1, 1, screenWidth, screenHeight, " ")

  gpu.setBackground(colorTopLineBackground)
  gpu.setForeground(colorTopLineForeground)
  gpu.fill(1, 1, screenWidth, 1, " ")
  
  gpu.setBackground(colorBottomLineBackground)
  gpu.setForeground(colorBottomLineForeground)
  gpu.fill(1, screenHeight, screenWidth, 1, " ")
end

function gui.setTop(text)
  gpu.setBackground(colorTopLineBackground)
  gpu.setForeground(colorTopLineForeground)
  gpu.fill(1, 1, screenWidth, 1, " ")
  gpu.set( (screenWidth / 2) - (string.len(text) / 2), 1, text)
end

function gui.setBottom(text)
  gpu.setBackground(colorBottomLineBackground)
  gpu.setForeground(colorBottomLineForeground)
  gpu.fill(1, screenHeight, screenWidth, 1, " ")
  gpu.set( (screenWidth / 2) - (string.len(text) / 2), screenHeight, text)
end

-- need to be called first to setup a new dialog
function gui.newGui(x, y, w, h, frame, text, bg, fg)
  local tmpTable = {}
  if x == "center" then
    tmpTable["x"] = math.floor((screenWidth / 2) - (w / 2))
  else
    tmpTable["x"] = x
  end
  if y == "center" then
    tmpTable["y"] = math.floor((screenHeight / 2) - (h / 2))
  else
    tmpTable["y"] = y
  end
  tmpTable["bg"] = bg or colorFrameBackground
  tmpTable["fg"] = fg or colorFrameForeground
  tmpTable["width"] = w
  tmpTable["height"] = h
  tmpTable["frame"] = frame
  if text then
    tmpTable["text"] = "¦" .. text .. "?"
  end
  return tmpTable
end

-- checkbox
function gui.newCheckbox(guiID, x, y, status)
  local tmpTable = {}
  tmpTable["type"] = "checkbox"
  tmpTable["status"] = status or false
  tmpTable["y"] = y + guiID.y
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["x"] = x
  table.insert(guiID, tmpTable)
  return #guiID
end

-- radio button
function gui.newRadio(guiID, x, y)
  local tmpTable = {}
  tmpTable["type"] = "radio"
  tmpTable["status"] = false
  tmpTable["y"] = y + guiID.y
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["x"] = x
  table.insert(guiID, tmpTable)
  return #guiID
end

-- label
function gui.newLabel(guiID, x, y, text, bg, fg)
  local tmpTable = {}
  tmpTable["type"] = "label"
  tmpTable["y"] = y + guiID.y
  tmpTable["text"] = text
  tmpTable["lenght"] = string.len(text)
  tmpTable["bg"] = bg or guiID.bg
  tmpTable["fg"] = fg or guiID.fg
  tmpTable["visible"] = true
  tmpTable["x"] = x
  table.insert(guiID, tmpTable)
  return #guiID
end

-- button
function gui.newButton(guiID, x, y, text, func)
  local tmpTable = {}
  tmpTable["type"] = "button"
  tmpTable["y"] = y + guiID.y
  tmpTable["text"] = "[" .. text .. "]"
  tmpTable["lenght"] = string.len(tmpTable.text)
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["active"] = false
  tmpTable["func"] = func
  tmpTable["x"] = x
  table.insert(guiID, tmpTable)
  return #guiID
end

-- text input field
function gui.newText(guiID, x, y, lenght, text, func)
  local tmpTable = {}
  tmpTable["type"] = "text"
  tmpTable["x"] = x
  tmpTable["y"] = y + guiID.y
  tmpTable["text"] = text
  tmpTable["lenght"] = lenght
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["func"] = func
  table.insert(guiID, tmpTable)
  return #guiID
end

-- progressbar
function gui.newProgress(guiID, x, y, lenght, maxValue, value, func, number)
  local tmpTable = {}
  tmpTable["type"] = "progress"
  tmpTable["x"] = x
  tmpTable["y"] = y + guiID.y
  tmpTable["lenght"] = lenght
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["max"] = maxValue
  tmpTable["value"] = value
  tmpTable["func"] = func
  tmpTable["finished"] = false
  tmpTable["displayNumber"] = number
  table.insert(guiID, tmpTable)
  return #guiID
end

-- vertical progress
function gui.newVProgress(guiID, x, y, lenght, maxValue, value, func, direction)
  local tmpTable = {}
  tmpTable["type"] = "vprogress"
  tmpTable["x"] = x
  tmpTable["y"] = y + guiID.y
  tmpTable["lenght"] = lenght
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["max"] = maxValue
  tmpTable["value"] = value
  tmpTable["func"] = func
  tmpTable["direction"] = direction or 0
  tmpTable["finished"] = false
  table.insert(guiID, tmpTable)
  return #guiID
end

function gui.newList(guiID, x, y, width, height, tab, func, text)
  local tmpTable = {}
  tmpTable["type"] = "list"
  tmpTable["x"] = x + guiID.x
  tmpTable["y"] = y + guiID.y
  tmpTable["width"] = width
  tmpTable["height"] = height
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["func"] = func
  tmpTable["selected"] = 1
  tmpTable["active"] = 1
  tmpTable["entries"] = tab
  tmpTable["text"] = text
  table.insert(guiID, tmpTable)
  return #guiID
end

function gui.newFrame(guiID, x, y, width, height, text)
  local tmpTable = {}
  tmpTable["type"] = "frame"
  tmpTable["x"] = x + guiID.x
  tmpTable["y"] = y + guiID.y
  tmpTable["width"] = width
  tmpTable["height"] = height
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  tmpTable["text"] = text
  table.insert(guiID, tmpTable)
  return #guiID
end

function gui.newHLine(guiID, x, y, width)
  local tmpTable = {}
  tmpTable["type"] = "hline"
  tmpTable["x"] = x + guiID.x
  tmpTable["y"] = y + guiID.y
  tmpTable["width"] = width
  tmpTable["visible"] = true
  tmpTable["enabled"] = true
  table.insert(guiID, tmpTable)
  return #guiID
end

function gui.getSelected(guiID, listID)
  return guiID[listID].selected, guiID[listID].entries[guiID[listID].selected]
end

function gui.setSelected(guiID, listID, selection)
  if selection<= #guiID[listID] then
    guiID[listID].selected = selection
    _displayList(guiID, listID)
  end
end

function gui.setMax(guiID, widgetID, maxValue)
  guiID[widgetID].max = maxValue
  _displayProgress(guiID, widgetID)
end

function gui.setValue(guiID, widgetID, value)
  guiID[widgetID].value = value
  if guiID[widgetID].type == "progress" then
    _displayProgress(guiID, widgetID)
  end
  if guiID[widgetID].type == "vprogress" then
    _displayVProgress(guiID, widgetID)
  end
end

function gui.resetProgress(guiID, progressID)
  guiID[progressID].finished = false
  _displayProgress(guiID, progressID)
end

-- sets the text of a widget
function gui.setText(guiID, widgetID, text)
  guiID[widgetID].text = text
  if guiID[widgetID].type == "text" then
    _displayText(guiID, widgetID)
  end
  if guiID[widgetID].type == "label" then
    _displayLabel(guiID, widgetID)
  end
--  gui.displayGui(guiID)
end

function gui.getText(guiID, widgetID)
  return guiID[widgetID].text
end

function gui.getCheckboxStatus(guiID, widgetID)
  return guiID[widgetID].status
end

function gui.setEnable(guiID, widgetID, state)
  guiID[widgetID].enabled = state
  --gui.displayGui(guiID)
  _drawWidget(guiID, widgetID)
end

function gui.setVisible(guiID, widgetID, state)
  if state == false then
    guiID[widgetID].visible = state
    guiID[widgetID].enabled = state
  elseif state == true then
    guiID[widgetID].visible = state
  end
  --gui.displayGui(guiID)
  _drawWidget(guiID, widgetID)
end

function gui.clearList(guiID, listID)
  guiID[listID].entries = {}
end

function gui.insertList(guiID, listID, value)
  table.insert(guiID[listID].entries, value)
  _displayList(guiID, listID)
end

function gui.getRadio(guiID)
  for i = 1, #guiID do
    if guiID[i].type == "radio" then
      if guiID[i].status == true then
	return i
      end
    end
  end
  return -1
end

local function runInput(guiID, textID)
  local inputText = guiID[textID].text
  gpu.setBackground(colorInputBackground)
  gpu.setForeground(colorInputForeground)
  
  local x = 0
  if guiID[textID].x == "center" then
    x = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[textID].lenght) / 2)
  else
    x =guiID.x + guiID[textID].x
  end

  local loopRunning = true
  while loopRunning == true do
    gpu.fill(x, guiID[textID].y, guiID[textID].lenght, 1, " ")
    tmpStr = inputText
    if string.len(tmpStr) + 1 > guiID[textID].lenght then
      tmpStr = string.sub(tmpStr, string.len(tmpStr) - guiID[textID].lenght + 2, string.len(tmpStr))
    end
    gpu.set(x, guiID[textID].y, tmpStr .. "_")
    local e, _, character, code = event.pullMultiple(0.1, "key_down", "touch")
    if e == "key_down" then
      if character == 8 then	-- backspace
	inputText = string.sub(inputText, 1, string.len(inputText) - 1)
      elseif character == 13 then 	-- return
	guiID[textID].text = inputText
	if guiID[textID].func then
	  guiID[textID].func(guiID, textID, inputText)
	end
	loopRunning = false
      elseif character > 31 and character < 128 then
	inputText = inputText .. string.char(character)
      end
    elseif e == "touch" then
      if character < x or character > (x + guiID[textID].lenght) or guiID[textID].y ~= code then
	guiID[textID].text = inputText
	_displayText(guiID, textID)
	if guiID[textID].func then
	  guiID[textID].func(guiID, textID, inputText)
	end
	loopRunning = false
	computer.pushSignal("touch", _, character, code)
      end
    end
  end
end

local displayed = false

function gui.runGui(guiID)
  if displayed == false then
    displayed = true
    gui.displayGui(guiID)
  end
  local ix = 0
  local e, _, x, y, button = event.pull(0.1, "touch")
  if e == nil then
    return false
  end
  for i = 1, #guiID do
    if guiID[i].type == "button" then
      if guiID[i].x == "center" then
	ix = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[i].lenght / 2))
      else
	ix = guiID.x + guiID[i].x
      end
      if x >= ix and x < (ix + guiID[i].lenght) and guiID[i].y == y then
	if guiID[i].func and guiID[i].enabled == true then
	  guiID[i].active = true
	  gui.displayGui(guiID)
	  os.sleep(0.05)
	  guiID[i].active = false
	  gui.displayGui(guiID)
	  guiID[i].func(guiID, i)
	end
      end
    elseif guiID[i].type == "checkbox" then
      ix = guiID.x + guiID[i].x + 1
      if x == ix and guiID[i].y == y then
	if guiID[i].enabled == true then
	  if guiID[i].status == true then
	    guiID[i].status = false
	  else
	    guiID[i].status = true
	  end
	  _displayCheckbox(guiID, i)
	end
      end
    elseif guiID[i].type == "radio" then
      ix = guiID.x + guiID[i].x + 1
      if x == ix and guiID[i].y == y then
	if guiID[i].enabled == true then
	  for c = 1, #guiID do
	    if guiID[c].type == "radio" then
	      guiID[c].status = false
	      _displayRadio(guiID, c)
	    end
	  end
	  guiID[i].status = true
	  _displayRadio(guiID, i)
	end
      end
    elseif guiID[i].type == "text" then
      if guiID[i].x == "center" then
	ix = guiID.x + math.floor((guiID.width / 2)) - math.floor((guiID[i].lenght / 2))
      else
	ix = guiID.x + guiID[i].x
      end
      if x >= ix and x < (ix + guiID[i].lenght) and guiID[i].y == y then
	if guiID[i].enabled == true then
	  runInput(guiID, i)
	end
      end
    elseif guiID[i].type == "list" and guiID[i].enabled == true then
      if x == guiID[i].x +1 and y == guiID[i].y + guiID[i].height - 1 then
	guiID[i].active = guiID[i].active - guiID[i].height + 2
	if guiID[i].active < 1 then
	  guiID[i].active = 1
	end
	gpu.setBackground(colorListActiveBackground)
	gpu.setForeground(colorListActiveForeground)
	gpu.set(guiID[i].x, guiID[i].y + guiID[i].height - 1, "[<]")
	guiID[i].selected = guiID[i].active
--	_displayList(guiID, i)

	if guiID[i].func then
	  gpu.setBackground(colorButtonClickedBackground)
	  gpu.setForeground(colorButtonClickedForeground)
	  gpu.set(guiID[i].x, guiID[i].y + guiID[i].height - 1, "[<]")
	  os.sleep(0.05)
	  gpu.setBackground(colorListBackground)
	  gpu.setForeground(colorListForeground)
	  gpu.set(guiID[i].x, guiID[i].y + guiID[i].height - 1, "[<]")
	  guiID[i].func(guiID, i, guiID[i].selected, guiID[i].entries[guiID[i].selected])
	end
      end
      if x == guiID[i].x + guiID[i].width - 2 and y == guiID[i].y + guiID[i].height - 1 then
	if guiID[i].active + guiID[i].height - 2 < #guiID[i].entries then
	  guiID[i].active = guiID[i].active + guiID[i].height - 2
	  guiID[i].selected = guiID[i].active
	end
	gpu.setBackground(colorListActiveBackground)
	gpu.setForeground(colorListActiveForeground)
	gpu.set(guiID[i].x + guiID[i].width - 3, guiID[i].y + guiID[i].height - 1, "[>]")
--	_displayList(guiID, i)
	
	if guiID[i].func then
	  gpu.setBackground(colorButtonClickedBackground)
	  gpu.setForeground(colorButtonClickedForeground)
	  gpu.set(guiID[i].x + guiID[i].width - 3, guiID[i].y + guiID[i].height - 1, "[>]")
	  os.sleep(0.05)
	  gpu.setBackground(colorListBackground)
	  gpu.setForeground(colorListForeground)
	  gpu.set(guiID[i].x + guiID[i].width - 3, guiID[i].y + guiID[i].height - 1, "[>]")
	  guiID[i].func(guiID, i, guiID[i].selected, guiID[i].entries[guiID[i].selected])
	end
      end
      if x > guiID[i].x - 1 and x < guiID[i].x + guiID[i].width and y > guiID[i].y and y < guiID[i].y + guiID[i].height - 1 then
	if guiID[i].active + y - guiID[i].y - 1 <= #guiID[i].entries then
	  guiID[i].selected = guiID[i].active + y - guiID[i].y - 1
--	  _displayList(guiID, i)
	  
	  if guiID[i].func then
	    guiID[i].func(guiID, i, guiID[i].selected, guiID[i].entries[guiID[i].selected])
	  end
	end
      end
	  _displayList(guiID, i)
    end
  end
--  gui.displayGui(guiID)
end

errorGui = gui.newGui("center", "center", 40, 10, true, "ERROR", 0xFF0000, 0xFFFF00)
errorMsgLabel1 = gui.newLabel(errorGui, "center", 3, "")
errorMsgLabel2 = gui.newLabel(errorGui, "center", 4, "")
errorMsgLabel3 = gui.newLabel(errorGui, "center", 5, "")
errorButton = gui.newButton(errorGui, "center", 8, "exit", gui.exit)

function gui.showError(msg1, msg2, msg3)
  gui.setText(errorGui, errorMsgLabel1, msg1 or "")
  gui.setText(errorGui, errorMsgLabel2, msg2 or "")
  gui.setText(errorGui, errorMsgLabel3, msg3 or "")
  gui.displayGui(errorGui)
  while true do
    gui.runGui(errorGui)
  end
end


local msgRunning = true
function msgCallback()
  msgRunning = false
end

msgGui = gui.newGui("center", "center", 40, 10, true, "Info")
msgLabel1 = gui.newLabel(msgGui, "center", 3, "")
msgLabel2 = gui.newLabel(msgGui, "center", 4, "")
msgLabel3 = gui.newLabel(msgGui, "center", 5, "")
msgButton = gui.newButton(msgGui, "center", 8, "ok", msgCallback)

function gui.showMsg(msg1, msg2, msg3)
  gui.setText(msgGui, msgLabel1, msg1 or "")
  gui.setText(msgGui, msgLabel2, msg2 or "")
  gui.setText(msgGui, msgLabel3, msg3 or "")
  msgRunning = true
  gui.displayGui(msgGui)
  while msgRunning == true do
    gui.runGui(msgGui)
  end
end


local yesNoRunning = true
local yesNoValue = false

local function yesNoCallbackYes()
  yesNoRunning = false
  yesNoValue = true
end
local function yesNoCallbackNo()
  yesNoRunning = false
  yesNoValue = false
end

yesNoGui = gui.newGui("center", "center", 40, 10, true, "Question")
yesNoMsgLabel1 = gui.newLabel(yesNoGui, "center", 3, "")
yesNoMsgLabel2 = gui.newLabel(yesNoGui, "center", 4, "")
yesNoMsgLabel3 = gui.newLabel(yesNoGui, "center", 5, "")
yesNoYesButton = gui.newButton(yesNoGui, 3, 8, "yes", yesNoCallbackYes)
yesNoNoButton = gui.newButton(yesNoGui, 33, 8, "no", yesNoCallbackNo)


function gui.getYesNo(msg1, msg2, msg3)
  yesNoRunning = true
  gui.setText(yesNoGui, yesNoMsgLabel1, msg1 or "")
  gui.setText(yesNoGui, yesNoMsgLabel2, msg2 or "")
  gui.setText(yesNoGui, yesNoMsgLabel3, msg3 or "")
  gui.displayGui(yesNoGui)
  while yesNoRunning == true do
    gui.runGui(yesNoGui)
  end
  return yesNoValue
end


return gui
# WorldMorph //////////////////////////////////////////////////////////
class WorldMorph
  constructor: (aCanvas, fillPage) ->
    @init aCanvas, fillPage

# I represent the <canvas> element

# WorldMorph inherits from FrameMorph:
WorldMorph:: = new FrameMorph()
WorldMorph::constructor = WorldMorph
WorldMorph.uber = FrameMorph::

# WorldMorph instance creation:

# WorldMorph initialization:
WorldMorph::init = (aCanvas, fillPage) ->
  WorldMorph.uber.init.call this
  @color = new Color(205, 205, 205) # (130, 130, 130)
  @alpha = 1
  @bounds = new Rectangle(0, 0, aCanvas.width, aCanvas.height)
  @drawNew()
  @isVisible = true
  @isDraggable = false
  @currentKey = null # currently pressed key code
  @worldCanvas = aCanvas
  
  # additional properties:
  @useFillPage = fillPage
  @useFillPage = true  if @useFillPage is `undefined`
  @isDevMode = false
  @broken = []
  @hand = new HandMorph(this)
  @keyboardReceiver = null
  @lastEditedText = null
  @cursor = null
  @activeMenu = null
  @activeHandle = null
  @trailsCanvas = null
  @virtualKeyboard = null
  @initEventListeners()

WorldMorph::drawNew = ->
  
  # initialize my surface property
  WorldMorph.uber.drawNew.call this
  @trailsCanvas = newCanvas(@extent())


# World Morph pen trails:
WorldMorph::penTrails = ->
  
  # answer my pen trails canvas. default is to answer my image
  @trailsCanvas


# World Morph display:
WorldMorph::brokenFor = (aMorph) ->
  
  # private
  fb = aMorph.fullBounds()
  @broken.filter (rect) ->
    rect.intersects fb


WorldMorph::fullDrawOn = (aCanvas, aRect) ->
  rectangle = undefined
  area = undefined
  ctx = undefined
  l = undefined
  t = undefined
  w = undefined
  h = undefined
  rectangle = aRect or @fullBounds()
  area = rectangle.intersect(@bounds)
  l = area.left()
  t = area.top()
  w = area.width()
  h = area.height()
  return null  if (w < 0) or (h < 0)
  ctx = aCanvas.getContext("2d")
  ctx.globalAlpha = 1
  ctx.fillStyle = @color.toString()
  ctx.fillRect l, t, w, h
  ctx.drawImage @trailsCanvas, l, t, w, h, l, t, w, h  if @trailsCanvas and (w > 1) and (h > 1)
  
  # for debugging purposes:
  #		try {
  #			ctx.drawImage(this.trailsCanvas, l, t, w, h, l, t, w, h);
  #		} catch (err) {
  #			alert('error' + err
  #				+ '\nl: ' + l
  #				+ '\nt: ' + t
  #				+ '\nw: ' + w
  #				+ '\nh: ' + h
  #				+ '\ntrailsCanvas width: ' + this.trailsCanvas.width
  #				+ '\ntrailsCanvas height: ' + this.trailsCanvas.height
  #			);
  #		}
  #
  #
  @children.forEach (child) ->
    child.fullDrawOn aCanvas, rectangle

  @hand.fullDrawOn aCanvas, rectangle

WorldMorph::updateBroken = ->
  myself = this
  @broken.forEach (rect) ->
    myself.fullDrawOn myself.worldCanvas, rect  if rect.extent().gt(new Point(0, 0))

  @broken = []

WorldMorph::doOneCycle = ->
  @stepFrame()
  @updateBroken()

WorldMorph::fillPage = ->
  pos = getDocumentPositionOf(@worldCanvas)
  clientHeight = window.innerHeight
  clientWidth = window.innerWidth
  myself = this
  if pos.x > 0
    @worldCanvas.style.position = "absolute"
    @worldCanvas.style.left = "0px"
    pos.x = 0
  if pos.y > 0
    @worldCanvas.style.position = "absolute"
    @worldCanvas.style.top = "0px"
    pos.y = 0
  # scrolled down b/c of viewport scaling
  clientHeight = document.documentElement.clientHeight  if document.body.scrollTop
  # scrolled left b/c of viewport scaling
  clientWidth = document.documentElement.clientWidth  if document.body.scrollLeft
  if @worldCanvas.width isnt clientWidth
    @worldCanvas.width = clientWidth
    @setWidth clientWidth
  if @worldCanvas.height isnt clientHeight
    @worldCanvas.height = clientHeight
    @setHeight clientHeight
  @children.forEach (child) ->
    child.reactToWorldResize myself.bounds.copy()  if child.reactToWorldResize



# WorldMorph global pixel access:
WorldMorph::getGlobalPixelColor = (point) ->
  
  #
  #	answer the color at the given point.
  #
  #	Note: for some strange reason this method works fine if the page is
  #	opened via HTTP, but *not*, if it is opened from a local uri
  #	(e.g. from a directory), in which case it's always null.
  #
  #	This behavior is consistent throughout several browsers. I have no
  #	clue what's behind this, apparently the imageData attribute of
  #	canvas context only gets filled with meaningful data if transferred
  #	via HTTP ???
  #
  #	This is somewhat of a showstopper for color detection in a planned
  #	offline version of Snap.
  #
  #	The issue has also been discussed at: (join lines before pasting)
  #	http://stackoverflow.com/questions/4069400/
  #	canvas-getimagedata-doesnt-work-when-running-locally-on-windows-
  #	security-excep
  #
  #	The suggestion solution appears to work, since the settings are
  #	applied globally.
  #
  dta = @worldCanvas.getContext("2d").getImageData(point.x, point.y, 1, 1).data
  new Color(dta[0], dta[1], dta[2])


# WorldMorph events:
WorldMorph::initVirtualKeyboard = ->
  myself = this
  if @virtualKeyboard
    document.body.removeChild @virtualKeyboard
    @virtualKeyboard = null
  return  unless MorphicPreferences.useVirtualKeyboard
  @virtualKeyboard = document.createElement("input")
  @virtualKeyboard.type = "text"
  @virtualKeyboard.style.color = "transparent"
  @virtualKeyboard.style.backgroundColor = "transparent"
  @virtualKeyboard.style.border = "none"
  @virtualKeyboard.style.outline = "none"
  @virtualKeyboard.style.position = "absolute"
  @virtualKeyboard.style.top = "0px"
  @virtualKeyboard.style.left = "0px"
  @virtualKeyboard.style.width = "0px"
  @virtualKeyboard.style.height = "0px"
  document.body.appendChild @virtualKeyboard
  @virtualKeyboard.addEventListener "keydown", ((event) ->
    
    # remember the keyCode in the world's currentKey property
    myself.currentKey = event.keyCode
    myself.keyboardReceiver.processKeyDown event  if myself.keyboardReceiver
    
    # supress backspace override
    event.preventDefault()  if event.keyIdentifier is "U+0008" or event.keyIdentifier is "Backspace"
    
    # supress tab override and make sure tab gets
    # received by all browsers
    if event.keyIdentifier is "U+0009" or event.keyIdentifier is "Tab"
      myself.keyboardReceiver.processKeyPress event  if myself.keyboardReceiver
      event.preventDefault()
  ), false
  @virtualKeyboard.addEventListener "keyup", ((event) ->
    
    # flush the world's currentKey property
    myself.currentKey = null
    
    # dispatch to keyboard receiver
    myself.keyboardReceiver.processKeyUp event  if myself.keyboardReceiver.processKeyUp  if myself.keyboardReceiver
    event.preventDefault()
  ), false
  @virtualKeyboard.addEventListener "keypress", ((event) ->
    myself.keyboardReceiver.processKeyPress event  if myself.keyboardReceiver
    event.preventDefault()
  ), false

WorldMorph::initEventListeners = ->
  canvas = @worldCanvas
  myself = this
  if myself.useFillPage
    myself.fillPage()
  else
    @changed()
  canvas.addEventListener "mousedown", ((event) ->
    myself.hand.processMouseDown event
  ), false
  canvas.addEventListener "touchstart", ((event) ->
    myself.hand.processTouchStart event
  ), false
  canvas.addEventListener "mouseup", ((event) ->
    event.preventDefault()
    myself.hand.processMouseUp event
  ), false
  canvas.addEventListener "touchend", ((event) ->
    myself.hand.processTouchEnd event
  ), false
  canvas.addEventListener "mousemove", ((event) ->
    myself.hand.processMouseMove event
  ), false
  canvas.addEventListener "touchmove", ((event) ->
    myself.hand.processTouchMove event
  ), false
  canvas.addEventListener "contextmenu", ((event) ->
    
    # suppress context menu for Mac-Firefox
    event.preventDefault()
  ), false
  canvas.addEventListener "keydown", ((event) ->
    
    # remember the keyCode in the world's currentKey property
    myself.currentKey = event.keyCode
    myself.keyboardReceiver.processKeyDown event  if myself.keyboardReceiver
    
    # supress backspace override
    event.preventDefault()  if event.keyIdentifier is "U+0008" or event.keyIdentifier is "Backspace"
    
    # supress tab override and make sure tab gets
    # received by all browsers
    if event.keyIdentifier is "U+0009" or event.keyIdentifier is "Tab"
      myself.keyboardReceiver.processKeyPress event  if myself.keyboardReceiver
      event.preventDefault()
  ), false
  canvas.addEventListener "keyup", ((event) ->
    
    # flush the world's currentKey property
    myself.currentKey = null
    
    # dispatch to keyboard receiver
    myself.keyboardReceiver.processKeyUp event  if myself.keyboardReceiver.processKeyUp  if myself.keyboardReceiver
    event.preventDefault()
  ), false
  canvas.addEventListener "keypress", ((event) ->
    myself.keyboardReceiver.processKeyPress event  if myself.keyboardReceiver
    event.preventDefault()
  ), false
  # Safari, Chrome
  canvas.addEventListener "mousewheel", ((event) ->
    myself.hand.processMouseScroll event
    event.preventDefault()
  ), false
  # Firefox
  canvas.addEventListener "DOMMouseScroll", ((event) ->
    myself.hand.processMouseScroll event
    event.preventDefault()
  ), false
  window.addEventListener "dragover", ((event) ->
    event.preventDefault()
  ), false
  window.addEventListener "drop", ((event) ->
    myself.hand.processDrop event
    event.preventDefault()
  ), false
  window.addEventListener "resize", (->
    myself.fillPage()  if myself.useFillPage
  ), false
  window.onbeforeunload = (evt) ->
    e = evt or window.event
    msg = "Are you sure you want to leave?"
    
    # For IE and Firefox
    e.returnValue = msg  if e
    
    # For Safari / chrome
    msg

WorldMorph::mouseDownLeft = ->
  nop()

WorldMorph::mouseClickLeft = ->
  nop()

WorldMorph::mouseDownRight = ->
  nop()

WorldMorph::mouseClickRight = ->
  nop()

WorldMorph::wantsDropOf = ->
  
  # allow handle drops if any drops are allowed
  @acceptsDrops

WorldMorph::droppedImage = ->
  null


# WorldMorph text field tabbing:
WorldMorph::nextTab = (editField) ->
  next = @nextEntryField(editField)
  editField.clearSelection()
  next.selectAll()
  next.edit()

WorldMorph::previousTab = (editField) ->
  prev = @previousEntryField(editField)
  editField.clearSelection()
  prev.selectAll()
  prev.edit()


# WorldMorph menu:
WorldMorph::contextMenu = ->
  menu = undefined
  if @isDevMode
    menu = new MenuMorph(this, @constructor.name or @constructor.toString().split(" ")[1].split("(")[0])
  else
    menu = new MenuMorph(this, "Morphic")
  if @isDevMode
    menu.addItem "demo...", "userCreateMorph", "sample morphs"
    menu.addLine()
    menu.addItem "hide all...", "hideAll"
    menu.addItem "show all...", "showAllHiddens"
    menu.addItem "move all inside...", "keepAllSubmorphsWithin", "keep all submorphs\nwithin and visible"
    menu.addItem "inspect...", "inspect", "open a window on\nall properties"
    menu.addLine()
    menu.addItem "restore display", "changed", "redraw the\nscreen once"
    menu.addItem "fill page...", "fillPage", "let the World automatically\nadjust to browser resizings"
    if useBlurredShadows
      menu.addItem "sharp shadows...", "toggleBlurredShadows", "sharp drop shadows\nuse for old browsers"
    else
      menu.addItem "blurred shadows...", "toggleBlurredShadows", "blurry shades,\n use for new browsers"
    menu.addItem "color...", (->
      @pickColor menu.title + "\ncolor:", @setColor, this, @color
    ), "choose the World's\nbackground color"
    if MorphicPreferences is standardSettings
      menu.addItem "touch screen settings", "togglePreferences", "bigger menu fonts\nand sliders"
    else
      menu.addItem "standard settings", "togglePreferences", "smaller menu fonts\nand sliders"
    menu.addLine()
  if @isDevMode
    menu.addItem "user mode...", "toggleDevMode", "disable developers'\ncontext menus"
  else
    menu.addItem "development mode...", "toggleDevMode"
  menu.addItem "about morphic.js...", "about"
  menu

WorldMorph::userCreateMorph = ->
  create = (aMorph) ->
    aMorph.isDraggable = true
    aMorph.pickUp myself
  myself = this
  menu = undefined
  newMorph = undefined
  menu = new MenuMorph(this, "make a morph")
  menu.addItem "rectangle", ->
    create new Morph()

  menu.addItem "box", ->
    create new BoxMorph()

  menu.addItem "circle box", ->
    create new CircleBoxMorph()

  menu.addLine()
  menu.addItem "slider", ->
    create new SliderMorph()

  menu.addItem "frame", ->
    newMorph = new FrameMorph()
    newMorph.setExtent new Point(350, 250)
    create newMorph

  menu.addItem "scroll frame", ->
    newMorph = new ScrollFrameMorph()
    newMorph.contents.acceptsDrops = true
    newMorph.contents.adjustBounds()
    newMorph.setExtent new Point(350, 250)
    create newMorph

  menu.addItem "handle", ->
    create new HandleMorph()

  menu.addLine()
  menu.addItem "string", ->
    newMorph = new StringMorph("Hello, World!")
    newMorph.isEditable = true
    create newMorph

  menu.addItem "text", ->
    newMorph = new TextMorph("Ich weiß nicht, was soll es bedeuten, dass ich so " + "traurig bin, ein Märchen aus uralten Zeiten, das " + "kommt mir nicht aus dem Sinn. Die Luft ist kühl " + "und es dunkelt, und ruhig fließt der Rhein; der " + "Gipfel des Berges funkelt im Abendsonnenschein. " + "Die schönste Jungfrau sitzet dort oben wunderbar, " + "ihr gold'nes Geschmeide blitzet, sie kämmt ihr " + "goldenes Haar, sie kämmt es mit goldenem Kamme, " + "und singt ein Lied dabei; das hat eine wundersame, " + "gewalt'ge Melodei. Den Schiffer im kleinen " + "Schiffe, ergreift es mit wildem Weh; er schaut " + "nicht die Felsenriffe, er schaut nur hinauf in " + "die Höh'. Ich glaube, die Wellen verschlingen " + "am Ende Schiffer und Kahn, und das hat mit ihrem " + "Singen, die Loreley getan.")
    newMorph.isEditable = true
    newMorph.maxWidth = 300
    newMorph.drawNew()
    create newMorph

  menu.addItem "speech bubble", ->
    newMorph = new SpeechBubbleMorph("Hello, World!")
    create newMorph

  menu.addLine()
  menu.addItem "gray scale palette", ->
    create new GrayPaletteMorph()

  menu.addItem "color palette", ->
    create new ColorPaletteMorph()

  menu.addItem "color picker", ->
    create new ColorPickerMorph()

  menu.addLine()
  menu.addItem "sensor demo", ->
    newMorph = new MouseSensorMorph()
    newMorph.setColor new Color(230, 200, 100)
    newMorph.edge = 35
    newMorph.border = 15
    newMorph.borderColor = new Color(200, 100, 50)
    newMorph.alpha = 0.2
    newMorph.setExtent new Point(100, 100)
    create newMorph

  menu.addItem "animation demo", ->
    foo = undefined
    bar = undefined
    baz = undefined
    garply = undefined
    fred = undefined
    foo = new BouncerMorph()
    foo.setPosition new Point(50, 20)
    foo.setExtent new Point(300, 200)
    foo.alpha = 0.9
    foo.speed = 3
    bar = new BouncerMorph()
    bar.setColor new Color(50, 50, 50)
    bar.setPosition new Point(80, 80)
    bar.setExtent new Point(80, 250)
    bar.type = "horizontal"
    bar.direction = "right"
    bar.alpha = 0.9
    bar.speed = 5
    baz = new BouncerMorph()
    baz.setColor new Color(20, 20, 20)
    baz.setPosition new Point(90, 140)
    baz.setExtent new Point(40, 30)
    baz.type = "horizontal"
    baz.direction = "right"
    baz.speed = 3
    garply = new BouncerMorph()
    garply.setColor new Color(200, 20, 20)
    garply.setPosition new Point(90, 140)
    garply.setExtent new Point(20, 20)
    garply.type = "vertical"
    garply.direction = "up"
    garply.speed = 8
    fred = new BouncerMorph()
    fred.setColor new Color(20, 200, 20)
    fred.setPosition new Point(120, 140)
    fred.setExtent new Point(20, 20)
    fred.type = "vertical"
    fred.direction = "down"
    fred.speed = 4
    bar.add garply
    bar.add baz
    foo.add fred
    foo.add bar
    create foo

  menu.addItem "pen", ->
    create new PenMorph()

  if myself.customMorphs
    menu.addLine()
    myself.customMorphs().forEach (morph) ->
      menu.addItem morph.toString(), ->
        create morph


  menu.popUpAtHand this

WorldMorph::toggleDevMode = ->
  @isDevMode = not @isDevMode

WorldMorph::hideAll = ->
  @children.forEach (child) ->
    child.hide()


WorldMorph::showAllHiddens = ->
  @forAllChildren (child) ->
    child.show()  unless child.isVisible


WorldMorph::about = ->
  versions = ""
  module = undefined
  for module of modules
    versions += ("\n" + module + " (" + modules[module] + ")")  if modules.hasOwnProperty(module)
  versions = "\n\nmodules:\n\n" + "morphic (" + morphicVersion + ")" + versions  if versions isnt ""
  @inform "morphic.js\n\n" + "a lively Web GUI\ninspired by Squeak\n" + morphicVersion + "\n\nwritten by Jens Mönig\njens@moenig.org" + versions

WorldMorph::edit = (aStringOrTextMorph) ->
  pos = getDocumentPositionOf(@worldCanvas)
  return null  unless aStringOrTextMorph.isEditable
  @cursor.destroy()  if @cursor
  @lastEditedText.clearSelection()  if @lastEditedText
  @cursor = new CursorMorph(aStringOrTextMorph)
  aStringOrTextMorph.parent.add @cursor
  @keyboardReceiver = @cursor
  @initVirtualKeyboard()
  if MorphicPreferences.useVirtualKeyboard
    @virtualKeyboard.style.top = @cursor.top() + pos.y + "px"
    @virtualKeyboard.style.left = @cursor.left() + pos.x + "px"
    @virtualKeyboard.focus()
  if MorphicPreferences.useSliderForInput
    if !aStringOrTextMorph.parentThatIsA(MenuMorph)
      @slide aStringOrTextMorph

WorldMorph::slide = (aStringOrTextMorph) ->
  
  # display a slider for numeric text entries
  val = parseFloat(aStringOrTextMorph.text)
  menu = undefined
  slider = undefined
  val = 0  if isNaN(val)
  menu = new MenuMorph()
  slider = new SliderMorph(val - 25, val + 25, val, 10, "horizontal")
  slider.alpha = 1
  slider.color = new Color(225, 225, 225)
  slider.button.color = menu.borderColor
  slider.button.highlightColor = slider.button.color.copy()
  slider.button.highlightColor.b += 100
  slider.button.pressColor = slider.button.color.copy()
  slider.button.pressColor.b += 150
  slider.silentSetHeight MorphicPreferences.scrollBarSize
  slider.silentSetWidth MorphicPreferences.menuFontSize * 10
  slider.drawNew()
  slider.action = (num) ->
    aStringOrTextMorph.changed()
    aStringOrTextMorph.text = Math.round(num).toString()
    aStringOrTextMorph.drawNew()
    aStringOrTextMorph.changed()

  menu.items.push slider
  menu.popup this, aStringOrTextMorph.bottomLeft().add(new Point(0, 5))

WorldMorph::stopEditing = ->
  if @cursor
    @lastEditedText = @cursor.target
    @cursor.destroy()
    @lastEditedText.escalateEvent "reactToEdit", @lastEditedText
  @keyboardReceiver = null
  if @virtualKeyboard
    @virtualKeyboard.blur()
    document.body.removeChild @virtualKeyboard
    @virtualKeyboard = null
  @worldCanvas.focus()

WorldMorph::toggleBlurredShadows = ->
  useBlurredShadows = not useBlurredShadows

WorldMorph::togglePreferences = ->
  if MorphicPreferences is standardSettings
    MorphicPreferences = touchScreenSettings
  else
    MorphicPreferences = standardSettings

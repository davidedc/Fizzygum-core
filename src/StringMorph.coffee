# StringMorph /////////////////////////////////////////////////////////

# A StringMorph is a single line of text. It can only be left-aligned.
# REQUIRES WorldMorph
# REQUIRES BackBufferMixin

class StringMorph extends Morph
  # this is so we can create objects from the object class name 
  # (for the deserialization process)
  namedClasses[@name] = @prototype

  @augmentWith BackBufferMixin

  text: ""
  fontSize: null
  fontName: null
  fontStyle: null
  isBold: null
  isItalic: null
  isEditable: false
  isNumeric: null
  isPassword: false
  isShowingBlanks: false
  # careful: Objects are shared with all the instances of this class.
  # if you modify it, then all the objects will get the change
  # but if you replace it with a new Color, then that will only affect the
  # specific object instance. Same behaviour as with arrays.
  # see: https://github.com/jashkenas/coffee-script/issues/2501#issuecomment-7865333
  blanksColor: new Color 180, 140, 140

  # Properties for text-editing
  isScrollable: true
  currentlySelecting: false
  startMark: null
  endMark: null
  # see note above about Colors and shared objects
  markedTextColor: new Color 255, 255, 255
  # see note above about Colors and shared objects
  markedBackgoundColor: new Color 60, 60, 120

  constructor: (
      @text = (if text is "" then "" else "StringMorph"),
      @fontSize = 12,
      @fontStyle = "sans-serif",
      @isBold = false,
      @isItalic = false,
      @isNumeric = false,
      @color = (new Color 0, 0, 0),
      @fontName = (WorldMorph.preferencesAndSettings.globalFontFamily)
      ) ->

    super()

    # override inherited properties:
    @noticesTransparentClick = true

  setContent: (theTextContent,a) ->
    if a?
      theTextContent = a.text.text
    if @text != theTextContent
      @text = theTextContent
      @reLayout()
      @backBufferIsPotentiallyDirty = true
      @changed()

  actualFontSizeUsedInRendering: ->
    @fontSize
  
  toString: ->
    # e.g. 'a StringMorph("Hello World")'
    firstPart = super()
    if AutomatorRecorderAndPlayer.state != AutomatorRecorderAndPlayer.IDLE and AutomatorRecorderAndPlayer.hidingOfMorphsContentExtractInLabels
      return firstPart
    else
      return firstPart + " (\"" + @text.slice(0, 30) + "...\")"

  getTextDescription: ->
    if @textDescription?
      return @textDescription + " (adhoc description of string)"
    textWithoutLocationOrInstanceNo = @text.replace /\[\d*@\d*[ ]*\|[ ]*\d*@\d*\]/, ""
    textWithoutLocationOrInstanceNo = textWithoutLocationOrInstanceNo.replace /#\d*/, ""
    return textWithoutLocationOrInstanceNo.slice(0, 30) + " (content of string)"
  
  password: (letter, length) ->
    ans = ""
    for i in [0...length]
      ans += letter
    ans

  buildCanvasFontProperty: ->
    # answer a font string, e.g. 'bold italic 12px sans-serif'
    font = ""
    font = font + "bold "  if @isBold
    font = font + "italic "  if @isItalic
    font + @fontSize + "px " + ((if @fontName then @fontName + ", " else "")) + @fontStyle


  widthOfText: (text = @text)->
    text = (if @isPassword then @password("*", text.length) else text)
    world.canvasContextForTextMeasurements.font = @buildCanvasFontProperty()
    return Math.ceil Math.max world.canvasContextForTextMeasurements.measureText(text).width, 1

  reLayout: ->
    super()
    width = @widthOfText @text
    @silentRawSetExtent new Point width, fontHeight @fontSize
    @notifyChildrenThatParentHasReLayouted()
  
  repaintBackBufferIfNeeded: ->
    if !@backBufferIsPotentiallyDirty then return
    @backBufferIsPotentiallyDirty = false

    if @backBufferValidityChecker?
      if @backBufferValidityChecker.extent == @extent().toString() and
      @backBufferValidityChecker.isPassword == @isPassword and
      @backBufferValidityChecker.isShowingBlanks == @isShowingBlanks and
      @backBufferValidityChecker.canvasFontProperty == @buildCanvasFontProperty() and
      @backBufferValidityChecker.textAlign == @alignment and
      @backBufferValidityChecker.color == @color.toString() and
      @backBufferValidityChecker.textHash == hashCode(@text) and
      @backBufferValidityChecker.startMark == @startMark and
      @backBufferValidityChecker.endMark == @endMark and
      @backBufferValidityChecker.markedBackgoundColor == @markedBackgoundColor.toString()
        return

    text = (if @isPassword then @password("*", @text.length) else @text)
    # initialize my surface property
    width = @widthOfText @text
    @backBuffer = newCanvas (new Point width, @height()).scaleBy pixelRatio
    @backBufferContext = @backBuffer.getContext "2d"

    @backBufferContext.scale pixelRatio, pixelRatio
    @backBufferContext.font = @buildCanvasFontProperty()
    @backBufferContext.textAlign = "left"
    @backBufferContext.textBaseline = "bottom"

    @backBufferContext.fillStyle = @color.toString()
    if @isShowingBlanks
      @renderWithBlanks @backBufferContext, 0, fontHeight @fontSize
    else
      @backBufferContext.fillText text, 0, fontHeight @fontSize

    # draw the selection
    start = Math.min @startMark, @endMark
    stop = Math.max @startMark, @endMark
    for i in [start...stop]
      p = @slotCoordinates(i).subtract @position()
      c = text.charAt(i)
      @backBufferContext.fillStyle = @markedBackgoundColor.toString()
      @backBufferContext.fillRect p.x, p.y, Math.ceil(@backBufferContext.measureText(c).width) + 1,
        fontHeight @fontSize
      @backBufferContext.fillStyle = @markedTextColor.toString()
      @backBufferContext.fillText c, p.x, fontHeight @fontSize

    @backBufferValidityChecker = new BackBufferValidityChecker()
    @backBufferValidityChecker.extent = @extent().toString()
    @backBufferValidityChecker.isPassword = @isPassword
    @backBufferValidityChecker.isShowingBlanks = @isShowingBlanks
    @backBufferValidityChecker.canvasFontProperty = @buildCanvasFontProperty()
    @backBufferValidityChecker.textAlign = @alignment
    @backBufferValidityChecker.color = @color.toString()
    @backBufferValidityChecker.textHash = hashCode @text
    @backBufferValidityChecker.startMark = @startMark
    @backBufferValidityChecker.endMark = @endMark
    @backBufferValidityChecker.markedBackgoundColor = @markedBackgoundColor.toString()
    # notify my parent of layout change
    # @parent.layoutSubmorphs()  if @parent.layoutSubmorphs  if @parent
  
  renderWithBlanks: (context, x = 0, y) ->
    # create the blank form
    drawBlank = ->
      context.drawImage blank, Math.round(x), 0
      x += space
    space = Math.ceil context.measureText(" ").width
    blank = newCanvas new Point(space, @height()).scaleBy pixelRatio
    ctx = blank.getContext "2d"
    words = @text.split " "
    isFirst = true
    ctx.fillStyle = @blanksColor.toString()
    ctx.arc space / 2, blank.height / 2, space / 2, degreesToRadians(0), degreesToRadians(360)
    ctx.fill()

    # render my text inserting blanks
    words.forEach (word) ->
      drawBlank()  unless isFirst
      isFirst = false
      if word isnt ""
        context.fillText word, x, y
        x += Math.ceil context.measureText(word).width
  
  
  # StringMorph measuring:
  slotCoordinates: (slot) ->
    # answer the position point of the given index ("slot")
    # where the caret should be placed
    text = (if @isPassword then @password("*", @text.length) else @text)
    dest = Math.min Math.max(slot, 0), text.length

    xOffset = Math.ceil @widthOfText text.substring 0, dest
    @pos = dest
    x = @left() + xOffset
    y = @top()
    new Point x, y
  
  slotAt: (aPoint) ->
    # answer the slot (index) closest to the given point
    # so the caret can be moved accordingly
    text = (if @isPassword then @password("*", @text.length) else @text)
    idx = 0
    charX = 0

    while aPoint.x - @left() > charX
      charX += Math.ceil @widthOfText text[idx]
      idx += 1
      if idx is text.length
        if (Math.ceil(@widthOfText(text)) - (Math.ceil(@widthOfText(text[idx-1])) / 2)) < (aPoint.x - @left())  
          return idx
    idx - 1
  
  upFrom: (slot) ->
    @startOfLine()
  
  downFrom: (slot) ->
    @endOfLine()

  startOfLine: ->
    # answer the first slot (index) of the line for the given slot
    0
  
  endOfLine: ->
    # answer the slot (index) indicating the EOL for the given slot
    @text.length
    
  fontSizePopup: (menuItem)->
    @prompt menuItem.parent.title + "\nfont\nsize:",
      @,
      "setFontSize",
      @fontSize.toString(),
      null, 6, 500, true

  # StringMorph menus:
  developersMenu: ->
    menu = super()
    menu.addLine()
    menu.addItem "edit", true, @, "edit"
    menu.addItem "font size...", true, @, "fontSizePopup", "set this String's\nfont point size"
    menu.addItem "serif", true, @, "setSerif"  if @fontStyle isnt "serif"
    menu.addItem "sans-serif", true, @, "setSansSerif"  if @fontStyle isnt "sans-serif"

    if @isBold
      menu.addItem "normal weight", true, @, "toggleWeight"
    else
      menu.addItem "bold", true, @, "toggleWeight"

    if @isItalic
      menu.addItem "normal style", true, @, "toggleItalic"
    else
      menu.addItem "italic", true, @, "toggleItalic"

    if @isShowingBlanks
      menu.addItem "hide blanks", true, @, "toggleShowBlanks"
    else
      menu.addItem "show blanks", true, @, "toggleShowBlanks"

    if @isPassword
      menu.addItem "show characters", true, @, "toggleIsPassword"
    else
      menu.addItem "hide characters", true, @, "toggleIsPassword"

    menu
  
  toggleIsfloatDraggable: ->
  #  # for context menu demo purposes
  #  @isfloatDraggable = not @isfloatDraggable
  #  if @isfloatDraggable
  #    @disableSelecting()
  #  else
  #    @enableSelecting()
  
  toggleShowBlanks: ->
    @isShowingBlanks = not @isShowingBlanks
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  toggleWeight: ->
    @isBold = not @isBold
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  toggleItalic: ->
    @isItalic = not @isItalic
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  toggleIsPassword: ->
    @isPassword = not @isPassword
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  setSerif: ->
    @fontStyle = "serif"
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  setSansSerif: ->
    @fontStyle = "sans-serif"
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  setFontSize: (sizeOrMorphGivingSize, morphGivingSize) ->
    if morphGivingSize?.getValue?
      size = morphGivingSize.getValue()
    else
      size = sizeOrMorphGivingSize

    # for context menu demo purposes
    if typeof size is "number"
      @fontSize = Math.round(Math.min(Math.max(size, 4), 500))
    else
      newSize = parseFloat size
      @fontSize = Math.round Math.min Math.max(newSize, 4), 500  unless isNaN newSize
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  # TODO this is invoked when for example you take a slider
  # and set it to target a TextMorph.
  # this is rather strange but I see why in case
  # of a Number you might want to show this in a more
  # compact form. This would have to be handled
  # in a different way though, "setText"'s obvious
  # meaning is very different from this...
  setText: (size) ->
    # for context menu demo purposes
    @text = Math.round(size).toString()
    @reLayout()
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  numericalSetters: ->
    # for context menu demo purposes
    ["fullRawMoveLeftSideTo", "fullRawMoveTopSideTo", "setAlphaScaled", "setFontSize", "setText"]
  
  
  # StringMorph editing:
  edit: ->
    world.edit @

  selection: ->
    start = Math.min @startMark, @endMark
    stop = Math.max @startMark, @endMark
    @text.slice start, stop
  
  selectionStartSlot: ->
    Math.min @startMark, @endMark
    if !@startMark? or !@endMark?
      return null
    return Math.min @startMark, @endMark

  selectionEndSlot: ->
    if !@startMark? or !@endMark?
      return null
    return Math.max @startMark, @endMark

  clearSelection: ->
    @currentlySelecting = false
    @startMark = null
    @endMark = null
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  deleteSelection: ->
    text = @text
    start = Math.min @startMark, @endMark
    stop = Math.max @startMark, @endMark
    @text = text.slice(0, start) + text.slice(stop)
    @backBufferIsPotentiallyDirty = true
    @changed()
    @clearSelection()
  
  selectAll: ->
    @startMark = 0
    @endMark = @text.length
    @backBufferIsPotentiallyDirty = true
    @changed()

  # Every time the user clicks on the text, a new edit()
  # is triggered, which creates a new caret.
  mouseClickLeft: (pos) ->
    @bringToForegroud()
    caret = world.caret
    if @isEditable
      @edit()  unless @currentlySelecting
      if caret then caret.gotoPos pos
      world.caret.gotoPos pos
      @currentlySelecting = true
    else
      @escalateEvent "mouseClickLeft", pos
  
  enableSelecting: ->
    @mouseDownLeft = (pos) ->
      @clearSelection()
      if @isEditable and !@isFloatDraggable()
        @edit()
        world.caret.gotoPos pos
        @startMark = @slotAt pos
        @endMark = @startMark
        @currentlySelecting = true
    
    @mouseMove = (pos) ->
      if @isEditable and @currentlySelecting
        newMark = @slotAt pos
        if newMark isnt @endMark
          @endMark = newMark
          
          @changed()
      else
        @disableSelecting()
  
  disableSelecting: ->
    # re-establish the original definition of the method
    @clearSelection()
    @mouseDownLeft = StringMorph::mouseDownLeft
    delete @mouseMove


  
# StringMorph2 /////////////////////////////////////////////////////////

# A StringMorph2 is a single line of text.
# It's like StringMorph BUT it fits any given size, so to
# behave well in layouts.
# REQUIRES WorldMorph
# REQUIRES BackBufferMixin

class StringMorph2 extends Morph
  # this is so we can create objects from the object class name 
  # (for the deserialization process)
  namedClasses[@name] = @prototype

  @augmentWith BackBufferMixin

  text: ""

  maybeTransformedFontSize: null
  originallySetFontSize: null

  fontName: null
  fontStyle: null
  isBold: null
  isItalic: null
  isEditable: false
  isNumeric: null
  isPassword: false
  isShowingBlanks: false
  # careful: this Color object is shared with all the instances of this class.
  # if you modify it, then all the objects will get the change
  # but if you replace it with a new Color, then that will only affect the
  # specific object instance. Same behaviour as with arrays.
  # see: https://github.com/jashkenas/coffee-script/issues/2501#issuecomment-7865333
  blanksColor: new Color(180, 140, 140)

  # Properties for text-editing
  isScrollable: true
  currentlySelecting: false
  startMark: null
  endMark: null
  # careful: this Color object is shared with all the instances of this class.
  # if you modify it, then all the objects will get the change
  # but if you replace it with a new Color, then that will only affect the
  # specific object instance. Same behaviour as with arrays.
  # see: https://github.com/jashkenas/coffee-script/issues/2501#issuecomment-7865333
  markedTextColor: new Color(255, 255, 255)
  # careful: this Color object is shared with all the instances of this class.
  # if you modify it, then all the objects will get the change
  # but if you replace it with a new Color, then that will only affect the
  # specific object instance. Same behaviour as with arrays.
  # see: https://github.com/jashkenas/coffee-script/issues/2501#issuecomment-7865333
  markedBackgoundColor: new Color(60, 60, 120)

  constructor: (
      text = "",
      @originallySetFontSize = 12,
      @fontStyle = "sans-serif",
      @isBold = false,
      @isItalic = false,
      @isNumeric = false,
      color,
      fontName
      @backgroundColor = null,
      @backgroundTransparency = null
      ) ->
    # additional properties:
    @text = text or ((if (text is "") then "" else "StringMorph2"))
    @fontName = fontName or WorldMorph.preferencesAndSettings.globalFontFamily

    super()

    # override inherited properties:
    @color = color or new Color(0, 0, 0)
    @noticesTransparentClick = true

  # the actual font size used might be
  # different than the one specified originally
  # because this morph has to be able to fit
  # any extent by shrinking.
  actualFontSizeUsedInRendering: ->
    @maybeTransformedFontSize
  
  toString: ->
    # e.g. 'a StringMorph2("Hello World")'
    firstPart = super()
    if AutomatorRecorderAndPlayer.state != AutomatorRecorderAndPlayer.IDLE and AutomatorRecorderAndPlayer.hidingOfMorphsContentExtractInLabels
      return firstPart
    else
      return firstPart + " (\"" + @text.slice(0, 30) + "...\")"

  getTextDescription: ->
    if @textDescription?
      return @textDescription + " (adhoc description of string)"
    textWithoutLocationOrInstanceNo = @text.replace(/\[\d*@\d*[ ]*\|[ ]*\d*@\d*\]/,"")
    textWithoutLocationOrInstanceNo = textWithoutLocationOrInstanceNo.replace(/#\d*/,"")
    return textWithoutLocationOrInstanceNo.slice(0, 30) + " (content of string)"
  
  password: (letter, length) ->
    ans = ""
    for i in [0...length]
      ans += letter
    ans

  font: (overrideFontSize = @maybeTransformedFontSize) ->
    # answer a font string, e.g. 'bold italic 12px sans-serif'
    font = ""
    font = font + "bold "  if @isBold
    font = font + "italic "  if @isItalic
    font + overrideFontSize + "px " + ((if @fontName then @fontName + ", " else "")) + @fontStyle

  # does a binary search to see which font size
  # we need to apply to the text to fit to the
  # current extent.
  # If this gets slow: all kinds of optimisation can be done.
  # for example keeping an LRU cache inside functionZeroesFollowedByOnes
  # keyed on the text and the size
  searchLargestFittingFont: (functionZeroesFollowedByOnes, textToFit) ->

    # decimalFloatFigures allows you to go into sub-points
    # in the font size. This is so the resizing of the
    # text is less "jumpy".
    # "1" seems to be perfect in terms of jumpiness,
    # but obviously this routine gets quite a bit more
    # expensive.
    decimalFloatFigures = 0

    start = 0    # minimum font size that we are gonna examine
    stop  = Math.round(200 * Math.pow(10,decimalFloatFigures))  # maximum font size that we are gonna examine
    
    if functionZeroesFollowedByOnes(textToFit, start) != 0
       return -1

    if functionZeroesFollowedByOnes(textToFit, stop) == 0
       return stop / Math.pow(10,decimalFloatFigures)

    # since we round the pivot to the floor, we
    # always end up start and pivot coinciding
    while start != (pivot = Math.floor (start + stop) / 2)

      valueAtPivot = functionZeroesFollowedByOnes(textToFit, pivot / Math.pow(10,decimalFloatFigures))

      if valueAtPivot == 0
        # bring forward the start since there are still
        # zeroes at the pivot
        start = pivot
      else
        # bring backwards the stop since there is already
        # a one at the pivot
        stop = pivot

    start / Math.pow(10,decimalFloatFigures)

  fitToExtent: ->

    doesTextFitInExtent = (text = @text, overrideFontSize) =>
      text = (if @isPassword then @password("*", text.length) else text)
      # initialize my surface property
      measuringCanvas = newCanvas()
      measuringCanvasContext = measuringCanvas.getContext("2d")
      measuringCanvasContext.scale pixelRatio, pixelRatio
      measuringCanvasContext.font = @font(overrideFontSize)
      measuringCanvasContext.textAlign = "left"
      measuringCanvasContext.textBaseline = "bottom"

      thisFitsInto = new Point(Math.ceil(Math.max(measuringCanvasContext.measureText(text).width, 1)), fontHeight(overrideFontSize))
      if thisFitsInto.le @extent()
        return 0
      else
        return 1

     return @searchLargestFittingFont(doesTextFitInExtent, @text)



  calculateExtentBasedOnText: (text = @text, overrideFontSize)->
    text = (if @isPassword then @password("*", text.length) else text)
    # initialize my surface property
    measuringCanvas = newCanvas()
    measuringCanvasContext = measuringCanvas.getContext("2d")
    measuringCanvasContext.scale pixelRatio, pixelRatio
    measuringCanvasContext.font = @font(overrideFontSize)
    measuringCanvasContext.textAlign = "left"
    measuringCanvasContext.textBaseline = "bottom"

    # set my extent based on the size of the text
    return Math.ceil(Math.max(measuringCanvasContext.measureText(text).width, 1))

  reLayout: ->
    super()
    @maybeTransformedFontSize = @fitToExtent()

  repaintBackBufferIfNeeded: ->
    if !@backBufferIsPotentiallyDirty then return
    @backBufferIsPotentiallyDirty = false

    if @backBufferValidityChecker?
      if @backBufferValidityChecker.extent == @extent().toString() and
      @backBufferValidityChecker.isPassword == @isPassword and
      @backBufferValidityChecker.isShowingBlanks == @isShowingBlanks and
      @backBufferValidityChecker.font == @font() and
      @backBufferValidityChecker.textAlign == @alignment and
      @backBufferValidityChecker.color == @color.toString() and
      @backBufferValidityChecker.textHash == hashCode(@text) and
      @backBufferValidityChecker.startMark == @startMark and
      @backBufferValidityChecker.endMark == @endMark and
      @backBufferValidityChecker.markedBackgoundColor == @markedBackgoundColor.toString()
        return

    text = (if @isPassword then @password("*", @text.length) else @text)
    # Initialize my surface property.
    # If don't have to paint the background then the surface is just as
    # big as the text - which is likely to be smaller than the whole morph
    # (because it needs to fit in both height and width, it's likely that
    # it's gonna be smaller in one of the two dimensions).
    # If, on the other hand, we have to paint the background then the surface is
    # as big as the whole morph,
    # so potentially we could be wasting some space as the string might
    # be really small so to fit, say, the width, while a lot of height of
    # the morph could be "wasted" in memory.
    # This could be optimised but it's unclear if it's worth it.
    if @backgroundColor?
      width = @width()
      height = @height()
    else
      width = @calculateExtentBasedOnText()
      height = fontHeight(@maybeTransformedFontSize)
    @backBuffer = newCanvas (new Point width, height).scaleBy pixelRatio

    @backBufferContext = @backBuffer.getContext("2d")

    # changing the canvas size resets many of
    # the properties of the canvas, so we need to
    # re-initialise the font and alignments here
    @backBufferContext.scale pixelRatio, pixelRatio
    @backBufferContext.font = @font()
    @backBufferContext.textAlign = "left"
    @backBufferContext.textBaseline = "bottom"

    # paint the background so we have a better sense of
    # where the text is fitting into.
    if @backgroundColor?
      @backBufferContext.save()
      @backBufferContext.fillStyle = @backgroundColor.toString()
      if @backgroundTransparency?
        @backBufferContext.globalAlpha = @backgroundTransparency
      @backBufferContext.fillRect  0,0, width * pixelRatio, height * pixelRatio
      @backBufferContext.restore()

    @backBufferContext.fillStyle = @color.toString()
    @backBufferContext.fillText text, 0, fontHeight(@maybeTransformedFontSize)

    # draw the selection
    start = Math.min(@startMark, @endMark)
    stop = Math.max(@startMark, @endMark)
    for i in [start...stop]
      p = @slotCoordinates(i).subtract(@position())
      c = text.charAt(i)
      @backBufferContext.fillStyle = @markedBackgoundColor.toString()
      @backBufferContext.fillRect p.x, p.y, Math.ceil(@backBufferContext.measureText(c).width) + 1,
        fontHeight(@maybeTransformedFontSize)
      @backBufferContext.fillStyle = @markedTextColor.toString()
      @backBufferContext.fillText c, p.x, fontHeight(@maybeTransformedFontSize)

    @backBufferValidityChecker = new BackBufferValidityChecker()
    @backBufferValidityChecker.extent = @extent().toString()
    @backBufferValidityChecker.isPassword = @isPassword
    @backBufferValidityChecker.isShowingBlanks = @isShowingBlanks
    @backBufferValidityChecker.font = @font()
    @backBufferValidityChecker.textAlign = @alignment
    @backBufferValidityChecker.color = @color.toString()
    @backBufferValidityChecker.textHash = hashCode(@text)
    @backBufferValidityChecker.startMark = @startMark
    @backBufferValidityChecker.endMark = @endMark
    @backBufferValidityChecker.markedBackgoundColor = @markedBackgoundColor.toString()
    # notify my parent of layout change
    # @parent.layoutSubmorphs()  if @parent.layoutSubmorphs  if @parent
    
  
  # StringMorph2 measuring:
  slotCoordinates: (slot) ->
    # answer the position point of the given index ("slot")
    # where the caret should be placed
    text = (if @isPassword then @password("*", @text.length) else @text)
    dest = Math.min(Math.max(slot, 0), text.length)

    xOffset = Math.ceil(@calculateExtentBasedOnText(text.substring(0,dest)))
    @pos = dest
    x = @left() + xOffset
    y = @top()
    new Point(x, y)
  
  slotAt: (aPoint) ->
    # answer the slot (index) closest to the given point
    # so the caret can be moved accordingly
    text = (if @isPassword then @password("*", @text.length) else @text)
    idx = 0
    charX = 0

    while aPoint.x - @left() > charX
      charX += Math.ceil(@calculateExtentBasedOnText(text[idx]))
      idx += 1
      if idx is text.length
        if (Math.ceil(@calculateExtentBasedOnText(text)) - (Math.ceil(@calculateExtentBasedOnText(text[idx-1])) / 2)) < (aPoint.x - @left())  
          return idx
    idx - 1
  
  upFrom: (slot) ->
    # answer the slot above the given one
    slot
  
  downFrom: (slot) ->
    # answer the slot below the given one
    slot
  
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
      @originallySetFontSize.toString(),
      null, 6, 500, true

  # StringMorph2 menus:
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
      @originallySetFontSize = Math.round(Math.min(Math.max(size, 4), 500))
    else
      newSize = parseFloat(size)
      @originallySetFontSize = Math.round(Math.min(Math.max(newSize, 4), 500))  unless isNaN(newSize)
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
  
  
  # StringMorph2 editing:
  edit: ->
    world.edit @

  selection: ->
    start = Math.min(@startMark, @endMark)
    stop = Math.max(@startMark, @endMark)
    @text.slice start, stop
  
  selectionStartSlot: ->
    Math.min @startMark, @endMark
  
  clearSelection: ->
    @currentlySelecting = false
    @startMark = null
    @endMark = null
    @backBufferIsPotentiallyDirty = true
    @changed()
  
  deleteSelection: ->
    text = @text
    start = Math.min(@startMark, @endMark)
    stop = Math.max(@startMark, @endMark)
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
    super
    caret = world.caret;
    if @isEditable
      @edit()  unless @currentlySelecting
      if caret then caret.gotoPos pos
      world.caret.gotoPos pos
      @currentlySelecting = true
    else
      @escalateEvent "mouseClickLeft", pos
  
  #mouseDoubleClick: ->
  #  alert "mouseDoubleClick!"

  enableSelecting: ->
    @mouseDownLeft = (pos) ->
      @clearSelection()
      if @isEditable and (not @isFloatDraggable())
        @edit()
        world.caret.gotoPos pos
        @startMark = @slotAt(pos)
        @endMark = @startMark
        @currentlySelecting = true
    
    @mouseMove = (pos) ->
      if @isEditable and @currentlySelecting
        newMark = @slotAt(pos)
        if newMark isnt @endMark
          @endMark = newMark
          
          @changed()
      else
        @disableSelecting()
  
  disableSelecting: ->
    # re-establish the original definition of the method
    @clearSelection()
    @mouseDownLeft = StringMorph2::mouseDownLeft
    delete @mouseMove


  
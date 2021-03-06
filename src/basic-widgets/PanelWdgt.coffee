# I clip my submorphs at my bounds. Which potentially saves a lot of redrawing
# and event handling.
# It's a good idea to use me whenever it's clear that there is a
# "container"/"contained" scenario going on.

class PanelWdgt extends Widget

  @augmentWith ClippingAtRectangularBoundsMixin, @name

  scrollPanel: nil
  extraPadding: 0
  _acceptsDrops: true
  providesAmenitiesForEditing: true

  # if this Panel belongs to a ScrollPanel, then
  # the @scrollPanel points to it
  constructor: (@scrollPanel = nil) ->
    super()
    @dragsDropsAndEditingEnabled = true
    @appearance = new RectangularAppearance @

    @color = WorldMorph.preferencesAndSettings.defaultPanelsBackgroundColor
    @strokeColor = WorldMorph.preferencesAndSettings.defaultPanelsStrokeColor

    if @scrollPanel
      @noticesTransparentClick = false

  colloquialName: ->
    "panel"

  # only the desktop and folder panels have menu entries
  # to invoke this
  makeFolder: (ignored, ignored2, name) ->
    newFolderWindow = new FolderWindowWdgt
    newFolderWindow.close()
    newFolderWindow.createReference (name or world.getNextUntitledFolderShortcutName()), @
    world.howManyUntitledShortcuts++
    return newFolderWindow

  setColor: (aColorOrAMorphGivingAColor, morphGivingColor, connectionsCalculationToken, superCall) ->
    if !superCall and connectionsCalculationToken == @connectionsCalculationToken then return else if !connectionsCalculationToken? then @connectionsCalculationToken = world.makeNewConnectionsCalculationToken() else @connectionsCalculationToken = connectionsCalculationToken

    aColor = super aColorOrAMorphGivingAColor, morphGivingColor, connectionsCalculationToken, true
    # keep in sync the value of the container scrollPanel
    # if there is one. Note that the container scrollPanel
    # is actually not painted.
    if @scrollPanel
      if @scrollPanel.color?.equals aColor
        return
      @scrollPanel.color = aColor
      @scrollPanel.changed()

    return aColor


  setAlphaScaled: (alphaOrMorphGivingAlpha, morphGivingAlpha) ->
    alpha = super(alphaOrMorphGivingAlpha, morphGivingAlpha)
    if @scrollPanel
      unless @scrollPanel.alpha == alpha
        @scrollPanel.alpha = alpha
    return alpha


  mouseClickLeft: (pos, ignored_button, ignored_buttons, ignored_ctrlKey, shiftKey, ignored_altKey, ignored_metaKey) ->
    @bringToForeground()

    # when you click on an "empty" part of a Panel that contains
    # a piece of text, we pass the click on to the text to it
    # puts the caret at the end of the text.
    # TODO the focusing and placing of the caret at the end of
    # the text should happen via API rather than via spoofing
    # a mouse event?
    if @parent? and @parent instanceof ScrollPanelWdgt
      childrenNotCarets = @children.filter (m) ->
        !(m instanceof CaretMorph)
      if childrenNotCarets.length == 1
        item = @firstChildSuchThat (m) ->
          ((m instanceof TextMorph) or
          (m instanceof SimplePlainTextWdgt)) and m.isEditable
        item?.mouseClickLeft item.bottomRight(), ignored_button, ignored_buttons, ignored_ctrlKey, shiftKey, ignored_altKey, ignored_metaKey


  reactToDropOf: ->
    if @parent?
      if @parent.adjustContentsBounds?
        @parent.adjustContentsBounds()
        @parent.adjustScrollBars?()

  childRemoved: (child) ->
    if @parent?
      @parent.grandChildRemoved?()
      if @parent.adjustContentsBounds?
        @parent.adjustContentsBounds()
        @parent.adjustScrollBars?()

  childAdded: (child) ->
    # the BasementWdgt has a filter that can
    # show/hide the contents of this pane
    # based on whether they are reachable or
    # not. So let's notify it.
    if @parent?
      @parent.grandChildAdded?()
      if @parent.parent?
        if @parent.parent.childAddedInScrollPanel?
          @parent.parent.childAddedInScrollPanel child

  # puts the morph in the ScrollPanel
  # in some sparse manner and keeping it
  # "in view"
  addInPseudoRandomPosition: (aWdgt) ->
    width = @width()
    height = @height()

    posx = Math.abs(aWdgt.hashCode()) % width
    posy = Math.abs((aWdgt.toString() + "x").hashCode()) % height
    position = @position().add new Point posx, posy

    @add aWdgt
    aWdgt.fullRawMoveTo position

    if @parent?
      if @parent.adjustContentsBounds?
        @parent.adjustContentsBounds()
        @parent.adjustScrollBars()


  detachesWhenDragged: ->
    if @parent?

      # otherwise you could detach a Frame contained in a
      # ScrollPanelWdgt which is very strange
      if @parent instanceof ScrollPanelWdgt
        return false

      return super

  grabsToParentWhenDragged: ->
    if @parent?

      # otherwise you could detach a Frame contained in a
      # ScrollPanelWdgt which is very strange
      if @parent instanceof ScrollPanelWdgt
        if @parent.canScrollByDraggingBackground and @parent.anyScrollBarShowing()
          return false
        else
          return true

      return super

    # doesn't have a parent
    return false
  
  reactToGrabOf: ->
    if @parent?
      if @parent.adjustContentsBounds?
        @parent.adjustContentsBounds()
        @parent.adjustScrollBars?()

  # PanelWdgt menus:
  addMorphSpecificMenuEntries: (morphOpeningThePopUp, menu) ->
    super
    if @children.length
      menu.addLine()
      menu.addMenuItem "move all inside", true, @, "keepAllSubmorphsWithin", "keep all submorphs\nwithin and visible"
  
  keepAllSubmorphsWithin: ->
    @children.forEach (m) =>
      m.fullRawMoveWithin @

  editButtonPressedFromWindowBar: ->
    if @dragsDropsAndEditingEnabled
      @disableDragsDropsAndEditing @
    else
      @enableDragsDropsAndEditing @


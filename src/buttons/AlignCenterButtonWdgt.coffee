class AlignCenterButtonWdgt extends Widget

  @augmentWith HighlightableMixin, @name
  @augmentWith ParentStainerMixin, @name

  color_hover: Color.create 90, 90, 90
  color_pressed: Color.GRAY
  color_normal: Color.create 230, 230, 230

  constructor: (@color) ->
    super
    @appearance = new AlignCenterIconAppearance @, WorldMorph.preferencesAndSettings.iconDarkLineColor
    @actionableAsThumbnail = true
    @editorContentPropertyChangerButton = true
    @toolTipMessage = "align center"

  mouseClickLeft: ->
    if world.lastNonTextPropertyChangerButtonClickedOrDropped?.alignCenter?
      world.lastNonTextPropertyChangerButtonClickedOrDropped.alignCenter()
    else if world.lastNonTextPropertyChangerButtonClickedOrDropped?
      lastNonTextPropertyChangerButtonClickedOrDropped = world.lastNonTextPropertyChangerButtonClickedOrDropped.findRootForGrab()
      if lastNonTextPropertyChangerButtonClickedOrDropped?.layoutSpec? and
       lastNonTextPropertyChangerButtonClickedOrDropped.layoutSpec == LayoutSpec.ATTACHEDAS_VERTICAL_STACK_ELEMENT
        lastNonTextPropertyChangerButtonClickedOrDropped.layoutSpecDetails.setAlignmentToCenter()



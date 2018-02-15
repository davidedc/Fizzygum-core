class FanoutPinWdgt extends Widget

  @augmentWith ControllerMixin

  inputValue: nil
  target: nil
  action: nil

  constructor: (@color) ->
    super
    @appearance = new FanoutPinAppearance @

  setInput: (newvalue, ignored, connectionsCalculationToken, superCall) ->
    if !superCall and connectionsCalculationToken == @connectionsCalculationToken then return else if !connectionsCalculationToken? then @connectionsCalculationToken = getRandomInt -20000, 20000 else @connectionsCalculationToken = connectionsCalculationToken
    @inputValue = newvalue
    @updateTarget()

  updateTarget: ->
    debugger
    if @action and @action != ""
      @target[@action].call @target, @inputValue, nil, @connectionsCalculationToken
    return    

  addMorphSpecificMenuEntries: (morphOpeningThePopUp, menu) ->
    super
    menu.addLine()
    menu.addMenuItem "set target", true, @, "openTargetSelector", "choose another morph\nwhose color property\n will be" + " controlled by this one"

  openTargetPropertySelector: (ignored, ignored2, theTarget) ->
    [menuEntriesStrings, functionNamesStrings] = theTarget.allSetters()
    menu = new MenuMorph @, false, @, true, true, "choose target property:"
    for i in [0...menuEntriesStrings.length]
      menu.addMenuItem menuEntriesStrings[i], true, @, "setTargetAndActionWithOnesPickedFromMenu", nil, nil, nil, nil, nil, theTarget, functionNamesStrings[i]
    if menuEntriesStrings.length == 0
      menu = new MenuMorph @, false, @, true, true, "no target properties available"
    menu.popUpAtHand()

  reactToTargetConnection: ->
    @parent.updateTarget()

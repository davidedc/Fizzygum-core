# 


class AutomatorCommandCut extends AutomatorCommand

  clipboardText: ""

  @replayFunction: (automatorRecorderAndPlayer, commandBeingPlayed) ->
    automatorRecorderAndPlayer.worldMorph.processCut null, commandBeingPlayed.clipboardText

  constructor: (@clipboardText, automatorRecorderAndPlayer) ->
    super(automatorRecorderAndPlayer)
    # it's important that this is the same name of
    # the class cause we need to use the static method
    # replayFunction to replay the command
    @automatorCommandName = "AutomatorCommandCut"
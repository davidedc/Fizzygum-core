# sends a message to a target object when pressed.
# Takes the shape of an icon, and can also host
# a morph to be used as "face"
#
# You could achieve something similar by having
# an empty button containing an icon, but changing
# the color of a face belonging to a button is
# not yet supported.
# i.e. this is currently the simplest way to change the color
# of a non-rectangular button.

class EditIconButtonWdgt extends EmptyButtonMorph


  constructor: (@target) ->
    # can't set the parent as the target directly because this morph
    # might not have a parent yet.
    super true, @, 'actOnClick', new Widget
    @color_hover = Color.create 255,153,0
    @color_pressed = @color_hover
    @appearance = new PencilIconAppearance @
    @toolTipMessage = "edit contents"


  actOnClick: ->
    if @parent?
      if (@parent instanceof WindowWdgt)
        @parent.contents?.editButtonPressedFromWindowBar?()


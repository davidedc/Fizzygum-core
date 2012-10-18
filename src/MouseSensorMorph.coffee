# MouseSensorMorph ////////////////////////////////////////////////////

# for demo and debuggin purposes only, to be removed later
class MouseSensorMorph
  constructor: (edge, border, borderColor) ->
    @init edge, border, borderColor

# MouseSensorMorph inherits from BoxMorph:
MouseSensorMorph:: = new BoxMorph()
MouseSensorMorph::constructor = MouseSensorMorph
MouseSensorMorph.uber = BoxMorph::

# MouseSensorMorph instance creation:
MouseSensorMorph::init = (edge, border, borderColor) ->
  MouseSensorMorph.uber.init.call this
  @edge = edge or 4
  @border = border or 2
  @color = new Color(255, 255, 255)
  @borderColor = borderColor or new Color()
  @isTouched = false
  @upStep = 0.05
  @downStep = 0.02
  @noticesTransparentClick = false
  @drawNew()

MouseSensorMorph::touch = ->
  myself = this
  unless @isTouched
    @isTouched = true
    @alpha = 0.6
    @step = ->
      if myself.isTouched
        myself.alpha = myself.alpha + myself.upStep  if myself.alpha < 1
      else if myself.alpha > (myself.downStep)
        myself.alpha = myself.alpha - myself.downStep
      else
        myself.alpha = 0
        myself.step = null
      myself.changed()

MouseSensorMorph::unTouch = ->
  @isTouched = false

MouseSensorMorph::mouseEnter = ->
  @touch()

MouseSensorMorph::mouseLeave = ->
  @unTouch()

MouseSensorMorph::mouseDownLeft = ->
  @touch()

MouseSensorMorph::mouseClickLeft = ->
  @unTouch()

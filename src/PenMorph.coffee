# this file is excluded from the fizzygum homepage build

# I am a simple LOGO-wise turtle. Note that this morph's graphical
# representation is ONLY the turtle, not the graphics that come
# out of it. The graphics generated by the pen are located in the
# canvas it was attached to when the graphics commands have
# been issued.
#
# example code to run:
#   this.sierpinski(400,40);

class PenMorph extends Widget
  
  heading: 0
  penSize: nil
  isDown: true
  penPoint: 'tip' # or 'center'
  
  constructor: ->
    @penSize = WorldMorph.preferencesAndSettings.handleSize * 4
    super()
    @rawSetExtent new Point @penSize, @penSize
    # todo we need to change the size two times, for getting the right size
    # of the arrow and of the line. Probably should make the two distinct
    @penSize = 1

  iHaveBeenAddedTo: (whereTo, beingDropped) ->
    if !(whereTo instanceof ActivePointerWdgt or whereTo instanceof CanvasMorph)
      @inform "a pen will only\nwork on a canvas..."

  # NOTE: here we are painting the turtle/pen,
  # NOT what the turtle/pen is drawing!
    
  # This method only paints this very morph's "image",
  # it doesn't descend the children
  # recursively. The recursion mechanism is done by fullPaintIntoAreaOrBlitFromBackBuffer, which
  # eventually invokes paintIntoAreaOrBlitFromBackBuffer.
  # Note that this morph might paint something on the screen even if
  # it's not a "leaf".
  paintIntoAreaOrBlitFromBackBuffer: (aContext, clippingRectangle, appliedShadow) ->

    if @preliminaryCheckNothingToDraw clippingRectangle, aContext
      return

    [area,sl,st,al,at,w,h] = @calculateKeyValues aContext, clippingRectangle
    return nil if w < 1 or h < 1 or area.isEmpty()

    aContext.save()

    # clip out the dirty rectangle as we are
    # going to paint the whole of the box
    aContext.clipToRectangle al,at,w,h

    aContext.globalAlpha = @alpha

    aContext.useLogicalPixelsUntilRestore()
    morphPosition = @position()
    aContext.translate morphPosition.x, morphPosition.y

    direction = @heading
    len = @width() / 2
    start = @center().subtract(@position())

    if @penPoint is "tip"
      dest = start.distanceAngle(len * 0.75, direction - 180)
      left = start.distanceAngle(len, direction + 195)
      right = start.distanceAngle(len, direction - 195)
    else # 'middle'
      dest = start.distanceAngle(len * 0.75, direction)
      left = start.distanceAngle(len * 0.33, direction + 230)
      right = start.distanceAngle(len * 0.33, direction - 230)

    aContext.fillStyle = @color.toString()
    aContext.beginPath()

    aContext.moveTo start.x, start.y
    aContext.lineTo left.x, left.y
    aContext.lineTo dest.x, dest.y
    aContext.lineTo right.x, right.y

    aContext.closePath()
    aContext.strokeStyle = Color.WHITE.toString()
    aContext.lineWidth = 3
    aContext.stroke()
    aContext.strokeStyle = Color.BLACK.toString()
    aContext.lineWidth = 1
    aContext.stroke()
    aContext.fill()

    aContext.restore()

    # paintHighlight is usually made to work with
    # al, at, w, h which are actual pixels
    # rather than logical pixels, so it's generally used
    # outside the effect of the scaling because
    # of the ceilPixelRatio (i.e. after the restore)
    @paintHighlight aContext, al, at, w, h

  
  
  # PenMorph access:
  setHeading: (degrees) ->
    @heading = parseFloat(degrees) % 360
    @changed()
    
  
  # PenMorph turtle ops:
  turn: (degrees) ->
    @setHeading @heading + parseFloat degrees
  
  forward: (steps) ->
    if !@parent.backBuffer?
      return

    start = @center()
    dist = parseFloat steps
    if dist >= 0
      dest = @position().distanceAngle dist, @heading
    else
      dest = @position().distanceAngle(Math.abs(dist), (@heading - 180))
    @fullRawMoveTo dest.round()
    if @isDown
      @parent.drawLine start.subtract(@parent.position()), @center().subtract(@parent.position()), @penSize, @color
  
  down: ->
    @isDown = true
  
  up: ->
    @isDown = false
  
  # TODO I don't think this is going to
  # work. Needs to clear the canvas, not
  # to change it.
  clear: ->
    if !@parent.backBuffer?
      return
    @parent.clear()
    
  
  # PenMorph demo ops:  
  sierpinski: (length, min) ->
    if length > min
      for i in [0...3]
        @sierpinski length * 0.5, min
        @turn 120
        @forward length
  
  tree: (level, length, angle) ->
    if level > 0
      @penSize = level
      @forward length
      @turn angle
      @tree level - 1, length * 0.75, angle
      @turn angle * -2
      @tree level - 1, length * 0.75, angle
      @turn angle
      @forward -length

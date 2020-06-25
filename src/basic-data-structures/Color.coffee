# IMMUTABLE

class Color

  @augmentWith DeepCopierMixin

  # if you want values like these instead: aliceblue: "0xfff0f8ff"
  # then search for CoulourLiterals in LiveCodeLab repo

  @_literalsData:[
    ["ALICEBLUE",0xf0,0xf8,0xff]
    ["ANTIQUEWHITE",0xfa,0xeb,0xd7]
    ["AQUA",0x00,0xff,0xff]
    ["AQUAMARINE",0x7f,0xff,0xd4]
    ["AZURE",0xf0,0xff,0xff]
    ["BEIGE",0xf5,0xf5,0xdc]
    ["BISQUE",0xff,0xe4,0xc4]
    ["BLACK",0x00,0x00,0x00]
    ["BLANCHEDALMOND",0xff,0xeb,0xcd]
    ["BLUE",0x00,0x00,0xff]
    ["BLUEVIOLET",0x8a,0x2b,0xe2]
    ["BROWN",0xa5,0x2a,0x2a]
    ["BURLYWOOD",0xde,0xb8,0x87]
    ["CADETBLUE",0x5f,0x9e,0xa0]
    ["CHARTREUSE",0x7f,0xff,0x00]
    ["CHOCOLATE",0xd2,0x69,0x1e]
    ["CORAL",0xff,0x7f,0x50]
    ["CORNFLOWERBLUE",0x64,0x95,0xed]
    ["CORNSILK",0xff,0xf8,0xdc]
    ["CRIMSON",0xdc,0x14,0x3c]
    ["CYAN",0x00,0xff,0xff]
    ["DARKBLUE",0x00,0x00,0x8b]
    ["DARKCYAN",0x00,0x8b,0x8b]
    ["DARKGOLDENROD",0xb8,0x86,0x0b]
    ["DARKGRAY",0xa9,0xa9,0xa9]
    ["DARKGREY",0xa9,0xa9,0xa9]
    ["DARKGREEN",0x00,0x64,0x00]
    ["DARKKHAKI",0xbd,0xb7,0x6b]
    ["DARKMAGENTA",0x8b,0x00,0x8b]
    ["DARKOLIVEGREEN",0x55,0x6b,0x2f]
    ["DARKORANGE",0xff,0x8c,0x00]
    ["DARKORCHID",0x99,0x32,0xcc]
    ["DARKRED",0x8b,0x00,0x00]
    ["DARKSALMON",0xe9,0x96,0x7a]
    ["DARKSEAGREEN",0x8f,0xbc,0x8f]
    ["DARKSLATEBLUE",0x48,0x3d,0x8b]
    ["DARKSLATEGRAY",0x2f,0x4f,0x4f]
    ["DARKSLATEGREY",0x2f,0x4f,0x4f]
    ["DARKTURQUOISE",0x00,0xce,0xd1]
    ["DARKVIOLET",0x94,0x00,0xd3]
    ["DEEPPINK",0xff,0x14,0x93]
    ["DEEPSKYBLUE",0x00,0xbf,0xff]
    ["DIMGRAY",0x69,0x69,0x69]
    ["DIMGREY",0x69,0x69,0x69]
    ["DODGERBLUE",0x1e,0x90,0xff]
    ["FIREBRICK",0xb2,0x22,0x22]
    ["FLORALWHITE",0xff,0xfa,0xf0]
    ["FORESTGREEN",0x22,0x8b,0x22]
    ["FUCHSIA",0xff,0x00,0xff]
    ["GAINSBORO",0xdc,0xdc,0xdc]
    ["GHOSTWHITE",0xf8,0xf8,0xff]
    ["GOLD",0xff,0xd7,0x00]
    ["GOLDENROD",0xda,0xa5,0x20]
    ["GRAY",0x80,0x80,0x80]
    ["GREY",0x80,0x80,0x80]
    ["GREEN",0x00,0x80,0x00]
    ["GREENYELLOW",0xad,0xff,0x2f]
    ["HONEYDEW",0xf0,0xff,0xf0]
    ["HOTPINK",0xff,0x69,0xb4]
    ["INDIANRED",0xcd,0x5c,0x5c]
    ["INDIGO",0x4b,0x00,0x82]
    ["IVORY",0xff,0xff,0xf0]
    ["KHAKI",0xf0,0xe6,0x8c]
    ["LAVENDER",0xe6,0xe6,0xfa]
    ["LAVENDERBLUSH",0xff,0xf0,0xf5]
    ["LAWNGREEN",0x7c,0xfc,0x00]
    ["LEMONCHIFFON",0xff,0xfa,0xcd]
    ["LIGHTBLUE",0xad,0xd8,0xe6]
    ["LIGHTCORAL",0xf0,0x80,0x80]
    ["LIGHTCYAN",0xe0,0xff,0xff]
    ["LIGHTGOLDENRODYELLOW",0xfa,0xfa,0xd2]
    ["LIGHTGREY",0xd3,0xd3,0xd3]
    ["LIGHTGRAY",0xd3,0xd3,0xd3]
    ["LIGHTGREEN",0x90,0xee,0x90]
    ["LIGHTPINK",0xff,0xb6,0xc1]
    ["LIGHTSALMON",0xff,0xa0,0x7a]
    ["LIGHTSEAGREEN",0x20,0xb2,0xaa]
    ["LIGHTSKYBLUE",0x87,0xce,0xfa]
    ["LIGHTSLATEGRAY",0x77,0x88,0x99]
    ["LIGHTSLATEGREY",0x77,0x88,0x99]
    ["LIGHTSTEELBLUE",0xb0,0xc4,0xde]
    ["LIGHTYELLOW",0xff,0xff,0xe0]
    ["LIME",0x00,0xff,0x00]
    ["LIMEGREEN",0x32,0xcd,0x32]
    ["LINEN",0xfa,0xf0,0xe6]
    ["MINTCREAM",0xf5,0xff,0xfa]
    ["MISTYROSE",0xff,0xe4,0xe1]
    ["MOCCASIN",0xff,0xe4,0xb5]
    ["NAVAJOWHITE",0xff,0xde,0xad]
    ["NAVY",0x00,0x00,0x80]
    ["OLDLACE",0xfd,0xf5,0xe6]
    ["OLIVE",0x80,0x80,0x00]
    ["OLIVEDRAB",0x6b,0x8e,0x23]
    ["ORANGE",0xff,0xa5,0x00]
    ["ORANGERED",0xff,0x45,0x00]
    ["ORCHID",0xda,0x70,0xd6]
    ["PALEGOLDENROD",0xee,0xe8,0xaa]
    ["PALEGREEN",0x98,0xfb,0x98]
    ["PALETURQUOISE",0xaf,0xee,0xee]
    ["PALEVIOLETRED",0xd8,0x70,0x93]
    ["PAPAYAWHIP",0xff,0xef,0xd5]
    ["PEACHPUFF",0xff,0xda,0xb9]
    ["PERU",0xcd,0x85,0x3f]
    ["PINK",0xff,0xc0,0xcb]
    ["PLUM",0xdd,0xa0,0xdd]
    ["POWDERBLUE",0xb0,0xe0,0xe6]
    ["PURPLE",0x80,0x00,0x80]
    ["RED",0xff,0x00,0x00]
    ["ROSYBROWN",0xbc,0x8f,0x8f]
    ["ROYALBLUE",0x41,0x69,0xe1]
    ["SADDLEBROWN",0x8b,0x45,0x13]
    ["SALMON",0xfa,0x80,0x72]
    ["SANDYBROWN",0xf4,0xa4,0x60]
    ["SEAGREEN",0x2e,0x8b,0x57]
    ["SEASHELL",0xff,0xf5,0xee]
    ["SIENNA",0xa0,0x52,0x2d]
    ["SILVER",0xc0,0xc0,0xc0]
    ["SKYBLUE",0x87,0xce,0xeb]
    ["SLATEBLUE",0x6a,0x5a,0xcd]
    ["SLATEGRAY",0x70,0x80,0x90]
    ["SLATEGREY",0x70,0x80,0x90]
    ["SNOW",0xff,0xfa,0xfa]
    ["SPRINGGREEN",0x00,0xff,0x7f]
    ["STEELBLUE",0x46,0x82,0xb4]
    ["TAN",0xd2,0xb4,0x8c]
    ["TEAL",0x00,0x80,0x80]
    ["THISTLE",0xd8,0xbf,0xd8]
    ["TOMATO",0xff,0x63,0x47]
    ["TURQUOISE",0x40,0xe0,0xd0]
    ["VIOLET",0xee,0x82,0xee]
    ["WHEAT",0xf5,0xde,0xb3]
    ["WHITE",0xff,0xff,0xff]
    ["WHITESMOKE",0xf5,0xf5,0xf5]
    ["YELLOW",0xff,0xff,0x00]
    ["YELLOWGREEN",0x9a,0xcd,0x32]
  ]

  @AVAILABLE_LITERALS_NAMES: []

  _r: nil
  _g: nil
  _b: nil
  _a: nil

  constructor: (@_r = 0, @_g = 0, @_b = 0, @_a=1) ->
    # all values are optional, just (r, g, b) is fine

  bluerBy: (howMuchMoreBlue) ->
    new @constructor @_r, @_g, (@_b+howMuchMoreBlue), @_a
  
  # Color string representation: e.g. 'rgba(255,165,0,1)'
  toString: ->
    "rgba(" + Math.round(@_r) + "," + Math.round(@_g) + "," + Math.round(@_b) + "," + @_a + ")"


  # »>> this part is excluded from the fizzygum homepage build
  # currently unused. Also: duplicated function
  prepareBeforeSerialization: ->
    @className = @constructor.name
    @classVersion = "0.0.1"
    @serializerVersion = "0.0.1"
    for property of @
      if @[property]?
        if typeof @[property] == 'object'
          if !@[property].className?
            if @[property].prepareBeforeSerialization?
              @[property].prepareBeforeSerialization()
  # this part is excluded from the fizzygum homepage build <<«
  
  # Color comparison:
  equals: (aColor) ->
    # ==
    @==aColor or (aColor and @_r == aColor._r and @_g == aColor._g and @_b == aColor._b and @_a == aColor._a)
  
  
  # »>> this part is excluded from the fizzygum homepage build
  
  # Color mixing:
  # currently unused
  mixed: (proportion, otherColor) ->
    # answer a copy of this color mixed with another color, ignore alpha
    frac1 = Math.min Math.max(proportion, 0), 1
    frac2 = 1 - frac1
    new @constructor(
      @_r * frac1 + otherColor._r * frac2,
      @_g * frac1 + otherColor._g * frac2,
      @_b * frac1 + otherColor._b * frac2,
      @_a * frac1 + otherColor._a * frac2)
  
  # currently unused
  darker: (percent) ->
    # return an rgb-interpolated darker copy of me, ignore alpha
    fract = 0.8333
    fract = (100 - percent) / 100  if percent
    @mixed fract, @constructor.BLACK
  
  # currently unused
  lighter: (percent) ->
    # return an rgb-interpolated lighter copy of me, ignore alpha
    fract = 0.8333
    fract = (100 - percent) / 100  if percent
    @mixed fract, @constructor.WHITE
  
  # this part is excluded from the fizzygum homepage build <<«

  # static method to initialise static constants. Will be called
  # immediately after the Class is defined
  # Note that this puts a spanner in the source management system
  # i.e. the source doesn't show these colors. Whatever solution you
  # put in place, remember that you should be able to re-generate valid
  # sources from whatever source code is loaded. I.e. the roundtrip
  # should be source -> parsed sources -> regen sources and the 1st step == last step
  @initStaticConstsAfterClassDefinition: ->
    for eachLiteral in @_literalsData
      @[eachLiteral[0]] = new @ eachLiteral[1], eachLiteral[2], eachLiteral[3]
      @AVAILABLE_LITERALS_NAMES.push eachLiteral[0]

    # release this chunk of memory since we only use it here to initialise
    # the static constants
    @_literalsData = null

    # there are two more constants that don't fit the
    # rgb pattern description, let's initialise them here
    @TRANSPARENT = new @ 0,0,0,0
    @AVAILABLE_LITERALS_NAMES.push "TRANSPARENT"

    # anglecolor is a special
    # color that tells the engine to use the
    # normal material.
    # It would be tempting to set it to a numeric value such as
    # 1 unit higher than then any max 32 bit integer, but it's such a special
    # case that it's OK to use a non-integer.
    # note that this is not an actual Color!
    @ANGLECOLOR = "angleColor"

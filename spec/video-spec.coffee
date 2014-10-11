###
Author:  Lyall Jonathan Di Trapani
LJD 16-bit Computer Video Sub-system
---------|---------|---------|---------|---------|---------|---------|--
###
RAM_TILE = [
  parseInt '00011011' + '11100100', 2
  parseInt '11111111' + '11111111', 2
  parseInt '00000000' + '11111111', 2
  parseInt '01010101' + '11111111', 2
  parseInt '00000000' + '10101010', 2
  parseInt '00000000' + '00000000', 2
  parseInt '00000000' + '00000000', 2
  parseInt '11100100' + '00011011', 2
]

test 'Single 16-bit color to 24-bit color conversion', ->
  inputs = [
    parseInt('00000' + '000000' + '00000', 2) # Black
    parseInt('11111' + '000000' + '00000', 2) # Red
    parseInt('00000' + '111111' + '00000', 2) # Green
    parseInt('00000' + '000000' + '11111', 2) # Blue
    parseInt('11111' + '111111' + '11111', 2) # White
    parseInt('00000' + '100000' + '10000', 2) # Cyan
    parseInt('10101' + '101011' + '00000', 2) # Yellow
    parseInt('10000' + '000000' + '10000', 2) # Magenta
  ]
  outputs = [
    [0, 0, 0]
    [0xFF, 0, 0]
    [0, 0xFF, 0]
    [0, 0, 0xFF]
    [0xFF, 0xFF, 0xFF]
    [0, 130, 132]
    [173, 174, 0]
    [132, 0, 132]
  ]
  for input, i in inputs
    output = outputs[i]
    deepEqual ljd.Video.to24bitColor(input), output

module 'Tile',
  setup: ->
    ramTile = [
      parseInt '00011011' + '11100100', 2
      parseInt '11111111' + '11111111', 2
      parseInt '00000000' + '11111111', 2
      parseInt '01010101' + '11111111', 2
      parseInt '00000000' + '10101010', 2
      parseInt '00000000' + '00000000', 2
      parseInt '00000000' + '00000000', 2
      parseInt '11100100' + '00011011', 2
    ]
    @array = [
      [0, 1, 2, 3, 3, 2, 1, 0]
      [3, 3, 3, 3, 3, 3, 3, 3]
      [0, 0, 0, 0, 3, 3, 3, 3]
      [1, 1, 1, 1, 3, 3, 3, 3]
      [0, 0, 0, 0, 2, 2, 2, 2]
      [0, 0, 0, 0, 0, 0, 0, 0]
      [0, 0, 0, 0, 0, 0, 0, 0]
      [3, 2, 1, 0, 0, 1, 2, 3]
    ]
    @tile = new ljd.Video.Tile(ramTile)

test 'construction', ->
  deepEqual @tile.array, @array

test 'flip about NO axies', ->
  actualArray = @tile.flip(0) # %00 base 2
  deepEqual actualArray, @array

test 'flip about X axis', ->
  expectedArray = [
    [3, 2, 1, 0, 0, 1, 2, 3]
    [0, 0, 0, 0, 0, 0, 0, 0]
    [0, 0, 0, 0, 0, 0, 0, 0]
    [0, 0, 0, 0, 2, 2, 2, 2]
    [1, 1, 1, 1, 3, 3, 3, 3]
    [0, 0, 0, 0, 3, 3, 3, 3]
    [3, 3, 3, 3, 3, 3, 3, 3]
    [0, 1, 2, 3, 3, 2, 1, 0]
  ]
  actualArray = @tile.flip(2) # %10 base 2
  deepEqual actualArray, expectedArray

test 'flip about Y axis', ->
  expectedArray = [
    [0, 1, 2, 3, 3, 2, 1, 0]
    [3, 3, 3, 3, 3, 3, 3, 3]
    [3, 3, 3, 3, 0, 0, 0, 0]
    [3, 3, 3, 3, 1, 1, 1, 1]
    [2, 2, 2, 2, 0, 0, 0, 0]
    [0, 0, 0, 0, 0, 0, 0, 0]
    [0, 0, 0, 0, 0, 0, 0, 0]
    [3, 2, 1, 0, 0, 1, 2, 3]
  ]
  actualArray = @tile.flip(1) # %01 base 2
  deepEqual actualArray, expectedArray

test 'flip about X and Y axies', ->
  expectedArray = [
    [3, 2, 1, 0, 0, 1, 2, 3]
    [0, 0, 0, 0, 0, 0, 0, 0]
    [0, 0, 0, 0, 0, 0, 0, 0]
    [2, 2, 2, 2, 0, 0, 0, 0]
    [3, 3, 3, 3, 1, 1, 1, 1]
    [3, 3, 3, 3, 0, 0, 0, 0]
    [3, 3, 3, 3, 3, 3, 3, 3]
    [0, 1, 2, 3, 3, 2, 1, 0]
  ]
  actualArray = @tile.flip(3) # %11 base 2
  deepEqual actualArray, expectedArray

test 'Bad input', ->
  throws (-> @tile.flip(4)), /n=4; n must be between 0 and 3 inclusive/


module 'Cell',
  setup: ->

test 'construction', ->
  ramCell = (2 << 8) + (1 << 4) + 0   # Tile # 2, cp1 = 1, cp2 = 0
  cell = new ljd.Video.Cell(ramCell)
  equal cell.tileIndex, 2
  equal cell.colorPair1, 1
  equal cell.colorPair2, 0
  equal cell.sprite, false


class MockCanvasContext

  constructor: (@imageData) ->

  createImageData: (width, height) ->
    @imageData

  putImageData: (imageData, x, y) ->


module 'Video',
  setup: ->
    Video = ljd.Video
    @ram = (0 for _ in [0...(Math.pow(2, 16))])

    addressOfTile2 = Video.TILE_INDEX + (Video.TILE_INDEX_STEP * 2)
    @ram[addressOfTile2...(addressOfTile2 + 8)] = RAM_TILE

    TILE_COLORS = Video.TILE_COLORS
    @ram[TILE_COLORS...(TILE_COLORS + 4)] = [
      parseInt('00000' + '000000' + '00000', 2) # Black
      parseInt('11111' + '000000' + '00000', 2) # Red
      parseInt('00000' + '111111' + '00000', 2) # Green
      parseInt('00000' + '000000' + '11111', 2) # Blue
    ]
    SPRITE_COLORS = Video.SPRITE_COLORS
    @ram[SPRITE_COLORS...(SPRITE_COLORS + 4)] = [
      parseInt('11111' + '111111' + '11111', 2) # White
      parseInt('00000' + '100000' + '10000', 2) # Cyan
      parseInt('10101' + '101011' + '00000', 2) # Yellow
      parseInt('10000' + '000000' + '10000', 2) # Magenta
    ]

    addressOfCell1 = Video.GRID_CELLS + 1
    @ram[Video.GRID_CELLS...(Video.GRID_CELLS + 8)] = [
      #gridCell:tileIndex;colorPair1;colorPair2
      parseInt('00000010' + '0001' + '0000', 2)
      parseInt('00000010' + '0001' + '0000', 2)
      parseInt('00000010' + '0001' + '0000', 2)
      parseInt('00000010' + '0001' + '0000', 2)
      parseInt('00000010' + '0000' + '0001', 2)
      parseInt('00000010' + '0000' + '0001', 2)
      parseInt('00000010' + '0000' + '0001', 2)
      parseInt('00000010' + '0000' + '0001', 2)
    ]
    @ram[Video.GRID_CELLS + 2399] =
      #        tile # 255   cp1=15   cp2=10
      parseInt('11111111' + '1111' + '1010', 2)

    numElements = 480 * 320 * 4 * 4
    @data = (0 for _ in [0...numElements])
    context = new MockCanvasContext({data: @data})
    @video = new Video(@ram, context, 4)

test '16-bit to 24-bit color conversion for all colors', ->
  @video.make24bitColors(@ram)
  tileColorPairs = [
    [[0, 0, 0],    [0xFF, 0, 0]]
    [[0, 0xFF, 0], [0, 0, 0xFF]]
  ]
  spriteColorPairs = [
    [[0xFF, 0xFF, 0xFF], [0, 130, 132]]
    [[173, 174, 0],      [132, 0, 132]]
  ]
  equal @video.tileColorPairs.length, 16
  equal @video.spriteColorPairs.length, 16
  deepEqual @video.tileColorPairs[0...2], tileColorPairs
  deepEqual @video.spriteColorPairs[0...2], spriteColorPairs

test 'makeTiles', ->
  @video.makeTiles()
  equal @video.tiles.length, 256
  tile2 = @video.tiles[2]
  equal tile2.array.length, 8
  equal tile2.array[7].length, 8
  deepEqual tile2.array[0], [0, 1, 2, 3, 3, 2, 1, 0]

test 'makeGrid', ->
  @video.makeGrid()
  grid = @video.grid
  [row0, row39] = [grid[0], grid[39]]
  equal grid.length, 40, '40 rows'
  deepEqual [row0.length, row39.length], [60, 60], '60 columns'
  tests = [
    [row0[0], 2, 1, 0]
    [row0[7], 2, 0, 1]
    [row39[59], 255, 15, 10]
  ]
  for [cell, tileIndex, cp1, cp2] in tests
    deepEqual [cell.tileIndex, cell.colorPair1, cell.colorPair2],
              [tileIndex, cp1, cp2],
              'Check individual cells'


###
# ? R G B #
test 'background', ->
  @video.newScreen4x()
  expectedColors = [
    #R     G     B     A
    0x00, 0x00, 0x00, 0xFF
    0x00, 0x00, 0x00, 0xFF
    0xFF, 0x00, 0x00, 0xFF
    0xFF, 0x00, 0x00, 0xFF
    0x00, 0xFF, 0x00, 0xFF
    0x00, 0xFF, 0x00, 0xFF
    0x00, 0x00, 0xFF, 0xFF
    0x00, 0x00, 0xFF, 0xFF
  ]
  # first 4 pixels (0-3) of second cell in first row
  deepEqual @data[64..95], expectedColors
###


###
# 16-bit Sprite color
#  R         G       B
# %10101   %101011  %00000
#
# 24-bit Sprite color
#  R           G          B
# %10101101   %10101110  %0000000
#  173         174        0
# $AD         $AE        $00
# The 2nd and 3rd pixels are from the background tile
# The 4th pixel is from the sprite
# ? B B S #
# ? R G Y #
# Red and green come from background
# Yello comes from sprite
###
###
test 'sprite', ->
  @video.newScreen4x()
  expectedColors = [
    #R     G     B     A
    0xFF, 0x00, 0x00, 0xFF
    0xFF, 0x00, 0x00, 0xFF
    0x00, 0xFF, 0x00, 0xFF
    0x00, 0xFF, 0x00, 0xFF
    0xAD, 0xAE, 0x00, 0xFF
    0xAD, 0xAE, 0x00, 0xFF
  ]
  deepEqual @data[8..31], expectedColors
  ok false, @data[8..31].length/8
  @ram[5..8] = [1, 2, 3, 4]
  ok false, @ram[5..9]
###
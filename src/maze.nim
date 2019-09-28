import tables, random, sets
import godot
import godotapi / [node_2d, tile_map]

type
  Direction* {.size: sizeof(cint).} = enum
    N, E ,S, W
  Directions = set[Direction]

proc toNum(f: Directions): int = cast[cint](f)

gdobj Maze of Node2D:
  var
    cellWalls = {vec2(1.0, 0.0): E, vec2(-1.0, 0.0): W,
                 vec2(0.0, 1.0): S, vec2(0.0, -1.0): N}.toTable
    tileSize: Vector2
    mapWidth = 25
    mapHeight = 15
    map: TileMap

  method ready*() =
    self.map = self.getNode("TileMap").as(TileMap)
    randomize()
    self.tileSize = self.map.cellSize
    self.makeMaze()

  proc checkNeighbors(cell: Vector2,
                      unvisited: HashSet[Vector2]): seq[Vector2] =

    for n in self.cellWalls.keys:
      if cell + n in unvisited:
        result.add(cell + n)

  proc makeMaze() =
    var
      unvisited = initHashSet[Vector2]()
      stack = initHashSet[Vector2]()

    self.map.clear()

    for x in 0 ..< self.mapWidth:
      for y in 0 ..< self.mapHeight:
        unvisited.incl(vec2(x.float, y.float))
        self.map.setCellv(vec2(x.float, y.float), toNum({N, E, S, W}))
    var current = vec2(0.0, 0.0)
    unvisited.excl(current)

    while unvisited.len != 0:
      let neighbors = self.checkNeighbors(current, unvisited)
      if neighbors.len > 0:
        let next = neighbors[rand(neighbors.high)]
        stack.incl(current)
        #remove walls from both cells
        var dir = next - current
        var currentWalls = self.map.getCellv(current) - toNum({
                                                          self.cellWalls[dir]})
        var nextWalls = self.map.getCellv(next) - toNum({self.cellWalls[-dir]})
        self.map.setCellv(current, currentWalls)
        self.map.setCellv(next, nextWalls)
        current = next
        unvisited.excl(current)
      elif stack.len > 0:
        current = stack.pop()








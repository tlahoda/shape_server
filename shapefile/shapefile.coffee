#
# @file shapefile.coffee Contains the shapefile library.
#
# Copyright (C) 2012 Thomas P. Lahoda
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#

jDataView = require('./external/jdataview').jDataView
jDataViewReader = require('./external/jdataview_reader').jDataViewReader

fs = require 'fs'

require './external/functional_arrays'

readInt32 = require('./readers').readInt32
readDouble = require('./readers').readDouble
readPoint = require('./readers').readPoint
readReversedPoint = require('./readers').readReversedPoint
readRecordHeader = require('./readers').readRecordHeader
readOffset = require('./readers').readOffset
readObjects = require('./readers').readObjects
readShape = require('./readers').readShape

load= (url) ->
  return fs.readFileSync url, 'binary'

class Header
  constructor: (shx) ->
    @header = new Array 17
    @header.apply_range 0, 7, readInt32, shx, false
    @header.apply_range 7, 9, readInt32, shx
    @header.apply_range 9, 17, readDouble, shx

    @numShapes = (@header[6] * 2.0 - 100.0) / 8.0

class Shape
  constructor: (shapeType, shp, hdrLen = 1) ->
    @header = new Array hdrLen
    @header[0] = shapeType

  eachVertex: (action) ->

##############################################################################
class Point extends Shape
  constructor: (shapeType, shp) ->
    super shapeType, shp
    @coords = readPoint shp

  eachVertex: (action) ->
    args = Array.prototype.slice_args arguments, 1
    args.unshift @coords
    @coords = action.apply null, args
    return

class PointZ extends Point
  constructor: (shapeType, shp) ->
    super shapeType, shp
    @z = shp.readDouble()
    @m = shp.readDeouble()

class PointM extends Point
  constructor: (shapeType, shp) ->
    super shapeType, shp
    @m = shp.readDouble()

##############################################################################
class MultiPoint extends Shape
  constructor: (shapeType, shp) ->
    super shapeType, shp, 6

    @header.apply_range 1, 5, readDouble, shp
    numPoints = shp.readInt32()
    @header[5] = numPoints
    @points = new Array numPoints
    @points.apply readPoint, shp

  eachVertex: (action) ->
    Array.apply.call @points, arguments
    return

class MultiPointZ extends MultiPoint
  constructor: (shapeType, shp) ->
    super shapeType, shp

    numPoints = @header[5]
    @zMin = shp.readDouble()
    @zMax = shp.readDouble()
    @zArray = new Array numPoints
    @zArray.apply readDouble, shp

    @mMin = shp.readDouble()
    @mMax = shp.readDouble()
    @mArray = new Array numPoints
    @mArray.apply readDouble, shp

class MultiPointM extends MultiPoint
  constructor: (shapeType, shp) ->
    super shapeType, shp

    numPoints = @header[5]
    @mMin = shp.readDouble()
    @mMax = shp.readDouble()
    @mArray = new Array numPoints
    @mArray.apply readDouble, shp

##############################################################################
class Polygon extends Shape
  constructor: (shapeType, shp) ->
    super shapeType, shp, 7

    @header.apply_range 1, 5, readDouble, shp
    @header.apply_range 5, 7, readInt32, shp

    numParts = @header[5]
    numPoints = @header[6]

    @partsIndex = new Array numParts
    @partsIndex.apply readInt32, shp

    @parts = new Array numParts
    readObjects @parts, numPoints, @partsIndex, readReversedPoint, shp

  eachVertex: (action) ->
    args = Array.prototype.slice_args arguments
    args.unshift (part) ->
      args2 = Array.prototype.slice_args arguments, 1
      part.apply.apply part, args2
      return

    @parts.for_each.apply @parts, args
    return

class PolygonZ extends Polygon
  constructor: (shapeType, shp) ->
    super shapeType, shp

    numParts = @header[5]
    numPoints = @header[6]

    @zMin = shp.readDouble()
    @zMax = shp.readDouble()
    @zArray = [numPoints]
    readObjects @zArray, numPoints, @partsIndex, readDouble, shp

    @mMin = shp.readDouble()
    @mMax = shp.readDouble()
    @mArray = [numParts]
    readObjects @mArray, numPoints, @partsIndex, readDouble, shp

class PolygonM extends Polygon
  constructor: (shapeType, shp) ->
    super shapeType, shp

    numParts = @header[5]
    numPoints = @header[6]

    @mMin = shp.readDouble()
    @mMax = shp.readDouble()
    @mArray = [numParts]
    readObjects @mArray, numPoints, @partsIndex, readDouble, shp

class PolyLine extends Polygon
  constructor: (shapeType, shp) ->
    super shapeType, shp

class PolyLineZ extends PolygonZ
  constructor: (shapeType, shp) ->
    super shapeType, shp

class PolyLineM extends PolygonM
  constructor: (shapeType, shp) ->
    super shapeType, shp

##############################################################################
class Multipatch extends Shape
  constructor: (shapeType, shp) ->
    super shapeType, shp

##############################################################################

ShapeFactory = (offset, shp) ->
  shp.seek offset
  shapeType = shp.readInt32()

  switch shapeType
    when 0 then return new Shape shapeType, shp
    when 1 then return new Point shapeType, shp
    when 3 then return new PolyLine shapeType, shp
    when 5 then return new Polygon shapeType, shp
    when 8 then return new MultiPoint shapeType, shp
    when 11 then return new PointZ shapeType, shp
    when 13 then return new PolyLineZ shapeType, shp
    when 15 then return new PolygonZ shapeType, shp
    when 18 then return new MultiPointZ shapeType, shp
    when 21 then return new PointM shapeType, shp
    when 23 then return new PolyLineM shapeType, shp
    when 25 then return new PolygonM shapeType, shp
    when 28 then return new MultiPointM shapeType, shp
    when 31 then return new MultiPatch shapeType, shp
    else throw "Shape type unknown."

##############################################################################
class Shapefile
  constructor: (@name) ->
    shx = new jDataViewReader new jDataView load @name + ".shx"
    @header = new Header shx
    
    @shapes = new Array @header.numShapes
    @shapes.apply readOffset, shx

    shp = new jDataViewReader new jDataView load @name + ".shp"
    @shapes.apply readShape, shp, ShapeFactory

exports.Shapefile = Shapefile

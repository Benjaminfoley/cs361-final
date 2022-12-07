#!/usr/bin/env ruby

class Track

  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    @segments = segment_objects
  end

  def get_track_json()
    json_output = '{"type": "Feature", '
    if @name != nil
      json_output+= '"properties": {"title": "' + @name + '"},'
    end
    json_output += '"geometry": {"type": "MultiLineString","coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        json_output += ","
      end
      json_output += '['
      # Loop through all the coordinates in the segment
      track_segment_json = ''
      s.coordinates.each do |c|
        if track_segment_json != ''
          track_segment_json += ','
        end
        track_segment_json += '['
        track_segment_json += "#{c.lon},#{c.lat}"
        if c.ele != nil
          track_segment_json += ",#{c.ele}"
        end
        track_segment_json += ']'
      end
      json_output+=track_segment_json
      json_output+=']'
    end
    json_output + ']}}'
  end
end
class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint

attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    json_output = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    json_output += "[#{@lon},#{@lat}"
    if ele != nil
      json_output += ",#{@ele}"
    end
    json_output += ']},'
    if name != nil or type != nil
      json_output += '"properties": {'
      if name != nil
        json_output += '"title": "' + @name + '"'
      end
      if type != nil
        if name != nil
          json_output += ','
        end
        json_output += '"icon": "' + @type + '"'
      end
      json_output += '}'
    end
    json_output += "}"
    return json_output
  end
end

class World

def initialize(name, features)
  @name = name
  @features = features
end
  def add_feature(features)
    @features.append(t)
  end

  def to_geojson(indent=0)
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature,i|
      if i != 0
        s +=","
      end
        if feature.class == Track
            s += feature.get_track_json
        elsif feature.class == Waypoint
            s += feature.get_waypoint_json
      end
    end
    s + "]}"
  end
end

def main()
  waypoint_1 = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint_2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ 
    Point.new(-121, 45),
    Point.new(-121, 46), 
  ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track_1 = Track.new([ts1, ts2], "track 1")
  track_2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [waypoint_1, waypoint_2, track_1, track_2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end


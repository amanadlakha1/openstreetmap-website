module GeoRecord
  # This scaling factor is used to convert between the float lat/lon that is 
  # returned by the API, and the integer lat/lon equivalent that is stored in
  # the database.
  SCALE = 10000000
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  def before_save
    self.update_tile
  end

  # Is this node within -90 >= latitude >= 90 and -180 >= longitude >= 180
  # * returns true/false
  def in_world?
    return false if self.lat < -90 or self.lat > 90
    return false if self.lon < -180 or self.lon > 180
    return true
  end

  def update_tile
    self.tile = QuadTile.tile_for_point(lat, lon)
  end

  def lat=(l)
    self.latitude = (l * SCALE).round
  end

  def lon=(l)
    self.longitude = (l * SCALE).round
  end

  # Return WGS84 latitude
  def lat
    return self.latitude.to_f / SCALE
  end

  # Return WGS84 longitude
  def lon
    return self.longitude.to_f / SCALE
  end

private
  
  def lat2y(a)
    180/Math::PI * Math.log(Math.tan(Math::PI/4+a*(Math::PI/180)/2))
  end

  module ClassMethods
    def find_by_area(minlat, minlon, maxlat, maxlon, options)
      self.with_scope(:find => {:conditions => OSM.sql_for_area(minlat, minlon, maxlat, maxlon)}) do
        return self.find(:all, options)
      end
    end
	def find_by_area_no_quadtile(minlat, minlon, maxlat, maxlon, options)
      self.with_scope(:find => {:conditions => OSM.sql_for_area_no_quadtile(minlat, minlon, maxlat, maxlon)}) do
        return self.find(:all, options)
      end
    end
  end
end


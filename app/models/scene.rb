# == Schema Information
#
# Table name: scenes
#
#  id           :integer          not null, primary key
#  adventure_id :integer
#  title        :string(255)
#  first_visit  :text
#  description  :text
#  image        :text
#  end          :boolean
#  multi_visit  :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

class Scene < ActiveRecord::Base
  #attributes
  attr_accessible :title, :description, :image, :end, :adventure_id
  
  #relationships
  belongs_to :adventure
  #self-join relationships
  has_many(:tracks, :foreign_key => :origin_id, :dependent => :destroy)
  has_many(:destinations, :through => :tracks, :source => :destination)

  has_many(:reverse_tracks, :class_name => :Track, :foreign_key => :destination_id, :dependent => :destroy)
  #to find the 'origins', scenes that have a 'track' to this scene, an origins method has been created below

  #validations
  validates :title, :presence => true
  validates :description, :presence => true

  #-------------------------------------------------------------------
  
  #returns the origin scenes (scenes with a path to the current scene)
  def origins
    #returns an array of the origin scene ids
    origin_ids = Track.where("destination_id = #{self.id}").pluck(:origin_id)
    #find the origin scenes
    origins = Scene.where(:id => origin_ids)
  end

  #returns true if this scene is the start of an adventure
  def start?
    @start = self.adventure.start_scene_id == self.id
  end

  def not_start?
    @not_start = self.adventure.start_scene_id != self.id
  end

  #finds the track between an origin scene and this scene (the destination)
  def track_to_here(origin)
    track = origin.tracks.where("destination_id = ?",self.id).first
  end

  def new_track_options
    #OPTIONS SHOULD BE NIL IF IT'S THE END!
    new_track_options = self.adventure.scenes.select do |scene| 
      #find all scenes where this scene has no track to and the scene is not this scene
      self.destinations.exclude? scene #&& scene != self
      # true
    end
  end

end

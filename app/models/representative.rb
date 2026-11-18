# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id           :integer          not null, primary key
#  address      :string
#  name         :string
#  ocdid        :string
#  party        :string
#  phone_number :string
#  photo_url    :string
#  title        :string
#  website_url  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials.geocodio_api_key)
    raise ArgumentError, 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    reps = []
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    @legislators = fields['congressional_districts'][0]['current_legislators']

    @legislators.each_with_index do |official, _index|
      official['name'] = "#{official.dig('bio', 'first_name')} #{official.dig('bio', 'last_name')}"
      title = official['type']
      ocdid = official.dig('references', 'govtrack_id')
      reps << Representative.find_rep(official, ocdid: ocdid, title: title)
    end
    reps
  end

  def self.find_rep(official, title: '', ocdid: '')
    rep = Representative.find_or_initialize_by(ocdid: ocdid)
    rep.update!(name: official['name'], title: title, **profile_attributes(official))
    rep
  end

  def self.profile_attributes(official)
    {
      party: official.dig('bio', 'party'),
      photo_url: official.dig('bio', 'photo_url'),
      address: official.dig('contact', 'address'),
      phone_number: official.dig('contact', 'phone'),
      website_url: official.dig('contact', 'url')
    }
  end

  def update_from_geocodio(official)
    self.title = official['type']
    self.ocdid = official.dig('references', 'govtrack_id')
    assign_attributes(self.class.profile_attributes(official))
    save!
    self
  end
end

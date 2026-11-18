# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative do
  let(:official) do
    { 'type' => 'senator',
      'bio' => { 'first_name' => 'Alex', 'last_name' => 'Padilla',
                 'party' => 'Democrat', 'photo_url' => 'https://example.com/padilla.jpg' },
      'contact' => { 'address' => '331 Hart Senate Office Building Washington DC 20510',
                     'phone' => '202-224-3553', 'url' => 'https://www.padilla.senate.gov' },
      'references' => { 'govtrack_id' => '456789' } }
  end

  let(:api_response) do
    { 'results' => [{ 'response' => { 'results' => [{ 'fields' => {
      'congressional_districts' => [{ 'current_legislators' => [official] }]
    } }] } }] }
  end

  describe '.civic_api_to_representative_params' do
    let(:rep) { described_class.civic_api_to_representative_params(api_response).first }

    it 'saves party and photo from bio' do
      expect(rep).to have_attributes(party: 'Democrat', photo_url: 'https://example.com/padilla.jpg')
    end

    it 'saves address, phone, and website from contact' do
      expect(rep).to have_attributes(
        address: '331 Hart Senate Office Building Washington DC 20510',
        phone_number: '202-224-3553',
        website_url: 'https://www.padilla.senate.gov'
      )
    end
  end

  describe '#update_from_geocodio' do
    it 'updates profile fields on an existing rep' do
      rep = described_class.create!(name: 'Alex Padilla', ocdid: '456789')
      rep.update_from_geocodio(official)
      expect(rep.reload).to have_attributes(party: 'Democrat', phone_number: '202-224-3553')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe RepresentativesController do
  render_views

  let(:rep) do
    Representative.create!(name: 'Alex Padilla', ocdid: '456789', title: 'senator', party: 'Democrat',
                           photo_url: 'https://example.com/padilla.jpg',
                           address: '331 Hart Senate Office Building Washington DC 20510',
                           phone_number: '202-224-3553', website_url: 'https://www.padilla.senate.gov')
  end

  describe 'GET show' do
    before { get :show, params: { id: rep.id } }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns the requested representative' do
      expect(assigns(:representative)).to eq(rep)
    end

    it 'shows the name, title, and party' do
      expect(response.body).to include('Alex Padilla', 'senator', 'Democrat')
    end

    it 'shows the contact info' do
      expect(response.body).to include('331 Hart Senate Office Building', '202-224-3553',
                                       'https://www.padilla.senate.gov')
    end

    it 'shows the photo with alt text' do
      expect(response.body).to include('src="https://example.com/padilla.jpg"', 'alt="Photo of Alex Padilla"')
    end
  end

  describe 'GET show with missing info' do
    it 'still renders when profile fields are blank' do
      bare = Representative.create!(name: 'Jane Doe', ocdid: '111')
      get :show, params: { id: bare.id }
      expect(response).to be_successful
    end
  end
end

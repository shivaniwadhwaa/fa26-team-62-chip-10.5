# frozen_string_literal: true

require 'rails_helper'

describe NewsItemsController do
  render_views

  let(:rep) { Representative.create!(name: 'Alex Padilla', ocdid: '456789') }
  let(:item) { rep.news_items.create!(title: 'Padilla on housing', link: 'https://example.com/article') }

  describe 'GET show' do
    it 'links the representative name to their profile page' do
      get :show, params: { representative_id: rep.id, id: item.id }
      expect(response.body).to include(%(href="#{representative_path(rep)}"))
    end
  end
end

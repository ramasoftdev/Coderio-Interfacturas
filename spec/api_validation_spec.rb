# frozen_string_literal: true

require 'rails_helper'
require 'public_api'

RSpec.describe 'api validation', type: :request do
  include PublicApi

  let(:now) { Time.now.to_i }

  context 'when posting event with wrong request params' do
    it 'returns 400 status code' do
      post_event({})
    end

    it 'returns 400 status code' do
      post_event({ employee_id: nil, kind: :in, timestamp: now })
    end

    it 'returns 400 status code' do
      post_event({ employee_id: 1, kind: nil, timestamp: now })
    end

    it 'returns 400 status code' do
      post_event({ employee_id: 1, kind: :in, timestamp: nil })
    end

    it 'returns 400 status code' do
      post_event({ employee_id: 'bad', kind: :in, timestamp: now })
    end

    it 'returns 400 status code' do
      post_event({ employee_id: 1, kind: 'bad', timestamp: now })
    end

    it 'returns 400 status code' do
      post_event({ employee_id: 1, kind: :in, timestamp: 'bad' })
    end
  end

  context 'when getting report with wrong request params' do
    it 'returns 400 status code' do
      get_report(1, 'bad', '2019-01-01')

      expect(response.status).to eq(400)
    end

    it 'returns 400 status code' do
      get_report(1, '2019-01-01', 'bad')

      expect(response.status).to eq(400)
    end

    it 'returns 400 status code' do
      get_report('bad', '2019-01-01', '2019-02-02')

      expect(response.status).to eq(400)
    end
  end
end

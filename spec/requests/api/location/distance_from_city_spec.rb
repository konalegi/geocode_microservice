# frozen_string_literal: true

describe 'GET /api/distance/from_city', type: :request do
  let(:url) { '/api/distance/from_city' }
  let(:city_name) { SecureRandom.hex }
  let(:dst) do
    { lat: rand(100).to_s, lon: rand(100).to_s }
  end

  let(:params) do
    { city_name: city_name, dst: dst }
  end

  context 'success' do
    let(:distance) { rand(100) }

    before do
      expect(Route::InRegion).to receive(:distance_from_city).
        with(city_name: city_name, dst: dst).and_return(distance)

      post(url, params: params)
    end

    specify do
      expect(response).to have_http_status(200)
      expect(parsed_body).to eq('distance' => distance)
    end
  end

  context 'failure' do
    let(:error_str) { SecureRandom.hex }

    before do
      expect(Route::InRegion).to receive(:distance_from_city).
        and_raise(Route::InRegion::BaseError, error_str)

      post(url, params: params)
    end

    specify do
      expect(response).to have_http_status(422)
      expect(parsed_body).to eq('errors' => [error_str])
    end
  end
end
